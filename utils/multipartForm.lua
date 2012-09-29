-------------------------------------------------
--
-- class_MultipartFormData.lua
-- Author: Brill Pappin, Sixgreen Labs Inc.
--
-- Generates multipart form-data for http POST calls that require it.
--
-- Caution: 
-- In Corona SDK you have to set a string as the body, which means that the 
-- entire POST needs to be encoded as a string, including any files you attach.
-- Needless to say, if the file you are sending is large, it''s going to use 
-- up all your available memory!
--
-- Example:
--[[
local MultipartFormData = require("class_MultipartFormData")
 
local multipart = MultipartFormData.new()
multipart:addHeader("Customer-Header", "Custom Header Value")
multipart:addField("myFieldName","myFieldValue")
multipart:addField("banana","yellow")
multipart:addFile("myfile", system.pathForFile( "myfile.jpg", system.DocumentsDirectory ), "image/jpeg", "myfile.jpg")
 
local params = {}
params.body = multipart:getBody() -- Must call getBody() first!
params.headers = multipart:getHeaders() -- Headers not valid until getBody() is called.
 
local function networkListener( event )
        if ( event.isError ) then
                print( "Network error!")
        else
                print ( "RESPONSE: " .. event.response )
        end
end
 
network.request( "http://www.example.com", "POST", networkListener, params)
 
]]
 
-------------------------------------------------
local crypto = require("crypto")
local ltn12 = require("ltn12")
local mime = require("mime")
 
MultipartFormData = {}
local MultipartFormData_mt = { __index = MultipartFormData }
 
function MultipartFormData.new()  -- The constructor
        local newBoundary = "MPFD-"..crypto.digest( crypto.sha1, "MultipartFormData"..tostring(object)..tostring(os.time())..tostring(os.clock()), false )
        local object = { 
                isClass = true,
                boundary = newBoundary,
                headers = {},
                elements = {},
        }
  
        object.headers["Content-Type"] = ""
        object.headers["Content-Length"] = ""
        object.headers["Accept"] = "*/*"
        object.headers["Accept-Encoding"] = "gzip" 
        object.headers["Accept-Language"] = "en-us"
        object.headers["connection"] = "keep-alive" 
        
        
  
  return setmetatable( object, MultipartFormData_mt )
end
 
function MultipartFormData:getBody()
        local src = {}
        
        -- always need two CRLF's as the beginning
        --table.insert(src, ltn12.source.chain(ltn12.source.string("\n"), mime.normalize()))
        
        for i = 1, #self.elements do
                local el = self.elements[i]
                if el then
                        if el.intent == "field" then
                                local elData = {
                                        "--"..self.boundary.."\r\n",
                                        "content-disposition: form-data; name=\"",
                                        el.name,
                                        "\"\r\n\r\n",
                                        el.value,
                                        --"\r\n"
                                }
                                
                                local elBody = table.concat(elData)
                                table.insert(src, ltn12.source.chain(ltn12.source.string(elBody), mime.normalize()))
                        elseif el.intent == "file" then
                                local elData = {
                                        "--"..self.boundary.."\r\n",
                                        "content-disposition: form-data; name=\"",
                                        el.name,
                                        "\"; filename=\"",
                                        el.filename,
                                        "\"\r\n",
                                        "Content-Type: ",
                                        el.mimetype,
                                        "\r\n\r\n",
                                }
                                local elHeader = table.concat(elData)
                                
                                local elFile = io.open( el.path, "rb" )
                                assert(elFile)
                                local fileSource = ltn12.source.cat(
                                                        ltn12.source.chain(ltn12.source.string(elHeader), mime.normalize()),
                                                        ltn12.source.chain(
                                                                        ltn12.source.file(elFile), 
                                                                        ltn12.filter.chain(
                                                                                mime.encode(el.encoding), 
                                                                                mime.wrap()
                                                                        )
                                                                )
                                                )
                                
                                table.insert(src, fileSource)
                        end
                end
        end
        
        -- always need to end the body
        table.insert(src, ltn12.source.chain(ltn12.source.string("\r\n--"..self.boundary.."--"), mime.normalize()))
        
        local source = ltn12.source.empty()
        for i = 1, #src do
                source = ltn12.source.cat(source, src[i])
        end
        
        local sink, data = ltn12.sink.table()
        ltn12.pump.all(source,sink)     
        local body = table.concat(data)
        
        -- update the headers we now know how to add based on the multipart data we just generated.
        self.headers["Content-Type"] = "multipart/form-data; boundary="..self.boundary
        self.headers["Content-Length"] = string.len(body) -- must be total length of body
        
        return body
end
 
function MultipartFormData:getHeaders()
        assert(self.headers["Content-Type"])
        assert(self.headers["Content-Length"])
        return self.headers
end
 
function MultipartFormData:addHeader(name, value)
        self.headers[name] = value
end
 
function MultipartFormData:setBoundry(string)
        self.boundary = string
end
 
function MultipartFormData:addField(name, value)
        self:add("field", name, value)
end
 
function MultipartFormData:addFile(name, path, mimeType, remoteFileName)
        -- For Corona, we can really only use base64 as a simple binary 
        -- won't work with their network.request method.
        local element = {intent="file", name=name, path=path, 
                mimetype = mimeType, filename = remoteFileName, encoding = "base64"}
        self:addElement(element)
end
 
function MultipartFormData:add(intent, name, value)
        local element = {intent=intent, name=name, value=value}
        self:addElement(element)
end
 
function MultipartFormData:addElement(element)
        table.insert(self.elements, element)
end
 
function MultipartFormData:toString()
        return "MultipartFormData [elementCount:"..tostring(#self.elements)..", headerCount:"..tostring(#self.headers).."]" 
end
 
return MultipartFormData