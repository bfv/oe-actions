 
 /*------------------------------------------------------------------------
    File        : HttpHandler
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Oct 12 11:29:12 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/


block-level on error undo, throw.

using bfvlib.pas.IRequestDispatcher.
using bfvlib.pas.RequestDispatcher.
using OpenEdge.Web.IWebRequest.
using OpenEdge.Web.WebHandler.
using OpenEdge.Web.WebResponseWriter.
using OpenEdge.Net.HTTP.IHttpResponse.

class bfvlib.pas.HttpHandler inherits WebHandler:
  
  method override protected integer HandleGet(request as IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    define variable dispatcher as IRequestDispatcher no-undo.
    
    dispatcher = this-object:getDispatcher().
    response = dispatcher:Dispatch(request).
    this-object:writeResponse(response).
    
    return 0.
    
  end method.
  
  method override protected integer HandlePost(request as IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    define variable dispatcher as IRequestDispatcher no-undo.
    
    dispatcher = this-object:getDispatcher().
    response = dispatcher:Dispatch(request).
    this-object:writeResponse(response).
    
    return 0.
    
  end method.
  
  method override protected integer HandlePut(request as IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    define variable dispatcher as IRequestDispatcher no-undo.
    
    dispatcher = this-object:getDispatcher().
    response = dispatcher:Dispatch(request).
    this-object:writeResponse(response).
    
    return 0.
    
  end method.
  
  method override protected integer HandleDelete(request as IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    define variable dispatcher as IRequestDispatcher no-undo.
    
    dispatcher = this-object:getDispatcher().
    response = dispatcher:Dispatch(request).
    this-object:writeResponse(response).
    
    return 0.
    
  end method.

  method override protected integer HandleHead(request as IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    define variable dispatcher as IRequestDispatcher no-undo.
    
    dispatcher = this-object:getDispatcher().
    response = dispatcher:Dispatch(request).
    this-object:writeResponse(response).
    
    return 0.
    
  end method.
  
  
  method override protected integer HandlePatch(request as IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    define variable dispatcher as IRequestDispatcher no-undo.
    
    dispatcher = this-object:getDispatcher().
    response = dispatcher:Dispatch(request).
    this-object:writeResponse(response).
    
    return 0.
    
  end method.
  
  method override protected integer HandleOptions(request as IWebRequest):
    
    define variable response as IHttpResponse no-undo.
    define variable dispatcher as IRequestDispatcher no-undo.
    
    dispatcher = this-object:getDispatcher().
    response = dispatcher:Dispatch(request).
    this-object:writeResponse(response).
    
    return 0.
    
  end method.
  
  method override protected integer HandleNotAllowedMethod(webRequest as IWebRequest):
    undo, throw new Progress.Lang.AppError('METHOD NOT ALLOWED').
  end method.

  method override protected integer HandleNotImplemented(webRequest as IWebRequest):
    undo, throw new Progress.Lang.AppError('METHOD NOT IMPLEMENTED').
  end method.
  
  method private void writeResponse(response as IHttpResponse):
    this-object:writeResponse(response, true).
  end method.
  
  /* enable future chunk writing */
  method private WebResponseWriter writeResponse(response as IHttpResponse, directClose as logical):
    
    define variable writer as WebResponseWriter no-undo.
    
    writer = new WebResponseWriter(response).
    writer:Open().
    
    if (directClose) then
      writer:Close().
    
    return writer.
    
  end method.
  
  method private IRequestDispatcher getDispatcher():
    
    define variable dispatcher as IRequestDispatcher no-undo.
    
    dispatcher = dynamic-new "bfvlib.pas.RequestDispatcher"().
    
    return cast(dispatcher, "bfvlib.pas.RequestDispatcher").
    
  end method.
  
end class.