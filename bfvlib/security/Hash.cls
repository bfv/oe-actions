 
 /*------------------------------------------------------------------------
    File        : Hash
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Oct 12 10:27:38 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using Progress.Json.ObjectModel.JsonObject.

class bfvlib.security.Hash: 
  
  method public static character Digest(algorithm as character, stringToHash as longchar):
    return string(base64-encode(message-digest(algorithm, stringToHash))).
  end method.
  
  method public static character Digest(algorithm as character, json as JsonObject):
    define variable jsonString as longchar no-undo.
    json:write(jsonString).
    return string(base64-encode(message-digest(algorithm, jsonString))).
  end method.
  
  method public static character DigestToHex(algorithm as character, stringToHash as longchar):
    return string(hex-encode(message-digest(algorithm, stringToHash))).
  end method.
  
  method public static character DigestToHex(algorithm as character, json as JsonObject):
    define variable jsonString as longchar no-undo.
    json:write(jsonString).
    return string(hex-encode(message-digest(algorithm, jsonString))).
  end method.
  
end class.