 
 /*------------------------------------------------------------------------
    File        : RequestDispatcher
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Oct 12 14:27:41 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using bfvlib.pas.IRequestDispatcher.
using OpenEdge.Net.HTTP.IHttpResponse.
using OpenEdge.Web.IWebRequest.
using OpenEdge.Web.WebResponse.
using OpenEdge.Net.HTTP.HttpHeader.
using OpenEdge.Core.String.

block-level on error undo, throw.

class bfvlib.pas.RequestDispatcher implements IRequestDispatcher: 

  method public IHttpResponse Dispatch(request as IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    
    message request:Method + ": " + string(request:GetContextValue('URI_FINAL_MATCH_GROUP')).
    
    response = new WebResponse().
        
    if (request:Method = "OPTIONS") then 
      this-object:handleOptions(request, response).
    else if (request:Method = "GET") then
      this-object:mockGetRequest(request, response).
    else 
      this-object:handleNotAllowed(request, response).
            
    return response.

  end method.
  
  method private IHttpResponse handleOptions(request as IWebRequest, response as IHttpResponse):
    
    define variable httpHeader as HttpHeader no-undo.
    
    httpHeader = new HttpHeader("Allow", "GET,OPTIONS").
    response:SetHeader(httpHeader).
    
    httpHeader = new HttpHeader("Content-Type", "text/plain").
    response:SetHeader(httpHeader).
    
    response:Entity = new String("").
    
    return response.
    
  end method.
  
  method private IHttpResponse mockGetRequest(request as IWebRequest, response as IHttpResponse):
    
    define variable httpHeader as HttpHeader no-undo.
    
    httpHeader = new HttpHeader("Content-Type", "text/plain").
    response:SetHeader(httpHeader).
    
    response:Entity = new String("GET " + string(request:GetContextValue('URI_FINAL_MATCH_GROUP'))).
    
    return response.
    
  end method.
  
  method private IHttpResponse handleNotAllowed(request as IWebRequest, response as IHttpResponse):
    
    define variable httpHeader as HttpHeader no-undo.
    
    httpHeader = new HttpHeader("Content-Type", "text/plain").
    response:SetHeader(httpHeader).
    
    response:Entity = new String("Not allowed").
    response:StatusCode = 405.
    
    return response.
        
  end method.
  
end class.
