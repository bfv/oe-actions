 
 /*------------------------------------------------------------------------
    File        : Factory
    Purpose     : This factory maps names (of interfaces) to implementations.
                  
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Dec 20 14:00:02 CET 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Json.ObjectModel.ObjectModelParser from propath.
using Progress.Json.ObjectModel.JsonObject from propath.
using bfvlib.process.ISingleton from propath.
using bfvlib.process.IDestroyable from propath.
using bfvlib.process.Factory from propath.
using bfvlib.process.FactoryDefinitionReader from propath.

block-level on error undo, throw.

class bfvlib.process.Factory: 
    
    {bfvlib/process/factory.i &accessor="private"}

    define private temp-table ttinstance no-undo
        field name as character 
        field instance as Progress.Lang.Object
        .
    
    define private static property instance as Factory no-undo get. set.
    
    
    /*------------------------------------------------------------------------------
     Purpose: Adds the definitions in definitionsFile parameter to the factory.
     Notes: If multiple definitions exist with the same name, the last one wins.
     @param definitionsFile Filename of the defintions to be added to the factory.
            
    ------------------------------------------------------------------------------*/
    constructor static Factory():
        Factory:instance = new Factory().
    end.
    
    constructor private Factory():
        
    end.
    
    
    method private void readDefs(definitionsFile as character):
        
        define variable reader as FactoryDefinitionReader no-undo.
        
        reader = new FactoryDefinitionReader().
        reader:ReadDefinitions(definitionsFile).
        reader:GetDefinitions(output table ttdefinition).
        
    end method.
    
    
    /*------------------------------------------------------------------------------
     Purpose: Read the definitions in a file in the factory 
     Notes: 
     @param definitionsFile file with the definitions (can be) relative to the PROPATH
      
    ------------------------------------------------------------------------------*/
    method public static void ReadDefinitions(definitionsFile as character):
        Factory:instance:readDefs(definitionsFile).
    end method.    
    
    
    /*------------------------------------------------------------------------------
     Purpose: Getting an instance 
     Notes:
     @param name Name of the instance
     @return Object instance 
    ------------------------------------------------------------------------------*/
    method public static Progress.Lang.Object Get(name as character):
        return Factory:instance:GetInstance(name).
    end method.
    
    method private Progress.Lang.Object GetInstance(name as character):
        
        define variable instance as Progress.Lang.Object no-undo.
        
        find ttinstance where ttinstance.name = name no-error.
        if (available(ttinstance) and valid-object(ttinstance.instance)) then
            return ttinstance.instance.
        
        for first ttdefinition where ttdefinition.name = name:
            instance = dynamic-new (ttdefinition.implementation)().
            if (instance:GetClass():IsA("bfvlib.process.ISingleton")) then do:
                create ttinstance.
                ttinstance.name = name.
                ttinstance.instance = instance.
            end.
        end.
        
        return instance.
               
    end method.
       
    
    /*------------------------------------------------------------------------------
     Purpose: Deletes an instance from the factory
     Notes: If the instance is a bfvlib.process.IDestroyable the Destroy() method will be called
     @param instance instance to delete 
    ------------------------------------------------------------------------------*/
    method public static void Delete(instance as Progress.Lang.Object):
        Factory:instance:deleteInstance(instance).
    end method.
    
    
    method private void deleteInstance(instance as Progress.Lang.Object):

        for first ttinstance where ttinstance.instance = instance:
            
            if (valid-object(ttinstance.instance)) then do:
                
                if (ttinstance.instance:GetClass():IsA("bfv.process.IDestroyable")) then 
                    cast(ttinstance.instance, IDestroyable):Destroy().
                    
                delete object ttinstance.instance no-error.
            end.
            
            delete ttinstance.
            
        end.
        
    end method.

end class.