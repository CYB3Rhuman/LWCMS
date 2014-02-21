uri = ngx.var.uri;

if uri:match(" ") or uri:match("%u") then       -- if space or uppercase found in uri
  uri = uri:gsub("% ", "_")                     -- replace spaces it with _
  uri = uri:gsub("%u", string.lower)            -- to lowercase
  return ngx.redirect(uri, 301)                 -- and redirect
end

s = uri:gsub("%/", " ")
uriparts = {}
for w in s:gmatch("%S+") do table.insert(uriparts, w) end

pages = {
  ["123"] = "\t\t<p>first page</p>\n",
  ["my_page"] = "\t\t<p>second page</p>\n",
  ["wtf"] = "\t\t<p>third page</p>\n"
}

if     #uriparts == 1 then
  title = 'index page'
  content = "\t\t<p>Here is an <a href=\"app/page\">example app</a>.</p>\n"
elseif uriparts[2] == 'page' and #uriparts == 2 then
  title = 'List of pages'
  content = "\t\t<p>Here is the list</p>\n"
  for key,value in pairs(pages) do content = content .. '\t\t<a href="page/' .. key .. '">' .. value .. "</a>\n" end
elseif uriparts[2] == 'page' and #uriparts == 3 then
  if pages[uriparts[3]] ~= nil then
    title = 'Page: ' .. uriparts[3]
    content = pages[uriparts[3]] .. "\t\t<a href=\"..\">Go back</a>\n"
  else
    ngx.exit(ngx.HTTP_NOT_FOUND)
  end
else
  ngx.exit(ngx.HTTP_NOT_FOUND)
end

function genpage (params)
  ngx.header.content_type = 'text/html'
  ngx.say([[
<!DOCTYPE html>
<html>
        <head>
                <title>]] .. params["title"] .. [[</title>
                <link rel="stylesheet" type="text/css" href="/default.css">
        </head>
        <body>
                <h1>]] .. params["title"] .. [[</h1>
]] .. params["content"] .. [[
        </body>
</html>

<!-- powered by OpenResty, this page was generated with Lua -->
]])
end

genpage({
  ["title"] = title,
  ["content"] = content
})
