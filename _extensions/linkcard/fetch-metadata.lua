--[[
fetch-metadata.lua
Metadata fetching and HTML parsing module for Link Card extension

This module handles:
- HTTP requests using pandoc.mediabag.fetch()
- HTML parsing for Open Graph, Twitter Card, and standard meta tags
- Graceful error handling and fallbacks
]]

local M = {}

--- Extract domain from URL
--- @param url string
--- @return string
function M.getDomain(url)
  local domain = url:match("^https?://([^/]+)")
  if domain then
    domain = domain:gsub("^www%.", "")
  end
  return domain or url
end

--- Extract meta tag content from HTML
--- @param html string
--- @param property string The property name (e.g., "og:title")
--- @return string|nil
local function extractMetaProperty(html, property)
  -- Try property="..." content="..."
  local pattern = '<meta[^>]+property=["\']' .. property:gsub(":", "%%:") .. '["\'][^>]+content=["\']([^"\']+)["\']'
  local value = html:match(pattern)

  if not value then
    -- Try reversed: content="..." property="..."
    pattern = '<meta[^>]+content=["\']([^"\']+)["\'][^>]+property=["\']' .. property:gsub(":", "%%:") .. '["\']'
    value = html:match(pattern)
  end

  return value
end

--- Extract meta tag content from HTML (name attribute)
--- @param html string
--- @param name string The name attribute (e.g., "description")
--- @return string|nil
local function extractMetaName(html, name)
  -- Try name="..." content="..."
  local pattern = '<meta[^>]+name=["\']' .. name .. '["\'][^>]+content=["\']([^"\']+)["\']'
  local value = html:match(pattern)

  if not value then
    -- Try reversed: content="..." name="..."
    pattern = '<meta[^>]+content=["\']([^"\']+)["\'][^>]+name=["\']' .. name .. '["\']'
    value = html:match(pattern)
  end

  return value
end

--- Extract title from HTML
--- @param html string
--- @return string|nil
local function extractTitle(html)
  local title = html:match('<title[^>]*>%s*([^<]+)%s*</title>')
  if title then
    -- Decode HTML entities (basic)
    title = title:gsub("&amp;", "&")
    title = title:gsub("&lt;", "<")
    title = title:gsub("&gt;", ">")
    title = title:gsub("&quot;", '"')
    title = title:gsub("&#39;", "'")
    -- Remove extra whitespace
    title = title:gsub("%s+", " ")
    title = title:match("^%s*(.-)%s*$")
  end
  return title
end

--- Decode HTML entities
--- @param text string
--- @return string
local function decodeHtmlEntities(text)
  if not text then return nil end
  text = text:gsub("&amp;", "&")
  text = text:gsub("&lt;", "<")
  text = text:gsub("&gt;", ">")
  text = text:gsub("&quot;", '"')
  text = text:gsub("&#39;", "'")
  text = text:gsub("&#x27;", "'")
  text = text:gsub("&nbsp;", " ")
  return text
end

--- Fetch metadata from internal Quarto document
--- @param path string Relative path from project root
--- @return table Metadata table
local function fetchInternalMetadata(path)
  local metadata = {
    url = path,
    title = nil,
    description = nil,
    image = nil
  }

  -- パスの正規化（先頭の/を削除）
  local normalizedPath = path:gsub("^/", "")

  -- プロジェクトディレクトリを取得（環境変数や代替手段も試す）
  local projectDir = quarto.project.directory or 
                     os.getenv("QUARTO_PROJECT_DIR") or 
                     pandoc.system.get_working_directory()

  -- QMDファイルの絶対パスを構築
  local filePath = projectDir .. "/" .. normalizedPath

  quarto.log.output("linkcard: Attempting to read internal file: " .. filePath)

  -- ファイルが存在するか確認
  local file = io.open(filePath, "r")
  if not file then
    quarto.log.warning("linkcard: Internal file not found: " .. filePath)
    metadata.title = "File not found"
    metadata.description = "The file " .. path .. " does not exist"
    return metadata
  end

  -- ファイル内容を読み込む
  local content = file:read("*all")
  file:close()

  -- YAML frontmatterを抽出（--- で囲まれた部分）
  local yamlContent = content:match("^%-%-%-\n(.-)\n%-%-%-")

  if not yamlContent then
    quarto.log.warning("linkcard: No YAML frontmatter found in " .. path)
    metadata.title = path
    return metadata
  end

  -- YAMLからtitle, description, imageを抽出
  -- titleは引用符で囲まれている場合と囲まれていない場合がある
  local title = yamlContent:match("title:%s*\"([^\"]+)\"") or
                yamlContent:match("title:%s*'([^']+)'") or
                yamlContent:match("title:%s*([^\n]+)")
  if title then
    metadata.title = title:gsub("^%s+", ""):gsub("%s+$", "")  -- trim
  end

  -- descriptionは複数行の可能性があるため特別な処理
  -- description: |形式の場合
  local descLine = yamlContent:match("description:%s*|%s*\n%s*([^\n]+)")
  if not descLine then
    -- 通常の形式
    descLine = yamlContent:match("description:%s*\"([^\"]+)\"") or
               yamlContent:match("description:%s*'([^']+)'") or
               yamlContent:match("description:%s*([^\n]+)")
  end
  if descLine then
    metadata.description = descLine:gsub("^%s+", ""):gsub("%s+$", "")  -- trim
  end

  -- 画像パスを抽出（相対パス）
  local imagePath = yamlContent:match("image:%s*([^\n]+)")
  if imagePath then
    imagePath = imagePath:gsub("^%s+", ""):gsub("%s+$", "")  -- trim
  end

  -- サイトURLを取得（_quarto.ymlから）
  local siteUrl = "https://yo5uke.com"  -- デフォルト値
  if quarto.doc.config_file and quarto.doc.config_file.website and quarto.doc.config_file.website["site-url"] then
    siteUrl = quarto.doc.config_file.website["site-url"]
  end

  -- 相対パスを絶対URLに変換
  local dirPath = normalizedPath:match("(.*/)")
  if dirPath then
    -- 画像URLの構築
    if imagePath and imagePath ~= "" then
      metadata.image = siteUrl .. "/" .. dirPath .. imagePath
    end

    -- QMD拡張子をHTMLに変換してURLを構築
    local htmlPath = normalizedPath:gsub("%.qmd$", ".html"):gsub("/index%.html$", "/")
    metadata.url = siteUrl .. "/" .. htmlPath
  else
    -- ディレクトリパスがない場合（ルート直下のファイル）
    local htmlPath = normalizedPath:gsub("%.qmd$", ".html")
    metadata.url = siteUrl .. "/" .. htmlPath
    if imagePath and imagePath ~= "" then
      metadata.image = siteUrl .. "/" .. imagePath
    end
  end

  quarto.log.output("linkcard: Fetched internal metadata for " .. path)
  quarto.log.output("  Title: " .. (metadata.title or "N/A"))
  quarto.log.output("  Description: " .. (metadata.description and metadata.description:sub(1, 50) or "N/A"))
  quarto.log.output("  Image: " .. (metadata.image or "N/A"))
  quarto.log.output("  Final URL: " .. (metadata.url or "N/A"))

  return metadata
