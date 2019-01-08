 
/*------------------------------------------------------------------------
   File        : WebHandlerExt
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : bronco
   Created     : Wed May 17 15:32:46 CEST 2017
   Notes       : 
 ----------------------------------------------------------------------*/


block-level on error undo, throw.

using OpenEdge.Core.String.
using OpenEdge.Net.HTTP.IHttpResponse.
using OpenEdge.Web.IWebRequest.
using OpenEdge.Web.WebHandler.
using OpenEdge.Web.WebResponse.
using OpenEdge.Web.WebResponseWriter.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.JsonArray.
using OpenEdge.Net.HTTP.HttpHeader.
using OpenEdge.Web.WebRequest.
using OpenEdge.Net.URI.
using OpenEdge.Core.Collections.StringStringMap.
using OpenEdge.Net.HTTP.Cookie.
using bfvlib.pas.WebHandlerExt.
using bfvlib.net.HttpHelper.

class bfvlib.pas.WebHandlerExt inherits WebHandler: 
  
  define private property queryParameters as StringStringMap no-undo get. set.
  
  constructor public WebHandlerExt():
    
  end.
		
  method override protected integer HandleGet(request as IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    define variable writer as OpenEdge.Web.WebResponseWriter  no-undo.               
    define variable endpoint as character no-undo.
    
    this-object:extractHttpInfo(request).
    
    endpoint = request:GetContextValue('URI_FINAL_MATCH_GROUP').
    
    case endpoint:
      
      when '/' then 
        response = this-object:processHome(request).
        
      when '/get' then
        response = this-object:processGet(request).
      
      when '/cookie' then
        response = this-object:processCookie(request, false).
      
      when '/persistentcookie' then
        response = this-object:processCookie(request, true).
      
      when '/customer' then
        response = this-object:processCustomer(request, false).
             
      when '/customercache' then
        response = this-object:processCustomer(request, true).
        
      otherwise do:
        response = this-object:processNotAllowed(request).  
      end.
        
    end case.
    
        
    writer = new WebResponseWriter(response).
    writer:Open().
    writer:Close().
        
    return 0.
    
  end method. 
  
  
  method override protected integer HandlePost(request as IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    define variable writer as OpenEdge.Web.WebResponseWriter  no-undo.               
    define variable endpoint as character no-undo.
    
    endpoint = request:GetContextValue('URI_FINAL_MATCH_GROUP').
    
    case endpoint:
      
      when '/' then 
        response = this-object:processHome(request).
        
      when '/post' then
        response = this-object:processGet(request).
      
      otherwise do:
        response = this-object:processNotAllowed(request).  
      end.
        
    end case.
    
        
    writer = new WebResponseWriter(response).
    writer:Open().
    writer:Close().
        
    return 0.
    
  end method. 

  
  method override protected integer HandleNotAllowedMethod( webRequest as OpenEdge.Web.IWebRequest ):
    undo, throw new Progress.Lang.AppError('METHOD NOT IMPLEMENTED').
  end method.


  method override protected integer HandleNotImplemented(webRequest as OpenEdge.Web.IWebRequest ):
    undo, throw new Progress.Lang.AppError('METHOD NOT IMPLEMENTED').
  end method.
  
  
  method private WebHandlerExt addHeaders(request as IWebRequest, json as JsonObject):
    
    define variable headerJson as JsonObject no-undo.
    define variable headers as HttpHeader extent no-undo.
    define variable currentHeader as HttpHeader no-undo.
    define variable headerCount as integer no-undo.
    define variable i as integer no-undo.
    
    headerJson = new JsonObject().
    
    headerCount = request:GetHeaders(headers).
    do i = 1 to headerCount:
      currentHeader = headers[i].
      headerJson:Add(HttpHelper:NormalizeHeaderName(currentHeader:Name), currentHeader:Value).
    end.
    
    json:Add('headers', headerJson).
    
    return this-object.
    
  end method.
  
  
  method private WebHandlerExt addQueryParameters(request as IWebRequest, json as JsonObject):
    
    define variable parameterJson as JsonObject no-undo.
    define variable parameterCount as integer no-undo.
    define variable i as integer no-undo.
    define variable parameters as character no-undo.
    define variable currentEntry as character no-undo.
    define variable parameterName as character no-undo.
    define variable parameterValue as character no-undo.
    
    parameterJson = new JsonObject().
    parameters = request:GetContextValue('QUERY_STRING').
    
    parameterCount = num-entries(parameters, '&').
    do i = 1 to parameterCount:
      currentEntry = entry(i, parameters, '&').
      parameterName = entry(1, currentEntry, '=').
      parameterValue = this-object:urlDecode(entry(2, currentEntry, '=')).
      parameterJson:Add(parameterName, parameterValue).
    end.
            
    json:Add('args', parameterJson).
    
    return this-object.
    
  end method.
  
  
  method private WebHandlerExt addPathParameters(request as IWebRequest, json as JsonObject):
    
    define variable parameterJson as JsonObject no-undo.
    define variable parameterCount as integer no-undo.
    define variable i as integer no-undo.
    define variable parameters as character no-undo.
    define variable parameterName as character no-undo.
    define variable parameterValue as character no-undo.
    
    parameterJson = new JsonObject().
    parameters = request:PathParameterNames.
    
    parameterCount = num-entries(parameters).
    do i = 1 to parameterCount:
      parameterName = entry(i, parameters).
      parameterValue = request:GetPathParameter(parameterName).
      parameterJson:Add(parameterName, parameterValue).
    end.
            
    json:Add('pathparameters', parameterJson).
    
    return this-object.
    
  end method.


  method private WebHandlerExt addContext(request as IWebRequest, json as JsonObject):
    
    define variable parameterJson as JsonObject no-undo.
    define variable parameterCount as integer no-undo.
    define variable i as integer no-undo.
    define variable parameters as character no-undo.
    define variable parameterName as character no-undo.
    define variable parameterValue as character no-undo.
    
    parameterJson = new JsonObject().
    parameters = request:ContextNames.
    
    parameterCount = num-entries(parameters).
    do i = 1 to parameterCount:
      parameterName = entry(i, parameters).
      parameterValue = request:GetContextValue(parameterName).
      parameterJson:Add(parameterName, parameterValue).
    end.
            
    json:Add('context', parameterJson).
    
    return this-object.
    
  end method.


  method private WebHandlerExt addStandardHttp(request as IWebRequest, json as JsonObject):
    
    json:Add('origin', request:RemoteHost).        
    json:Add('url', request:URI:BaseURI + request:URI:Path).    
    
    return this-object.

  end method.
  
  method private IHttpResponse processCookie(request as IWebRequest, persistentCookie as logical):
    
    define variable response as IHttpResponse no-undo.
    define variable cookie as Cookie no-undo.
    define variable path as character no-undo.
    define variable maxAge as integer no-undo.
    define variable urlMaxage as character no-undo.
    
    response = new WebResponse().
    response:ContentType = 'text/plain'.
    response:Entity = new String('you got a cookie').
    
    path = request:GetContextValue('SERVLET_APPLICATION_URL') + request:GetContextValue('URI_FINAL_MATCH_GROUP').   
       
    if (persistentCookie) then do:
      maxAge = 600.
      urlMaxage = this-object:queryParameters:Get('maxage').
      if (urlMaxage > '') then
        maxAge = integer(urlMaxage) no-error.
        
      cookie = new Cookie('test', 'localhost', path, 'succeeded', maxAge, ?, false, true, ?).
      
    end.
    else 
      cookie = new Cookie('test', 'localhost', path, 'succeeded').
    
    response:SetCookie(cookie).
      
    return response.
    
  end method.
  
  
  method private IHttpResponse processCustomer(request as IWebRequest, cached as logical):
    
    define variable response as IHttpResponse no-undo.
    define variable json as JsonArray no-undo.
    define variable cacheHeader as HttpHeader no-undo.
    
    response = new WebResponse().
    
    if (not connected('sports2000')) then do:
      response:ContentType = 'text/plain'.
      response:Entity = new String('sports2000 not connected').
    end.
    else do:
      json = this-object:customersToJson().
      response:ContentType = 'application/json'.
      response:Entity = json.
      if (cached) then do:
        cacheHeader = new HttpHeader('Cache-Control', 'max-age=60').
        response:SetHeader(cacheHeader).
      end.   
    end.
    
    return response.
    
  end method.
  
  
  method private IHttpResponse processGet(request as IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    define variable json as JsonObject no-undo.
    define variable oeJson as JsonObject no-undo.
    
    response = new WebResponse().
    response:ContentType = 'application/json'.
    
    json = new JsonObject().
    this-object
        :addQueryParameters(request, json)
        :addHeaders(request, json)
        :addStandardHttp(request, json)
        .
    
    oeJson = new JsonObject().
    
    if (this-object:queryParameters:Get('openedge') = 'true') then do:
      this-object
        :addContext(request, oeJson)
        :addPathParameters(request, oeJson)
        .
    
      json:Add('openedge', oeJson).
      
    end.
    
    response:Entity = json.
    
    return response.
    
  end method.


  method private IHttpResponse processHome(request as IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    define variable htmlContent as longchar no-undo.
    define variable htmlFile as character no-undo.
    
    htmlFile = search('home.html').
    copy-lob file htmlFile to htmlContent.
    
    response = new WebResponse().
    response:Entity = new String(htmlContent).
    response:ContentType = 'text/html'.    
    
    return response.

  end method.
  
  
  method private IHttpResponse processNotAllowed(request as IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    
    response = new WebResponse().
    
    response:StatusCode = 405.
    response:StatusReason = 'Method Not Allowed'.
    response:ContentType = 'text/html'.
    response:Entity = new String(
      '405: ' + request:Method + ' of ' + quoter(request:GetContextValue('URI_FINAL_MATCH_GROUP')) + ' not allowed'
    ).
    
    return response.
    
  end method.
  
  
  method private character urlDecode(urlEntry as character):
    
    // for now just the spaces
    urlEntry = replace(urlEntry, '%20', ' ').
    
    return urlEntry.
    
  end method.
  
  
  method private void reset():
    delete object this-object:queryParameters no-error.  
  end method.
  
  
  method private void extractHttpInfo(request as IWebRequest):
    
    define variable parameters as character no-undo.
    define variable parameterCount as integer no-undo.
    define variable i as integer no-undo.
    define variable currentEntry as character no-undo.
    define variable parameterName as character no-undo.
    define variable parameterValue as character no-undo.
    
    this-object:queryParameters = new StringStringMap().
  
    parameters = request:GetContextValue('QUERY_STRING').
    
    parameterCount = num-entries(parameters, '&').
    do i = 1 to parameterCount:
      currentEntry = entry(i, parameters, '&').
      parameterName = entry(1, currentEntry, '=').
      parameterValue = this-object:urlDecode(entry(2, currentEntry, '=')).
      this-object:queryParameters:Put(parameterName, parameterValue).
    end.
        
  end method.
  
  
  method private JsonArray customersToJson():
    
    define variable json as JsonArray no-undo.
    define variable recordJson as JsonObject no-undo.
    
    define variable queryHandle as handle no-undo.
    define variable bufferHandle as handle no-undo.
    define variable i as integer no-undo.
    
    json = new JsonArray().
    
    create query queryHandle.
    create buffer bufferHandle for table 'customer'.
    queryHandle:set-buffers(bufferHandle).
    queryHandle:query-prepare('for each customer').
    queryHandle:query-open().
    
    queryHandle:get-first().
    do while (not queryHandle:query-off-end):
      recordJson = new JsonObject().
      do i = 1 to bufferHandle:num-fields:
        recordJson:Add(bufferHandle:buffer-field(i):name, bufferHandle:buffer-field(i):buffer-value).
      end.
      json:Add(recordJson).
      queryHandle:get-next().  
    end.
    
    return json.
    
    finally:
       delete object queryHandle no-error.
       delete object bufferHandle no-error.    
    end finally.
    
  end method.
    
end class.
    