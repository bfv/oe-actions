 
 /*------------------------------------------------------------------------
    File        : Base64
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Thu Oct 04 18:03:15 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

class bfvlib.misc.Base64: 
  
  /** this method prevents OE from adding a \0 to the end of the base64 result.
   *  This way the result is identical to other implementation (JS, C#, etc)
   */ 
  method public static character EncodeString(sourceString as character):
    
    define variable mptr as memptr no-undo.
    define variable resultString as longchar no-undo.
    define variable stringSize as integer no-undo.
    
    stringSize = length(sourceString, "raw").
    set-size(mptr) = stringSize.
    put-string(mptr, 1, stringSize) = sourceString.
    
    resultString = base64-encode(mptr).
    
    return string(resultString).
    
    finally:
      set-size(mptr) = 0.
    end.
    
  end method.
  
end class.