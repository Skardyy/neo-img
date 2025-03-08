local M = {}

--- @class NeoImg.Config
--- @field supported_extensions table<string, boolean> Supported file extensions
--- @field size string Size of the image in percent (e.g., "80%")
--- @field center boolean Whether to center the image in the window
--- @field auto_open boolean Auto-open images on buffer load
--- @field oil_preview boolean Enable oil.nvim preview for images
--- @field backend "auto"|"kitty"|"iterm"|"sixel" Backend for rendering
--- @field resizeMode "Fit"|"Stretch"|"Crop" Resize mode for images
--- @field offset string Offset for positioning (e.g., "0x3")
--- @field ttyimg "local"|"global" which ttyimg is preferred
--- @field winsize string the win size for fallback if spx fails in checkhealth
--- @field bin_path? string Path to the ttyimg binary (populated at runtime)
--- @field os? string the OS of the machine (populated at runtime)
--- @field window_size? {spx: NeoImg.Size, sc: NeoImg.Size} window size fallbacks in px and cells (populated at runtime)
--- @field ttyimg_version? string the version of ttyimg to scope to (populated at runtime)

--- Default configuration
---@type NeoImg.Config
M.defaults = {
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
  winsize =
  "1920x1080" -- do printf "\x1b[14t" in your terminal to get <heigt;width t> put here <width>x<height> (only relevant if checkhealth spx query warns)
  ----- If Spx fails in checkhealth -----
}

local config = M.defaults

--- Get the directory where ttyimg is installed
---@return string bin_dir Path to the ttyimg binary directory
function M.get_bin_dir()
  local bin_name = "ttyimg"
  local config_dir = debug.getinfo(1).source:sub(2)
  local _, end_idx = config_dir:find("neo%-img")
  return config_dir:sub(1, end_idx) .. "/" .. bin_name
end

--- Get the path to the ttyimg binary
---@return string bin_path The resolved binary path or an empty string if not found
function M.get_bin_path()
  local bin_dir = M.get_bin_dir()
  local bin_path = bin_dir .. "/ttyimg"
  local fallback_bin = nil

  local local_bin = vim.fn.exepath(bin_path)
  if local_bin ~= "" then
    if config.ttyimg == "local" then
      return local_bin
    else
      fallback_bin = local_bin
    end
  end

  local global_binary = vim.fn.exepath("ttyimg")
  if global_binary ~= "" then
    if config.ttyimg == "global" then
      return global_binary
    else
      if fallback_bin == nil then
        fallback_bin = global_binary
      end
    end
  end
  if fallback_bin ~= nil then
    return fallback_bin
  end
  print("couldn't find ttyimg, please call :NeoImg Install")
  return ""
end

--- Set the bin_path in config
function M.set_bin_path()
  config.bin_path = M.get_bin_path()
end

--- Setup function to initialize the configuration
---@param opts? NeoImg.Config Custom user options
function M.setup(opts)
  config.ttyimg_version = "1.0.5"
  config.bin_path = M.get_bin_path()
  local new_opts = opts and M.validate_config(opts) or {}
  config = vim.tbl_deep_extend('force', M.defaults, new_opts)
end

--- Get the current configuration
---@return NeoImg.Config config The current configuration table
function M.get()
  return config
end

--- Validates and corrects a given NeoImg.Config table.
---@param opts NeoImg.Config The configuration table to validate.
---@return NeoImg.Config opts The validated and corrected configuration.
function M.validate_config(opts)
  local defaults = M.defaults

  if type(opts) ~= "table" then
    return vim.deepcopy(defaults)
  end

  local function is_valid_percentage(value)
    return type(value) == "string" and value:match("^%d+%%$")
  end

  local function is_valid_boolean(value)
    return type(value) == "boolean"
  end

  local function is_valid_backend(value)
    if type(value) == "string" then
      local value2 = string.lower(value)
      return value2 == "auto" or value2 == "kitty" or value2 == "iterm" or value2 == "sixel"
    end
    return false
  end

  local function is_valid_resize_mode(value)
    if type(value) == "string" then
      local value2 = string.lower(value)
      return value2 == "fit" or value2 == "stretch" or value2 == "crop"
    end
    return false
  end

  local function is_valid_offset(value)
    return type(value) == "string" and value:match("^%d+x%d+$")
  end

  local function is_valid_ttyimg(value)
    return value == "global" or value == "local"
  end

  --- @type NeoImg.Config
  local validated_config = {
    supported_extensions = type(opts.supported_extensions) == "table" and opts.supported_extensions or
        defaults.supported_extensions,
    size = is_valid_percentage(opts.size) and opts.size or defaults.size,
    center = is_valid_boolean(opts.center) and opts.center or defaults.center,
    auto_open = is_valid_boolean(opts.auto_open) and opts.auto_open or defaults.auto_open,
    oil_preview = is_valid_boolean(opts.oil_preview) and opts.oil_preview or defaults.oil_preview,
    backend = is_valid_backend(opts.backend) and opts.backend or defaults.backend,
    resizeMode = is_valid_resize_mode(opts.resizeMode) and opts.resizeMode or defaults.resizeMode,
    offset = is_valid_offset(opts.offset) and opts.offset or defaults.offset,
    ttyimg = is_valid_ttyimg(opts.ttyimg) and opts.ttyimg or defaults.ttyimg,
    winsize = is_valid_offset(opts.winsize) and opts.winsize or defaults.winsize,

    bin_path = type(opts.bin_path) == "string" and opts.bin_path or nil,
    os = type(opts.os) == "string" and opts.os or nil,
    window_size = type(opts.window_size) == "table" and opts.window_size or nil,
  }

  return validated_config
end

return M
