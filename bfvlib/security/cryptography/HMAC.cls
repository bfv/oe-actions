 
/*------------------------------------------------------------------------
   File        : HMAC
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : rlakenvelt
   Created     : Thu Aug 02 13:58:52 CEST 2018
   Notes       : Code originally written by James Bowen
                 Fixed bug in sha256 with keys longer than 64 bytes
 ----------------------------------------------------------------------*/
  
/* Simple HMAC function Overview                                                */
/* Developer: James Bowen                                                       */
/* Date:      13/06/2011                                                        */
/* References: http://www.ietf.org/rfc/rfc2104.txt                              */
/*             http://the.jhu.edu/upe/member_sites/zarfoss/HMAC-big.jpg         */
/*             http://en.wikipedia.org/wiki/HMAC                                */
/*             http://www.cryptostuff.com/crypto/index.php?title=hmac           */
/* HMAC is a hash based MAC algorithm defined in RFC 2104. It can use any       */
/* hash function (such as MD5, SHA1 etc). HMAC also requires a user             */
/* supplied secret key, which is a string of bytes of any length upto 64 bytes. */  
  

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
  
  method public static character MD5_Base64(key as character, data as character):
    return string(base64-encode(keyedHash('MD5', key, data))).
  end.    

   method public static character MD5_Hex(key as character, data as character):
    return string(hex-encode(keyedHash('MD5', key, data))).
  end.
  
  /* in its current state the algorithm is flawed when using zero length keys.
   * In reality this will not occur 
   */
  method private static raw keyedHash(hashAlgoritm as character, keyString as character, dataString as character):
    
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
    define variable rRawDataSHA as raw no-undo.
    define variable i as integer no-undo.
        
    &SCOPED-DEFINE hmacBlockSize  64
        
    set-size(keyBytes)     = {&hmacBlockSize}.
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
      rRawDataSHA = message-digest(hashAlgoritm, dataBytes). 
      set-size(keyBytes) = length(keyString).
      put-bytes(keyBytes, 1) = rRawDataSHA.
    end.
    else if (keyString > "") then
      put-string(keyBytes, 1, length(keyString)) = keyString.       
      
    do byteNumber = 1 to {&hmacBlockSize}:
                    
      assign
        keyByteValue  = get-byte(keyBytes, byteNumber)
        outerPadByteValue = get-byte(outerPaddedKey, byteNumber)
        innerPadByteValue = get-byte(innerPaddedKey, byteNumber)
        .
          
      /* The inner key, innerPaddedKey is formed from keyBytes by XORing each byte with 0x36.. */
      put-byte(innerPaddedKey, byteNumber) = Binary:XOR(innerPadByteValue, keyByteValue).
        
      /* The inner key, outerPaddedKey is formed from keyBytes by XORing each byte with 0x5C. */
      put-byte(outerPaddedKey, byteNumber) = Binary:XOR(outerPadByteValue, keyByteValue).
        
    end.
        
    set-size(dataBytes) = length(dataString).
    put-string(dataBytes, 1, length(dataString)) = dataString.
        
    /* Inner Loop*/
    set-size(innerCombined) = get-size(innerPaddedKey) + get-size(dataBytes).
    put-bytes(innerCombined, 1) = innerPaddedKey.
        
    /* Append the data the end of the block size.*/
    put-bytes(innerCombined, {&hmacBlockSize} + 1) = dataBytes.
        
    /* Get the results of the SHA Digest.*/
    rRawDataSHA = message-digest(hashAlgoritm, innerCombined).
                                         
    set-size(outerCombined) = get-size(outerPaddedKey) + length(rRawDataSHA, 'RAW').    
    put-bytes(outerCombined, 1) = outerPaddedKey.
    put-bytes(outerCombined, {&hmacBlockSize} + 1) = rRawDataSHA.
    
    rRawDataSHA = message-digest(hashAlgoritm, outerCombined).    
        
    return rRawDataSHA.

    finally:
      set-size(dataBytes) = 0.
      set-size(keyBytes)  = 0.
      set-size(innerCombined) = 0.
      set-size(innerPaddedKey) = 0.
      set-size(outerPaddedKey) = 0.
      set-size(outerCombined) = 0.  
    end.    
    
  end method. 
    
end class.