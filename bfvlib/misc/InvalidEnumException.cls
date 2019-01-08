/*------------------------------------------------------------------------
  File        : InvalidEnumException
  Purpose     : 
  Syntax      : 
  Description : 
  Author(s)   : 
  Created     : 
  Notes       : 
----------------------------------------------------------------------*/

using Progress.Lang.AppError.

block-level on error undo, throw.

class bfvlib.misc.InvalidEnumException inherits AppError: 
    
  define public property Value as character no-undo get. private set.
  define public property EnumType as character no-undo get. private set.
    
  constructor public InvalidEnumException (enumValue as character):
    super (input substitute("Enumeration has an invalid value: &1", enumValue), 0).
    this-object:Value = enumValue.
  end constructor.

  constructor public InvalidEnumException (enumValue as character, enumType as character):
    super (input substitute("Enumeration of type '&2' has an invalid name or value: &1", enumValue, enumType), 0).
    this-object:Value = enumValue.
    this-object:EnumType = enumType.
  end constructor.

end class.
