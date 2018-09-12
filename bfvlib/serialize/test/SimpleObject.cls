 
 /*------------------------------------------------------------------------
    File        : SimpleObject
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Sat Aug 18 16:14:29 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/


block-level on error undo, throw.

class bfvlib.serialize.test.SimpleObject serializable: 
  define public property Prop1 as character no-undo get. set.
  define public property Prop2 as character no-undo get. set.
  define public property Prop3 as character no-undo get. set.
end class.