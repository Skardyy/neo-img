<h1 align="center">Neo-Img</h1>  
<p align="center">🖼️ A Neovim plugin for viewing images in the terminal. 🖼️</p> 
<div align="center">
    
[![Static Badge](https://img.shields.io/badge/neovim-1e2029?logo=neovim&logoColor=3CA628&label=built%20for&labelColor=15161b)](https://neovim.io)  
</div>

---
https://github.com/user-attachments/assets/f7c76789-d57f-437c-b4da-444eebb7eb20

## Features ✨  
- Automatically preview supported image files
- Oil.nvim preview support
- Caching

## Installation 🚀  

> uses [ttyimg](https://github.com/Skardyy/ttyimg)  
> you can install it in 2 ways:  
> * via `:NeoImg Install` **(recommended)**
> * globally via `go install github.com/Skardyy/ttyimg@v1.0.5`, make sure you have GOPATH in your path `export PATH="$HOME/go/bin:$PATH`

Using lazy.nvim:
```lua
return {
    'skardyy/neo-img',
    build = ":NeoImg Install",
    config = function()
        require('neo-img').setup()
    end
}
```

## Usage 💼  
- Images will automatically preview when opening supported files  
- Use `:NeoImg DisplayImage` to manually display the current file  
- you can also call `require("neo-img.utils").display_image(filepath, win)` to display the image in the given window  

## Configuration ⚙️  
> document files require 
><details>
>  <summary>Libreoffice</summary>
> 
>  ```txt
>    make sure its installed and in your path  
>    * window: its called soffice and should be in C:\Program Files\LibreOffice\program 
>    * linux: should be in the path automatically
>  ```
> </details>
```lua
require('neo-img').setup({
  supported_extensions = {
    png = true,
    jpg = true,
    jpeg = true,
    tiff = true,
    tif = true,
    svg = true,
    webp = true,
    bmp = true,
    gif = true, -- static only
    docx = true,
    xlsx = true,
    pdf = true,
    pptx = true,
    odg = true,
    odp = true,
    ods = true,
    odt = true
  },

  ----- Important ones -----
  size = "80%",  -- size of the image in percent
  center = true, -- rather or not to center the image in the window
  ----- Important ones -----

  ----- Less Important -----
  auto_open = true,   -- Automatically open images when buffer is loaded
  oil_preview = true, -- changes oil preview of images too
  backend = "auto",   -- auto / kitty / iterm / sixel
  resizeMode = "Fit", -- Fit / Strech / Crop
  offset = "2x3",     -- that exmp is 2 cells offset x and 3 y.
  ttyimg = "local",   -- local / global
  ----- Less Important -----

  ----- If Spx fails in checkhealth -----
  winsize = "1920x1080" -- do printf "\x1b[14t" in your terminal to get <height>;<width>t put here <width>x<height> (only relevant if checkhealth spx query warns)
  ----- If Spx fails in checkhealth -----
})
```  
