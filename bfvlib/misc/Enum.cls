/*------------------------------------------------------------------------
   File        : Enum
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : 
   Created     : 
   Notes       : 
 ----------------------------------------------------------------------*/

block-level on error undo, throw.

class bfvlib.misc.Enum:

  define public property Value as character no-undo get. private set. 
  define public property Name as character no-undo get. private set. 

  constructor protected Enum (enumValue as character, enumName as character):
    this-object:Value  = enumValue.
    this-object:Name = enumName.
    setExtraAttributes(). 
  end constructor. 

  method public override character ToString():
    return this-object:Value.
  end method.

  method protected void SetExtraAttributes():
    /* noop */
  end method.

end class.
