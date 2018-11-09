 
/*------------------------------------------------------------------------
   File        : HMAC
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : bronco
   Created     : 
   Notes       : Code originally written by James Bowen and Roel Lakenvelt
 ----------------------------------------------------------------------*/
  
/* References: http://www.ietf.org/rfc/rfc2104.txt                              */
/*             http://the.jhu.edu/upe/member_sites/zarfoss/HMAC-big.jpg         */
/*             http://en.wikipedia.org/wiki/HMAC                                */
/*             http://www.cryptostuff.com/crypto/index.php?title=hmac           */  

block-level on error undo, throw.

using bfvlib.misc.Binary.

class bfvlib.security.cryptography.HMAC: 

  method public static character SHA256_Base64(key as character, data as character):
    return string(base64-encode(keyedHash('SHA-256', key, data))).
  end.    

   method public static character SHA256_Hex(key as character, data as character):
    return string(hex-encode(keyedHash('SHA-256', key, data))).
  end.
  
  method public static character SHA1_Base64(key as character, data as character):
    return string(base64-encode(keyedHash('SHA-1', key, data))).
  end.    

   method public static character SHA1_Hex(key as character, data as character):
    return string(hex-encode(keyedHash('SHA-1', key, data))).
  end.
  
  method private static raw keyedHash(hashAlgoritm as character, keyString as character, dataString as character):
    
    &if proversion(1) >= "11.7.4" &then
    return message-digest("HMAC-" + hashAlgoritm, dataString, keyString).
    &else
    define variable outerPaddedKey as memptr no-undo.
    define variable innerPaddedKey as memptr no-undo.
    define variable dataBytes as memptr no-undo.
    define variable keyBytes as memptr no-undo.
    define variable innerCombined as memptr no-undo.
    define variable outerCombined as memptr no-undo.
    define variable byteNumber as integer no-undo.
    define variable outerPadByteValue as integer no-undo.
    define variable innerPadByteValue as integer no-undo.
    define variable keyByteValue as integer no-undo.
    define variable rawDataSHA as raw no-undo.
    define variable i as integer no-undo.
        
    &SCOPED-DEFINE hmacBlockSize  64
        
    set-size(keyBytes) = {&hmacBlockSize}.
    set-size(outerPaddedKey) = {&hmacBlockSize}.
    set-size(innerPaddedKey) = {&hmacBlockSize}.
    
    do i = 1 to {&hmacBlockSize}:
      put-bytes(keyBytes, i) = hex-decode("00").
    end. 
       
    put-string(outerPaddedKey, 1, {&hmacBlockSize}) = fill("~134", {&hmacBlockSize}). // use octal for the value
    put-string(innerPaddedKey, 1, {&hmacBlockSize}) = fill("~066", {&hmacBlockSize}). // use octal for the value
        
    if length(keyString) > {&hmacBlockSize} then do:
      set-size(dataBytes) = length(keyString).
      put-string(dataBytes, 1, length(keyString)) = keyString.
      rawDataSHA = message-digest(hashAlgoritm, dataBytes). 
      set-size(keyBytes) = length(keyString).
      put-bytes(keyBytes, 1) = rawDataSHA.
    end.
    else if (keyString > "") then
      put-string(keyBytes, 1, length(keyString)) = keyString.       
    // in case of empty key, do nothing
      
    do byteNumber = 1 to {&hmacBlockSize}:
                    
      assign
        keyByteValue = get-byte(keyBytes, byteNumber)
        outerPadByteValue = get-byte(outerPaddedKey, byteNumber)
        innerPadByteValue = get-byte(innerPaddedKey, byteNumber)
        .
          
      /* The inner key, innerPaddedKey is formed from keyBytes by XORing each byte with 0x36.. */
      put-byte(innerPaddedKey, byteNumber) = Binary:XOR(innerPadByteValue, keyByteValue).
        
      /* The inner key, outerPaddedKey is formed from keyBytes by XORing each byte with 0x5C. */
      put-byte(outerPaddedKey, byteNumber) = Binary:XOR(outerPadByteValue, keyByteValue).
        
    end.
    
    if (length(dataString) > 0) then do:    
      set-size(dataBytes) = length(dataString).
      put-string(dataBytes, 1, length(dataString)) = dataString.
    end.
    
    /* Inner Loop*/
    set-size(innerCombined) = get-size(innerPaddedKey) + get-size(dataBytes).
    put-bytes(innerCombined, 1) = innerPaddedKey.
        
    /* Append the data the end of the block size.*/
    put-bytes(innerCombined, {&hmacBlockSize} + 1) = dataBytes.
        
    /* Get the results of the SHA Digest.*/
    rawDataSHA = message-digest(hashAlgoritm, innerCombined).
                                         
    set-size(outerCombined) = get-size(outerPaddedKey) + length(rawDataSHA, 'RAW').    
    put-bytes(outerCombined, 1) = outerPaddedKey.
    put-bytes(outerCombined, {&hmacBlockSize} + 1) = rawDataSHA.
    
    rawDataSHA = message-digest(hashAlgoritm, outerCombined).    
        
    return rawDataSHA.

    finally:
      set-size(dataBytes) = 0.
      set-size(keyBytes) = 0.
      set-size(innerCombined) = 0.
      set-size(innerPaddedKey) = 0.
      set-size(outerPaddedKey) = 0.
      set-size(outerCombined) = 0.  
    end.    
    &endif
    
  end method. 
    
end class.