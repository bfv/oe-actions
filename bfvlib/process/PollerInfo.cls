 
 /*------------------------------------------------------------------------
    File        : PollerInfo
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Aug 01 05:21:19 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

class bfvlib.process.PollerInfo: 
  
  define public property Topic as character no-undo get. set.
  define public property Period as integer init 60 no-undo get. set.
  define public property ReportIsAlive as logical init true no-undo get. set.
  define public property CronMode as logical no-undo get. set.
  define public property Verbose as logical no-undo get. set.
  
  // default info from session:parameter
  constructor public PollerInfo():
    this-object:readSessionParameter().
  end.
  
  method private void readSessionParameter():
    
    define variable params as character no-undo.
    define variable i as integer no-undo.
    define variable numParams as integer no-undo.
    define variable entryValue as character no-undo.
    define variable paramValue as character no-undo.
    define variable paramName as character no-undo.
    
    params = session:parameter.
    
    numParams = num-entries(params).
    do i = 1 to numParams:
      
      entryValue = entry(i, params).
      paramName = entry(1, entryValue, "=").
      paramValue = entry(2, entryValue, "=").
      
      case (paramName):
        
        when "topic" then 
          this-object:Topic = paramValue.
        when "period" then 
          this-object:Period = integer(paramValue).
        when "isalive" then
          this-object:ReportIsAlive = (paramValue = "true" or paramValue = "yes").
        when "cronmode" then
          this-object:CronMode = (paramValue = "true" or paramValue = "yes").
        when "verbose" then
          this-object:Verbose = (paramValue = "true" or paramValue = "yes").
          
      end case.
      
    end.  // do i = 1 ...
      
  end method.
  
end class.