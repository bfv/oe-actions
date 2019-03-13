 
 /*------------------------------------------------------------------------
    File        : Binary
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Sep 07 08:35:42 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using bfvlib.misc.Binary.

block-level on error undo, throw.

class bfvlib.misc.Binary: 
  
  define public static property Bits8 as integer no-undo initial 8 get. 
  define public static property Bits16 as integer no-undo initial 16 get.
  define public static property Bits24 as integer no-undo initial 24 get.
  define public static property Bits32 as integer no-undo initial 32 get.
  
  method public static integer AND(operand1 as integer, operand2 as integer):
    return Binary:AND(operand1, operand2, 8).
  end method.
  
  method public static integer AND(operand1 as integer, operand2 as integer, bitcount as integer):
    
    define variable bitNumber as integer no-undo.
    define variable resultByte as integer no-undo.
    define variable bitResult as integer no-undo.
    
    bitcount = bitcount - 1.
    do bitNumber = 0 to bitcount: 
    
      bitResult = get-bits(operand1, bitNumber + 1, 1) * get-bits(operand2, bitNumber + 1, 1).
      if (bitResult = 1) then
        resultByte = resultByte + exp(2, bitNumber).
        
    end.
     
    return resultByte.
    
  end method. 
  
  
  method public static integer OR(operand1 as integer, operand2 as integer):
    return Binary:OR(operand1, operand2, 8).  
  end method.

  method public static integer OR(operand1 as integer, operand2 as integer, bitcount as integer):
    
    define variable bitNumber as integer no-undo.
    define variable resultByte as integer no-undo.
    define variable bitResult as integer no-undo.
    
    bitcount = bitcount - 1.
    do bitNumber = 0 to bitcount: 
    
      bitResult = get-bits(operand1, bitNumber + 1, 1) + get-bits(operand2, bitNumber + 1, 1).
      if (bitResult > 0) then
        resultByte = resultByte + exp(2, bitNumber).
        
    end.
     
    return resultByte.
    
  end method. 
  
  method public static integer XOR(operand1 as integer, operand2 as integer):
    return Binary:XOR(operand1, operand2, 8).  
  end method.
  
  method public static integer XOR(operand1 as integer, operand2 as integer, bitcount as integer):
    
    define variable bitNumber as integer no-undo.
    define variable resultByte as integer no-undo.
    define variable bitResult as integer no-undo.
    
    bitcount = bitcount - 1.
    do bitNumber = 0 to bitcount: 
    
      bitResult = get-bits(operand1, bitNumber + 1, 1) + get-bits(operand2, bitNumber + 1, 1).
      if (bitResult = 1) then
        resultByte = resultByte + exp(2, bitNumber).
        
    end.
     
    return resultByte.
    
  end method. 

  method public static integer NOT(operand1 as integer):
    return Binary:NOT(operand1, 8).
  end method.
  
  method public static integer NOT(operand1 as integer, bitcount as integer):
    
    define variable bitNumber as integer no-undo.
    define variable resultByte as integer no-undo.
    define variable bitResult as integer no-undo.
    
    bitcount = bitcount - 1.
    do bitNumber = 0 to bitcount: 
    
      bitResult = get-bits(operand1, bitNumber + 1, 1).
      if (bitResult = 0) then
        resultByte = resultByte + exp(2, bitNumber).
        
    end.
     
    return resultByte.
    
  end method. 
  
  method public static integer ShiftLeft(operand1 as integer, shiftcount as integer):
    return Binary:ShiftLeft(operand1, shiftcount, 8).  
  end method.
  
  method public static integer ShiftLeft(operand1 as integer, shiftcount as integer, bitcount as integer):
    
    define variable resultByte as integer no-undo.
    define variable i as integer no-undo.
    
    resultByte = operand1.
    do i = 1 to shiftcount:
      resultByte = resultByte * 2.
      if (resultByte >= (exp(2, bitcount))) then 
        resultByte = resultByte - exp(2, bitcount).
    end.
    
    return resultByte.
      
  end method.

  method public static integer ShiftRight(operand1 as integer, shiftcount as integer):
    return Binary:ShiftRight(operand1, shiftcount, 8).  
  end method.
  
  method public static integer ShiftRight(operand1 as integer, shiftcount as integer, bitcount as integer):
    
    define variable resultByte as integer no-undo.
    define variable i as integer no-undo.
    
    resultByte = operand1.
    do i = 1 to shiftcount:
      resultByte = truncate(resultByte / 2, 0).
    end.
    
    return resultByte.
      
  end method.
  
  method public static integer CircularShiftLeft(operand1 as integer, shiftcount as integer):
    return Binary:CircularShiftLeft(operand1, shiftcount, 8).  
  end method.
  
  method public static integer CircularShiftLeft(operand1 as integer, shiftcount as integer, bitcount as integer):
    
    define variable resultByte as integer no-undo.
    
    if (shiftcount = 0) then
      return operand1.
      
    resultByte = Binary:OR(
                   Binary:ShiftLeft(operand1, shiftcount, bitcount),
                   Binary:ShiftRight(operand1, (bitcount - shiftcount), bitcount)
                 ). 
    return resultByte.    
    
  end method.

  method public static integer CircularShiftRight(operand1 as integer, shiftcount as integer):
    return Binary:CircularShiftRight(operand1, shiftcount, 8).  
  end method.
  
  method public static integer CircularShiftRight(operand1 as integer, shiftcount as integer, bitcount as integer):
    
    define variable resultByte as integer no-undo.
    
    if (shiftcount = 0) then
      return operand1.
      
    resultByte = Binary:OR(
                   Binary:ShiftRight(operand1, shiftcount, bitcount),
                   Binary:ShiftLeft(operand1, (bitcount - shiftcount), bitcount)
                 ). 
    return resultByte.    
    
  end method.
  
end class.