end

--- Fetch metadata from external URL
--- @param url string
--- @return table Metadata table
local function fetchExternalMetadata(url)
  local metadata = {
    url = url,
    title = nil,
    description = nil,
    image = nil
  }

  -- Try to fetch URL content
  local mt, contents = pandoc.mediabag.fetch(url)

  if not contents or contents == "" then
    quarto.log.warning("linkcard: Failed to fetch URL: " .. url)
    metadata.title = M.getDomain(url)
    metadata.description = "Failed to fetch metadata from this URL"
    return metadata
  end

  -- Convert contents to string if needed
  local html = tostring(contents)

  -- Extract Open Graph metadata (first priority)
  local ogTitle = extractMetaProperty(html, "og:title")
  local ogDescription = extractMetaProperty(html, "og:description")
  local ogImage = extractMetaProperty(html, "og:image")

  -- Extract Twitter Card metadata (second priority)
  local twitterTitle = extractMetaProperty(html, "twitter:title")
  local twitterDescription = extractMetaProperty(html, "twitter:description")
  local twitterImage = extractMetaProperty(html, "twitter:image")

  -- Extract standard HTML metadata (third priority)
  local htmlTitle = extractTitle(html)
  local htmlDescription = extractMetaName(html, "description")

  -- Set metadata with fallback chain
  metadata.title = ogTitle or twitterTitle or htmlTitle or M.getDomain(url)
  metadata.description = ogDescription or twitterDescription or htmlDescription or ""
  metadata.image = ogImage or twitterImage or ""

  -- Decode HTML entities
  metadata.title = decodeHtmlEntities(metadata.title)
  metadata.description = decodeHtmlEntities(metadata.description)

  -- Handle relative image URLs
  if metadata.image and metadata.image ~= "" then
    if metadata.image:match("^//") then
      -- Protocol-relative URL
      metadata.image = "https:" .. metadata.image
    elseif metadata.image:match("^/") then
      -- Absolute path
      local protocol, domain = url:match("^(https?://)([^/]+)")
      if protocol and domain then
        metadata.image = protocol .. domain .. metadata.image
      end
    elseif not metadata.image:match("^https?://") then
      -- Relative path
      local baseUrl = url:match("^(https?://[^/]+/)")
      if baseUrl then
        metadata.image = baseUrl .. metadata.image
      end
    end
  end

  quarto.log.output("linkcard: Fetched metadata for " .. url)
  quarto.log.output("  Title: " .. (metadata.title or "N/A"))
  quarto.log.output("  Description: " .. (metadata.description and metadata.description:sub(1, 50) or "N/A"))
  quarto.log.output("  Image: " .. (metadata.image or "N/A"))

  return metadata
end

--- Main function to fetch metadata from URL (internal or external)
--- @param url string URL or relative path
--- @return table Metadata table
function M.fetchMetadata(url)
  -- 外部URLかどうかを判定
  if url:match("^https?://") then
    -- 既存の外部URL処理
    return fetchExternalMetadata(url)
  else
    -- 新しい内部リンク処理
    return fetchInternalMetadata(url)
  end
end

return M
