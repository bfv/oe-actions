 
 /*------------------------------------------------------------------------
    File        : SimpleJsonSerializer
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Jul 20 11:53:54 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using OpenEdge.Core.Collections.IIterator.
using OpenEdge.Core.Collections.IMap.
using OpenEdge.Core.Collections.IMapEntry.
using OpenEdge.Core.Collections.ISet.
using OpenEdge.Core.Collections.KeySet.
using OpenEdge.Core.Collections.List.
using OpenEdge.Core.WidgetHandle.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Lang.Class.
using Progress.Reflect.Property.
using Progress.Lang.AppError.
using Progress.Json.ObjectModel.ObjectModelParser.
using bfvlib.serialize.IListInfo.
using bfvlib.serialize.ISerializable.
using bfvlib.serialize.ISerializableDataStructure.


class bfvlib.serialize.SimpleJsonSerializer implements ISerializable: 
  
  define private variable serializeThese as character no-undo.
  
  constructor public SimpleJsonSerializer():
    serializeThese = "character,date,datetime,datetimetz,decimal,integer,int64,logical,longchar,memptr".    
  end.
  
  method public JsonObject Serialize(objectToSerialize as Progress.Lang.Object):
    return Serialize(objectToSerialize, false).
  end method.
   
  method public JsonObject Serialize(objectToSerialize as Progress.Lang.Object, includeClassName as logical): 
    
    define variable cls as class Class no-undo.
    define variable props as Property extent no-undo.
    define variable prop as Property no-undo.
    define variable jsonOut as JsonObject no-undo.
    define variable jsonSerialized as JsonObject no-undo.
    
    define variable valueObject as Progress.Lang.Object no-undo.
    define variable i as integer no-undo.
   
    
    cls = objectToSerialize:GetClass().
    props = cls:GetProperties().  
    jsonOut = new JsonObject().
    if (includeClassName) then do:
      jsonSerialized = new JsonObject().
      jsonOut:Add(cls:TypeName, jsonSerialized).
    end.
    else 
      jsonSerialized = jsonOut.
    
    do i = 1 to extent(props):
      
      prop = props[i].
      if (not prop:CanRead or prop:Name = "next-sibling" or prop:Name = "prev-sibling") then
        next.
      
      if (lookup(prop:DataType:ToString(), serializeThese) > 0) then  
        jsonSerialized:Add(prop:Name, dynamic-property(objectToSerialize, prop:Name)).
      else do:
        if (prop:DataTypeName = "OpenEdge.Core.Collections.List") then do:
          jsonSerialized:Add(prop:Name, serializeList(dynamic-property(objectToSerialize, prop:Name))).
        end.
        else if (prop:DataTypeName begins "Progress." or prop:DataTypeName begins "OpenEdge.") then do:
          // nothing
        end.
        else do:
          jsonSerialized:Add(prop:Name, Serialize(dynamic-property(objectToSerialize, prop:Name))).
        end.
      end.
    end.
    
    if (objectToSerialize:GetClass():IsA("bfvlib.serialize.ISerializableDataStructure")) then
      addDatastructures(cast(objectToSerialize, "bfvlib.serialize.ISerializableDataStructure"), jsonSerialized).
    
    return jsonOut.
    
  end method.
  
  method private void addDatastructures(objectToSerialize as ISerializableDataStructure, jsonOut as JsonObject):
    
    define variable dataStructs as IMap no-undo.
    define variable dataStruct as IMapEntry no-undo.
    define variable keyset as ISet no-undo.
    define variable iterator as IIterator no-undo.
    define variable keyname as character no-undo.
    define variable dataHandle as handle no-undo.
    define variable keyObject as Progress.Lang.Object no-undo.
    define variable dataObject as WidgetHandle no-undo.
    
    define variable i as integer no-undo.
    
    dataStructs = objectToSerialize:GetDataStructures().
    keyset = dataStructs:KeySet.
    iterator = keyset:Iterator().
    
    do while (iterator:HasNext()):
      keyObject = iterator:Next().
      keyname = string(cast(keyObject, "OpenEdge.Core.String"):Value).
      dataObject = cast(dataStructs:Get(keyObject), "OpenEdge.Core.WidgetHandle").
      dataHandle = dataObject:Value.
      serializeDataObject(keyname, datahandle, jsonOut).
    end.
    
  end method.
  
  method private void serializeDataObject(propertyName as character, data as handle, jsonOut as JsonObject):
        
    if (data:type <> "temp-table") then do:
      jsonOut:Add(propertyName, substitute("<data struct &1 not serializable>", data:type)).
      return.
    end.  
    
    serializeTempTable(propertyName, data, jsonOut).
    
  end method.
  
  method private JsonArray serializeList(dataArray as List):
    
    define variable iterator as IIterator no-undo.
    define variable arrayItem as Progress.Lang.Object no-undo.
    define variable array as JsonArray no-undo.
    define variable obj as Progress.Lang.Object no-undo.
    
    array = new JsonArray().
    
    iterator = dataArray:Iterator().
    do while (iterator:HasNext()):
      arrayItem = iterator:Next().
      if (arrayItem:GetClass():TypeName begins "OpenEdge.Core") then
        array:Add(dynamic-property(arrayItem, "Value")).
      else   
        array:Add(Serialize(arrayItem)).
    end.
    
    return array.
    
  end method.
  
  method private void serializeTempTable(propertyName as character, data as handle, jsonOut as JsonObject):
    
    define variable queryHandle as handle no-undo.
    define variable bufferHandle as handle no-undo.
    define variable fieldHandle as handle no-undo.
    define variable i as integer no-undo.
    define variable array as JsonArray no-undo.
    define variable record as JsonObject no-undo.
    
    array = new JsonArray().
    create query queryHandle.
    bufferHandle = data:default-buffer-handle.
    
    queryHandle:set-buffers(bufferHandle).
    queryHandle:query-prepare("for each " + bufferHandle:name).
    queryHandle:query-open().
    
    queryHandle:get-first().
    do while (not queryHandle:query-off-end):
      record = new JsonObject().
      do i = 1 to bufferHandle:num-fields:
        fieldHandle = bufferHandle:buffer-field(i).
        record:Add(fieldHandle:serialize-name, fieldHandle:buffer-value).
      end.  
      array:Add(record).
      queryHandle:get-next().
    end.
    
    jsonOut:Add(propertyName, array).
      
    finally:
      delete object queryHandle no-error.
    end.
    
  end method.
  
  
  method public longchar SerializeToLongchar(objectToSerialize as Progress.Lang.Object):
    
    define variable json as JsonObject no-undo.
    define variable resultString as longchar no-undo.
    
    json = this-object:Serialize(objectToSerialize).
    json:Write(resultString).
    
    return resultString.
    
  end method.
  
end class.
