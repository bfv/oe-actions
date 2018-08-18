 
 /*------------------------------------------------------------------------
    File        : TestTempTables
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Aug 08 16:06:04 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.Core.Collections.IMap.
using OpenEdge.Core.String.
using OpenEdge.Core.WidgetHandle.
using OpenEdge.Core.Collections.Map.
using bfvlib.serialize.ISerializableDataStructure.

block-level on error undo, throw.

class bfvlib.serialize.test.TestTempTables implements ISerializableDataStructure: 
  
  {bfvlib/serialize/test/ttfactorydef.i @accessor="protected"}
  
  method public IMap GetDataStructures():
    
    define variable dataStructs as IMap no-undo.
    
    dataStructs = new Map().
    dataStructs:Put(new String("definitions"), new WidgetHandle(temp-table ttfactorydef:handle)).
    
    return dataStructs.
    
  end method.
  
  
  method public void LoadClasses():
    
    create ttfactorydef.
    assign 
      ttfactorydef.logicalname = "bol.com:order"
      ttfactorydef.classname = "channel.processors.BolOrderProcessor"
      .

    create ttfactorydef.
    assign 
      ttfactorydef.logicalname = "gallweb:order"
      ttfactorydef.classname = "channel.processors.GallProcessor"
      .
      
  end method.
  
  
  method public override character ToString():
    
    define variable resultString as character no-undo.
    
    for each ttfactorydef:
      resultString = resultString + ttfactorydef.logicalname + '=' + ttfactorydef.classname + "~n".
    end.
    
    return trim(resultString, "~n").
    
  end method.
  
end class.