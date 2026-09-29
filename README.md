# ⚠️ NSFW WARNING ⚠️

> **THIS PLUGIN SHOWS IMAGES FROM CHAT AUTOMATICALLY.**
> **ANYONE CAN POST NSFW, GORE OR OTHER NASTY STUFF AND IT WILL SHOW UP ON YOUR SCREEN.**
> **DON'T USE IT ON STREAM, AT WORK, OR IN CHATS YOU DON'T TRUST.**

# Link Thumbnails

Image links in chat show up as images. Click one to open it.

## Install

### 1. Get a nightly build of Chatterino

Plugins only work on nightly builds. Stable 2.5.5 won't work.

Download the latest nightly from the [Chatterino releases page](https://github.com/Chatterino/chatterino2/releases/tag/nightly-build) and install it.

### 2. Turn on plugins

1. Open Chatterino **Settings** (the gear icon, top right).
2. Go to **Plugins**.
3. Tick **Enable plugins**.

### 3. Download this plugin

1. On this GitHub page, click the green **Code** button → **Download ZIP**.
2. Unzip it. You get a folder called `chatterino-link-thumbnails-master` with `init.lua` and `info.json` inside.

### 4. Put it in your Plugins folder

1. In **Settings → Plugins**, click **Open Plugin Directory**.
2. Move the whole unzipped folder into it.

   It should look like this:

   ```
   Plugins/
   └── chatterino-link-thumbnails-master/
       ├── info.json
       └── init.lua
   ```

   `init.lua` must be directly inside the folder, not inside another folder inside it.

If the button isn't there, the Plugins folder is usually:

- Windows: `%APPDATA%\Chatterino2\Plugins`
- Linux: `~/.local/share/chatterino/Plugins`
- macOS: `~/Library/Application Support/chatterino/Plugins`

### 5. Enable it

1. Restart Chatterino.
2. Go to **Settings → Plugins**.
3. Find **Link Thumbnails** and click **Enable**.
4. It asks for **Network** permission, which it needs to download the images. Allow it.

### 6. Test it

Post an image link in any chat, for example a `kappa.lol` or `imgur.com` link. After a second it turns into an image.

## Troubleshooting

- **Nothing happens:** check that the plugin is enabled and that you restarted Chatterino.
- **Images show up twice:** you have two copies of the plugin. Delete one folder.
- **Size changes don't show:** Chatterino caches images, so restart it after editing `init.lua`.

## Settings

Edit `init.lua` with any text editor, then restart Chatterino.

- **Image size:** change `MAX_HEIGHT` (the tallest an image can be, in pixels). It scales with Chatterino's zoom, just like emotes.
- **More sites:** add them to `HOSTS`.

## Which links?

- Image sites like imgur, kappa.lol, gyazo and catbox
- Links ending in `.png`, `.jpg`, `.gif` or `.webp`
