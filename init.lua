local json = require("chatterino.json")

local RESOLVER = "https://braize.pajlada.com/chatterino/link_resolver/"
local MAX_HEIGHT = 120 
local SCALE = MAX_HEIGHT / 300
local RETRIES = 3
local MAX_PER_MESSAGE = 3 -- distinct links; the rest stay as plain links

local HOSTS = {
    "kappa.lol",
    "i.nuuls.com",
    "imgur.com",
    "gyazo.com",
    "prnt.sc",
    "ibb.co",
    "postimg.cc",
    "catbox.moe",
    "i.redd.it",
    "pbs.twimg.com",
    "media.discordapp.net",
    "cdn.discordapp.com",
    "giphy.com",
    "tenor.com",
    "media.mrdoebs.lol",
    "femboy.beauty",
    "segs.lol",
    "olrite.lol",
    "p.ftk.li",
}

local EXTENSIONS = { png = true, jpg = true, jpeg = true, gif = true, webp = true, avif = true }

local cache = {}
local hooked = {}

local function allowed(url)
    local host = url:match("^%a+://([^/:?#]+)")
    if not host then
        return false
    end
    local ext = url:match("^[^?#]+"):match("%.(%w+)$")
    if ext and EXTENSIONS[ext:lower()] then
        return true
    end
    host = host:lower()
    for _, h in ipairs(HOSTS) do
        if host == h or host:sub(-#h - 1) == "." .. h then
            return true
        end
    end
    return false
end

local function encode(s)
    return (s:gsub("[^%w%-%._~]", function(c)
        return string.format("%%%02X", c:byte())
    end))
end

local function fetch(url, cb, attempt)
    attempt = attempt or 1
    local req = c2.HTTPRequest.create(c2.HTTPMethod.Get, url)
    req:set_timeout(15000)
    req:on_success(cb)
    req:on_error(function()
        if attempt >= RETRIES then
            return cb(nil)
        end
        c2.later(function()
            fetch(url, cb, attempt + 1)
        end, math.floor(1000 * 3 ^ (attempt - 1)))
    end)
    req:execute()
end

-- Only hand back thumbnails that actually downloaded: a thumbnail that fails to
-- load renders as a zero-size image, hiding the link with nothing to click.
local function resolve(url, cb)
    if cache[url] then
        return cb(cache[url])
    end
    fetch(RESOLVER .. encode(url), function(res)
        local ok, data = pcall(json.parse, res and res:data() or "")
        local thumb = ok and type(data) == "table" and data.status == 200 and data.thumbnail
        if not thumb then
            return cb(false)
        end
        fetch(thumb, function(img)
            cache[url] = img and #img:data() > 0 and thumb or nil
            cb(cache[url] or false)
        end)
    end)
end

local function rebuild(msg, thumbs)
    local elements = {}
    local src = msg:elements()
    local first = true
    for i = 1, #src do
        if thumbs[i] then
            -- one linebreak before the first image, the rest share its row
            if first then
                elements[#elements + 1] = { type = "linebreak", flags = c2.MessageElementFlag.AlwaysShow }
                first = false
            end
            elements[#elements + 1] = {
                type = "image",
                image = c2.Image.from_url(thumbs[i] .. "#lt", SCALE),
                flags = c2.MessageElementFlag.AlwaysShow,
                link = src[i].link,
            }
        else
            elements[#elements + 1] = src[i]
        end
    end
    return c2.Message.new({
        flags = msg.flags,
        id = msg.id,
        search_text = msg.search_text,
        message_text = msg.message_text,
        login_name = msg.login_name,
        display_name = msg.display_name,
        localized_name = msg.localized_name,
        user_id = msg.user_id,
        channel_name = msg.channel_name,
        username_color = msg.username_color,
        server_received_time = msg.server_received_time,
        highlight_color = msg.highlight_color,
        elements = elements,
    })
end

local function on_message(channel, msg)
    local links, seen, pending = {}, {}, 0
    local src = msg:elements()
    for i = 1, #src do
        local url = src[i].type == "link" and src[i].link.value
        if url and pending < MAX_PER_MESSAGE and not seen[url] and allowed(url) then
            seen[url] = true
            links[i] = url
            pending = pending + 1
        end
    end

    local thumbs = {}
    for i, url in pairs(links) do
        resolve(url, function(thumb)
            thumbs[i] = thumb or nil
            pending = pending - 1
            if pending == 0 and next(thumbs) then
                c2.later(function()
                    if channel:is_valid() then
                        channel:replace_message(msg, rebuild(msg, thumbs))
                    end
                end, 1)
            end
        end)
    end
end

local function hook_all()
    for _, win in ipairs(c2.windows:all()) do
        local nb = win.notebook
        for p = 0, nb.page_count - 1 do
            for _, split in ipairs(nb:page_at(p):splits()) do
                local ch = split.channel
                if ch and ch:is_valid() then
                    local name = ch:get_name()
                    local h = hooked[name]
                    if name ~= "" and not (h and h:is_connected()) then
                        hooked[name] = ch:on_message_appended(function(msg)
                            on_message(ch, msg)
                        end)
                    end
                end
            end
        end
    end
    c2.later(hook_all, 5000)
end

hook_all()
