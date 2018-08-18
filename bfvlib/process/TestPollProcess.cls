 
 /*------------------------------------------------------------------------
    File        : CeOrderPollProcess
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Aug 01 05:51:42 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using bfvlib.process.IExecutable.
using bfvlib.process.PollProcess.

block-level on error undo, throw.

class bfvlib.process.TestPollProcess inherits PollProcess implements IExecutable: 
  
  constructor public TestPollProcess():
    super("polltest").  
  end.
  
  method public void Execute():
    LogThis("Execute() @ TestPollProcess").
  end method.

end class.