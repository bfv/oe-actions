 
 /*------------------------------------------------------------------------
    File        : TestMessageOut
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Jul 20 11:18:04 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using bfvlib.serialize.ISerializableDataStructure.
using OpenEdge.Core.Collections.Map.
using OpenEdge.Core.Collections.IMap.
using OpenEdge.Core.String.
using OpenEdge.Core.WidgetHandle.
using OpenEdge.Core.Collections.List.
using bfvlib.serialize.test.Address.

block-level on error undo, throw.

class bfvlib.serialize.test.TestMessageOut implements ISerializableDataStructure serializable: 
  
  define public property Id as int64 no-undo get. set.
  define public property To as character no-undo get. set.
  define public property Type as character no-undo get. set.
  define public property Created as datetime-tz no-undo get. set.
  define public property Datum as date no-undo get. set.
  define public property Bedrag as decimal no-undo get. set.
  define public property Active as logical no-undo get. set.
  
  define public property Bla as Progress.Lang.Object no-undo get. set.  
  define public property mptr as memptr no-undo get. set.
  
  define public property HouseAddress as Address no-undo get. set.
  
  define public property Recipients as List no-undo get. set.
  
  {bfvlib/serialize/test/dstest.i}
  
  define protected temp-table ttkeyvalue no-undo
    field keyname as character
    field keyvalue as character
    .
  
  method public IMap GetDataStructures():
    
    define variable dataStructs as IMap no-undo.
    
    dataStructs = new Map().
    dataStructs:Put(new String("properties"), new WidgetHandle(temp-table ttkeyvalue:handle)).
    
    return dataStructs.
    
  end method.
  
  method public void AddKV(kname as character, kvalue as character):
    
    create ttkeyvalue.
    assign 
      ttkeyvalue.keyname = kname
      ttkeyvalue.keyvalue = kvalue
      .
  end method.
  
  method public void GenerateOrderDataset():
    
    create ttcustomer.
    assign 
      ttcustomer.custnum = 1
      ttcustomer.custname = "Skylift tours"
      ttcustomer.address = "dorpsstraat 1"
      .
      
    create ttorder.
    assign 
      ttorder.custnum = 1
      ttorder.ordernum = 2
      ttorder.price = 10.0
      .
    
  end method.
  
end class.
