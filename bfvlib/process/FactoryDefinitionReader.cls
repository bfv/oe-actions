 
 /*------------------------------------------------------------------------
    File        : FactoryDefinitionReader
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Sun Dec 29 10:27:24 CET 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using bfvlib.process.FactoryDefinitionReader from propath.
using Progress.Json.ObjectModel.ObjectModelParser from propath.
using Progress.Json.ObjectModel.JsonObject from propath.
using Progress.Json.ObjectModel.JsonArray from propath.

block-level on error undo, throw.

class bfvlib.process.FactoryDefinitionReader: 
    
    {bfvlib/process/factory.i &accessor="private"}
    
    constructor public FactoryDefinitionReader():
        
    end.
    
    constructor public FactoryDefinitionReader(definitionsFile as character):
        this-object:init(definitionsFile).    
    end.
    
    
    method private void init(definitionsFile as character):
        this-object:ReadDefinitions(definitionsFile).
    end method.
    
    
    method public void ReadDefinitions(definitionsFile as character):
        
        define variable definitionsFullPath as character no-undo.
        
        definitionsFullPath = search(definitionsFile).
        if (definitionsFullPath = ?) then
            return.
            
        this-object:readDefs(definitionsFullPath).

    end method.
    
    
    method public void GetDefinitions(output table ttdefinition):
    
    end method.
    
    
    method private void readDefs(definitionsFullPath as character):
      
        define variable parser as ObjectModelParser no-undo.
        define variable json as JsonObject no-undo.
        define variable i as integer no-undo.
        define variable names as character extent no-undo.
        define variable refs as JsonArray no-undo.
        
        parser = new ObjectModelParser().
        json = cast(parser:ParseFile(definitionsFullPath), JsonObject).
        
        if (json:Has("refs")) then do:
            
            refs = json:GetJsonArray("refs").
            do i = 1 to refs:Length:
                this-object:ReadDefinitions(refs:GetCharacter(i)).
            end.
            
        end.
        
        names = json:GetNames().
        do i = 1 to extent(names):
            
            if (names[i] = "refs") then 
                next.
                
            find ttdefinition where ttdefinition.name = names[i] no-error.
            if (not available(ttdefinition)) then
                create ttdefinition.
                
            ttdefinition.name = names[i].
            ttdefinition.implementation = json:GetCharacter(names[i]).  
              
        end.
        
    end method.
    
end class.