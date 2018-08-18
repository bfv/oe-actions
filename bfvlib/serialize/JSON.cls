 
 /*------------------------------------------------------------------------
    File        : JsonHelper
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Jul 20 13:18:28 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Json.ObjectModel.JsonConstruct.

block-level on error undo, throw.

class bfvlib.serialize.JSON: 
  
  method public static longchar Stringify(json as JsonConstruct):
    return Stringify(json, false).
  end method.

  method public static longchar Stringify(json as JsonConstruct, formatJson as logical):
    define variable resultString as longchar no-undo.
    json:Write(resultString, formatJson).
    return resultString.
  end method.
  
end class.