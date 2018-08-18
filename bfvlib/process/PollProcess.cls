 
 /*------------------------------------------------------------------------
    File        : PollProcess
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Aug 01 06:17:04 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/


block-level on error undo, throw.

class bfvlib.process.PollProcess: 
  
  define private variable topic as character no-undo.
  
  define private stream logfile.
  
  constructor protected PollProcess(topicIn as character):
    this-object:topic = topicIn.
  end.
  
  method protected void LogThis(messageString as character):
    
    output stream logfile to value(this-object:topic + ".log") append.
    
    put stream logfile unformatted iso-date(now) " " messageString skip.
    
    finally:
      output stream logfile close.
    end.
    
  end method.
  
end class.