 
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
  
  
  method public Progress.Lang.Object DeserializeFile(jsonFilename as character, className as character):
    
    define variable parser as ObjectModelParser no-undo.
    define variable jsonObj as JsonObject no-undo.
    
    parser = new ObjectModelParser().
    jsonObj = cast(parser:ParseFile(jsonFilename), "JsonObject").
    
    return Deserialize(jsonObj, className).
    
  end method.
  
  
  method public Progress.Lang.Object DeserializeFile(jsonFilename as character, targetObj as Progress.Lang.Object):
    
    define variable parser as ObjectModelParser no-undo.
    define variable jsonObj as JsonObject no-undo.
    
    parser = new ObjectModelParser().
    jsonObj = cast(parser:ParseFile(jsonFilename), "JsonObject").
    
    return Deserialize(jsonObj, targetObj).
    
  end method.
   

  // in this method the target class name is expected to the name of the first property
  method public Progress.Lang.Object Deserialize(jsonIn as JsonObject, className as character):
    
    define variable properties as character extent no-undo.
    define variable obj as Progress.Lang.Object no-undo.
    define variable jsonObj as JsonObject no-undo.
       
    do on error undo, throw:
      
      obj = dynamic-new(className)().
      Deserialize(jsonIn, obj).
      
      catch err1 as Progress.Lang.Error :
        message 'error:' err1:GetMessage(1) view-as alert-box.
        undo, throw new AppError(substitute("'&1' is not a class", className)).  
      end catch.
    end.
    
    return obj.
    
  end method.
  
  method public Progress.Lang.Object DeserializeString(jsonString as longchar, className as character):
    
    define variable parser as ObjectModelParser no-undo.
    define variable jsonObj as JsonObject no-undo.
    
    parser = new ObjectModelParser().
    jsonObj = cast(parser:Parse(jsonString), "JsonObject").
    
    return this-object:Deserialize(jsonObj, className).
    
  end method.
  
  method public void DeserializeString(jsonString as longchar, targetObject as Progress.Lang.Object):
    
    define variable parser as ObjectModelParser no-undo.
    define variable jsonObj as JsonObject no-undo.
    
    parser = new ObjectModelParser().
    jsonObj = cast(parser:Parse(jsonString), "JsonObject").
    
    this-object:Deserialize(jsonObj, targetObject).
    
  end method.
  
  method public Progress.Lang.Object Deserialize(jsonIn as JsonObject, targetObj as Progress.Lang.Object): 

    define variable cls as class Class no-undo.
    define variable props as Property extent no-undo.
    define variable prop as Property no-undo.
    define variable jsonOut as JsonObject no-undo.
    define variable resultList as List no-undo.    
    define variable resultObj as Progress.Lang.Object no-undo.
    define variable valueObject as Progress.Lang.Object no-undo.
    define variable i as integer no-undo.
    define variable getter as character no-undo.
    
    cls = targetObj:GetClass().
    props = cls:GetProperties().  
    
    do i = 1 to extent(props):
      
      prop = props[i].
      if (not prop:CanWrite or prop:Name = "next-sibling" or prop:Name = "prev-sibling") then
        next.      
      
      do on error undo, throw:

        getter = "Get" + prop:DataType:ToString().        
        if (lookup(prop:DataType:ToString(), serializeThese) > 0) then  
          dynamic-property(targetObj, prop:Name) = dynamic-invoke(jsonIn, getter, prop:Name).
        else do:
          if (prop:DataTypeName = "OpenEdge.Core.Collections.List" and targetObj:GetClass():IsA("bfvlib.serialize.IListInfo")) then do:
            //add list entries to object
            resultList = deserializeList(cast(targetObj, "bfvlib.serialize.IListInfo"), prop, jsonIn:GetJsonArray(prop:Name)).
            dynamic-property(targetObj, prop:Name) = resultList.
          end.
          else if (prop:DataTypeName begins "Progress." or prop:DataTypeName begins "OpenEdge.") then do:
            // nothing
          end.
          else do:
            resultObj = dynamic-new(prop:DataTypeName)().
            Deserialize(jsonIn:GetJsonObject(prop:Name), resultObj).
            dynamic-property(targetObj, prop:Name) = resultObj.
          end.
        end.
        
        catch err1 as Progress.Lang.Error:
          message err1:GetMessage(1) view-as alert-box.  
        end catch.
        
      end.  // do on error   
         
    end.  // do i = 1 to extent(props)
    
    if (targetObj:GetClass():IsA("bfvlib.serialize.ISerializableDataStructure")) then do:
      this-object:deserializeDataStructures(jsonIn, cast(targetObj, "bfvlib.serialize.ISerializableDataStructure")). 
    end.
    
    return targetObj.
    
  end method.
  
  method private List deserializeList(targetObject as IListInfo, prop as Property, array as JsonArray):
    
    define variable listType as character no-undo.   
    define variable newList as List no-undo.
    define variable i as integer no-undo.
    define variable jsonObj as JsonObject no-undo.
    define variable obj as Progress.Lang.Object no-undo.
    
    newList = new List().
    listType = targetObject:GetListType(prop:Name).
    
    do i = 1 to array:Length:
      
      if (listType begins "OpenEdge.Core") then do:
        
        case (listType): 
          
          when "OpenEdge.Core.String" then
            obj = dynamic-new(listType)(array:GetLongchar(i)).
             
          when "OpenEdge.Core.Integer" then 
            obj = dynamic-new(listType)(array:GetInteger(i)).
          
          when "OpenEdge.Core.Decimal" then
            obj = dynamic-new(listType)(array:GetDecimal(i)).
            
          otherwise
            message listType 'not handled' view-as alert-box.
            
        end case.
        
      end.
      else do:
        obj = dynamic-new(listType)().
        jsonObj = array:GetJsonObject(i).
        Deserialize(jsonObj, obj).
      end.
      
      newList:Add(obj).
      
    end.
    
    return newList.
    
  end method.
  
  @todo(what="deserialize temp-table").
  method private void deserializeDataStructures(jsonIn as jsonObject, targetObj as ISerializableDataStructure):
    
    define variable dataStructs as IMap no-undo.
    define variable structure as IMapEntry no-undo.
    define variable keyset as ISet no-undo.
    define variable iterator as IIterator no-undo.
    define variable keyObject as Progress.Lang.Object no-undo.
    define variable keyname as character no-undo.
    define variable dataObject as WidgetHandle no-undo.
    define variable array as JsonArray no-undo.
        
    dataStructs = targetObj:GetDataStructures().
    keyset = dataStructs:KeySet.
    iterator = keyset:Iterator().
    
    do while (iterator:HasNext()):
      keyObject = iterator:Next().
      keyname = string(cast(keyObject, "OpenEdge.Core.String"):Value).
      dataObject = cast(dataStructs:Get(keyObject), "OpenEdge.Core.WidgetHandle").
      
      array = jsonIn:GetJsonArray(keyname).
      this-object:jsonArrayToTempTable(array, dataObject:Value).
    end.
       
  end method.
  
  
  method private void jsonArrayToTempTable(array as JsonArray, tthandle as handle):
    
    define variable i as integer no-undo.
    define variable j as integer no-undo.
    define variable bufferHandle as handle no-undo.
    define variable bufferField as handle no-undo.
    define variable jsonRecord as JsonObject no-undo.
    define variable getter as character no-undo.
    
    bufferHandle = tthandle:default-buffer-handle.
    
    do i = 1 to array:Length:
      jsonRecord = array:GetJsonObject(i).
      bufferHandle:buffer-create().
      
      do j = 1 to bufferHandle:num-fields:
        bufferField = bufferHandle:buffer-field(j).
        bufferField:buffer-value = dynamic-invoke(jsonRecord, "Get" + bufferField:data-type, bufferField:serialize-name).
      end.
      
      bufferHandle:buffer-release().
      
    end.  
    
  end method.
  
end class.