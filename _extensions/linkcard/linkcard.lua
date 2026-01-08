--[[
Link Card Extension for Quarto
Author: Yosuke Abe
Version: 1.0.0

This extension provides a shortcode to display rich link cards with
automatically fetched metadata (title, description, image) from URLs.

Usage:
  {{< linkcard url="https://example.com" >}}
  {{< linkcard url="https://example.com" title="Custom Title" >}}
]]

-- Load fetch-metadata module
local fetchMeta = dofile(quarto.utils.resolve_path("fetch-metadata.lua"))

--- @type function
local stringify = pandoc.utils.stringify

-- Global cache for metadata (persists across documents in same build)
-- Use module-level variables instead of _G
local LINKCARD_CACHE = {}
local LINKCARD_CACHE_HITS = 0
local LINKCARD_CACHE_MISSES = 0

--- Extract domain from URL (use module function)
--- @param url string
--- @return string
local function getDomain(url)
  return fetchMeta.getDomain(url)
end

--- Escape HTML special characters
--- @param text string
--- @return string
local function escapeHtml(text)
  if not text then return "" end
  text = text:gsub("&", "&amp;")
  text = text:gsub("<", "&lt;")
  text = text:gsub(">", "&gt;")
  text = text:gsub('"', "&quot;")
  text = text:gsub("'", "&#39;")
  return text
end

--- Generate link card HTML
--- @param metadata table
--- @param params table
--- @return string
local function generateCardHtml(metadata, params)
  local url = metadata.url or ""
  local title = metadata.title or getDomain(url)
  local description = metadata.description or ""
  local image = metadata.image or ""
  local domain = getDomain(url)

  -- Handle target parameter
  local target = params.target or "_self"
  local rel = (target == "_blank") and ' rel="noopener noreferrer"' or ''

  -- Handle no-image parameter
  local noImage = params["no-image"] == "true" or params["no-image"] == true

  -- Check if image is actually available
  local hasImage = image and image ~= "" and not noImage

  -- Escape HTML
  local escapedTitle = escapeHtml(title)
  local escapedDescription = escapeHtml(description)
  local escapedUrl = escapeHtml(url)
  local escapedDomain = escapeHtml(domain)

  -- Build aria-label
  local ariaLabel = "Link to " .. escapedTitle
  if description and description ~= "" then
    ariaLabel = ariaLabel .. ": " .. escapedDescription
  end

  -- Build CSS classes
  local cssClasses = "linkcard linkcard--default"
  if not hasImage then
    cssClasses = cssClasses .. " linkcard--no-image"
  end

  -- Start building HTML
  local html = string.format(
    '<a href="%s" class="%s" target="%s"%s aria-label="%s">',
    escapedUrl, cssClasses, target, rel, escapeHtml(ariaLabel)
  )

  -- Add image if available and not disabled
  if hasImage then
    html = html .. string.format(
      '<img src="%s" alt="Preview image for %s" class="linkcard__image" loading="lazy" />',
      escapeHtml(image), escapedTitle
    )
  end

  -- Add content section
  html = html .. '<div class="linkcard__content">'
  html = html .. string.format('<div class="linkcard__title">%s</div>', escapedTitle)

  if description and description ~= "" then
    html = html .. string.format('<div class="linkcard__description">%s</div>', escapedDescription)
  end

  html = html .. string.format('<div class="linkcard__url">%s</div>', escapedDomain)
  html = html .. '</div>' -- close linkcard__content
  html = html .. '</a>' -- close linkcard

  return html
end

--- Main shortcode function
--- @param args table
--- @param kwargs table
--- @param meta table
--- @return pandoc.RawBlock
function linkcard(args, kwargs, meta)
  -- Extract parameters
  local url = stringify(kwargs["url"] or "")

  if url == "" then
    quarto.log.warning("linkcard: 'url' parameter is required")
    return pandoc.RawBlock("html", '<div class="linkcard linkcard--error">Error: URL parameter is required</div>')
  end

  -- Extract optional parameters
  local params = {
    title = stringify(kwargs["title"] or ""),
    description = stringify(kwargs["description"] or ""),
    image = stringify(kwargs["image"] or ""),
    target = stringify(kwargs["target"] or "_self"),
    style = stringify(kwargs["style"] or "default"),
    ["no-image"] = kwargs["no-image"],
    manual = kwargs["manual"] == "true" or kwargs["manual"] == true
  }

  -- Fetch metadata from URL (Phase 4: with caching)
  local metadata
  if params.manual or (params.title ~= "" and params.description ~= "" and params.image ~= "") then
    -- Manual mode: use provided parameters only
    metadata = {
      url = url,
      title = params.title ~= "" and params.title or getDomain(url),
      description = params.description,
      image = params.image
    }
    quarto.log.output("linkcard: Using manual metadata for " .. url)
  else
    -- Automatic mode: fetch metadata from URL with caching
    if LINKCARD_CACHE[url] then
      -- Cache hit
      metadata = LINKCARD_CACHE[url]
      LINKCARD_CACHE_HITS = LINKCARD_CACHE_HITS + 1
      quarto.log.output("linkcard: Cache hit for " .. url .. " (hits: " .. LINKCARD_CACHE_HITS .. ", misses: " .. LINKCARD_CACHE_MISSES .. ")")
    else
      -- Cache miss: fetch metadata
      LINKCARD_CACHE_MISSES = LINKCARD_CACHE_MISSES + 1
      local success, result = pcall(function()
        return fetchMeta.fetchMetadata(url)
      end)

      if success and result then
        metadata = result
        -- Store in cache
        LINKCARD_CACHE[url] = metadata
        quarto.log.output("linkcard: Cache miss for " .. url .. " (hits: " .. LINKCARD_CACHE_HITS .. ", misses: " .. LINKCARD_CACHE_MISSES .. ")")
      else
        -- Error occurred during fetch
        quarto.log.warning("linkcard: Error fetching metadata for " .. url .. ": " .. tostring(result))
        metadata = {
          url = url,
          title = getDomain(url),
          description = "Failed to fetch metadata. Please check the URL or use manual parameters.",
          image = ""
        }
        -- Cache the error result too to avoid repeated failed fetches
        LINKCARD_CACHE[url] = metadata
      end
    end

    -- Override with manual parameters if provided
    if params.title ~= "" then
      metadata.title = params.title
    end
    if params.description ~= "" then
      metadata.description = params.description
    end
    if params.image ~= "" then
      metadata.image = params.image
    end
  end

  -- Generate HTML
  local html = generateCardHtml(metadata, params)

  -- Return as raw HTML block
  return pandoc.RawBlock("html", html)
end

-- Register the shortcode
return {
  ["linkcard"] = linkcard
}
