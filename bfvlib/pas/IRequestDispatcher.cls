
/*------------------------------------------------------------------------
    File        : IRequestDispatcher
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Oct 12 14:12:10 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.Net.HTTP.IHttpResponse.
using OpenEdge.Web.IWebRequest.

interface bfvlib.pas.IRequestDispatcher:  
  
  method public IHttpResponse Dispatch(request as IWebRequest).
          
end interface.