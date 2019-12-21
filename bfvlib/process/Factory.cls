 
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

block-level on error undo, throw.

class bfvlib.process.Factory: 
    
    define private static temp-table ttdefinition no-undo
        field name as character
        field implementation as character
        field lifecycle as character 
        .
    
    define private static temp-table ttinstance no-undo
        field name as character 
        field instance as Progress.Lang.Object
        .

    /*------------------------------------------------------------------------------
     Purpose: Adds the definitions in definitionsFile parameter to the factory.
     Notes: If multiple definitions exist with the same name, the last one wins.
     @param definitionsFile Filename of the defintions to be added to the factory.
            
    ------------------------------------------------------------------------------*/
    constructor public Factory(definitionsFile as character):
        this-object:init(definitionsFile).    
    end.
    
    
    method private void init(definitionsFile as character):
      
        define variable definitionsFullPath as character no-undo.
        
        definitionsFullPath = search(definitionsFile).
        if (definitionsFullPath = ?) then
            return.
            
        this-object:readDefinitions(definitionsFullPath).
        
    end method.
    
    
    method private void readDefinitions(definitionsFullPath as character):
      
        define variable parser as ObjectModelParser no-undo.
        define variable json as JsonObject no-undo.
        define variable i as integer no-undo.
        define variable names as character extent no-undo.
        
        parser = new ObjectModelParser().
        json = cast(parser:ParseFile(definitionsFullPath), JsonObject).
        
        names = json:GetNames().
        do i = 1 to extent(names):
            
            find ttdefinition where ttdefinition.name = names[i] no-error.
            if (not available(ttdefinition)) then
                create ttdefinition.
                
            ttdefinition.name = names[i].
            ttdefinition.implementation = json:GetCharacter(names[i]).    
        end.
        
    end method.
    
    
    /*------------------------------------------------------------------------------
     Purpose: Getting an instance 
     Notes:
     @param name Name of the instance
     @return Object instance 
    ------------------------------------------------------------------------------*/
    method public static Progress.Lang.Object Get(name as character):
        
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