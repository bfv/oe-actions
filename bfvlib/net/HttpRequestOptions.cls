 
 /*------------------------------------------------------------------------
    File        : HttpRequestOptions
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Mon Aug 13 09:34:59 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.Core.Collections.StringStringMap.

block-level on error undo, throw.

class bfvlib.net.HttpRequestOptions: 
  
  define variable httpLinefeed as character no-undo.
  
  define public property Accept as character no-undo get. set.
  define public property ContentType as character no-undo get. set.
  
  define public property Headers as StringStringMap no-undo get. private set.
  define public property QueryParameters as StringStringMap no-undo get. private set.
  
  define public property ViaProxy as character no-undo get. set.
  
  constructor public HttpRequestOptions():
    this-object:Headers = new StringStringMap().  
    this-object:QueryParameters = new StringStringMap().  
  end. 
  
  method public void AddHeader(headerName as character, headerValue as longchar):
    this-object:Headers:Put(headerName, headerValue).
  end method.
  
  method public void AddQueryParameter(parameterName as character, parameterValue as longchar):
    this-object:queryParameters:Put(parameterName, parameterValue).
  end method.  
   
end class.