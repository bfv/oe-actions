 
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

class bfvlib.security.cryptography.HMAC: 

  method public static character SHA256-BASE64(key as character, data as character):
    return keyedHash('SHA-256', key, data).
  end.    

  method private static character keyedHash(pcSHA as character, pcKey as character, pcData as character):
    
    define variable mKeyOpad       as memptr    no-undo.
    define variable mKeyIpad       as memptr    no-undo.
    define variable mData          as memptr    no-undo.
    define variable mKey           as memptr    no-undo.
    define variable mInnerCombined as memptr    no-undo.
    define variable mOuterCombined as memptr    no-undo.
    define variable iBytePos       as integer   no-undo.
    define variable iOpad          as integer   no-undo.
    define variable iIpad          as integer   no-undo.
    define variable iKey           as integer   no-undo.
    define variable iTimeTaken     as integer   no-undo.
    define variable rRawDataSHA    as raw       no-undo.
    define variable cHMACSHA       as character no-undo.
        
        &SCOPED-DEFINE xiBlockSize  64
        
    set-size(mKey)     = 0.
    set-size(mKeyOpad) = 0.
    set-size(mKeyIpad) = 0.
    set-size(mKey)     = {&xiBlockSize}.
    set-size(mKeyOpad) = {&xiBlockSize}.
    set-size(mKeyIpad) = {&xiBlockSize}.
        
/*    do iBytePos = 1 to {&xiBlockSize}:                                                                */
/*      put-bytes(mKey, iBytePos)     = hex-decode("00":U).  /* 64 bytes of zeros 0x00*/                */
/*      put-bytes(mKeyOpad, iBytePos) = hex-decode("5C":U).  /* 64 bytes of 0x5C (92 dec,  "/" ascii) */*/
/*      put-bytes(mKeyIpad, iBytePos) = hex-decode("36":U).  /* 64 bytes of 0x36 (54 dec, "6" ascii)*/  */
/*    end.                                                                                              */
    
    // de code hierboven heeft last van bug PSC00343029 onder 11.6
    put-string(mKeyOpad, 1, {&xiBlockSize}) = fill("~134", {&xiBlockSize}). // use octal for the value
    put-string(mKeyIpad, 1, {&xiBlockSize}) = fill("~066", {&xiBlockSize}). // use octal for the value
        
    /* correction by Valery A.Eliseev */
    if length(pcKey) > {&xiBlockSize} then do:
      set-size(mData) = length(pcKey).
      put-string(mData, 1, length(pcKey)) = pcKey.
      /* Roel Lakenvelt: fixed issue in sha256 with keys longer than 64 bytes */
      if pcSHA = 'SHA-256' then
        rRawDataSHA = message-digest('SHA-256', mData). 
      else
        rRawDataSHA = sha1-digest(mData).    
      set-size(mKey)     = length(pckey).
      put-bytes(mKey, 1) = rRawDataSHA.
    end.
    else
      /* end of correction */
        
      put-string(mKey, 1, length(pckey))  = pcKey. 
        
    do iBytePos = 1 to {&xiBlockSize}:
          
      assign
        iKey  = get-byte(mKey, iBytePos)
        iOpad = get-byte(mKeyOpad, iBytePos)
        iIpad = get-byte(mKeyIpad, iBytePos).
          
      /* The inner key, mKeyIpad is formed from mKey by XORing each byte with 0x36.. */
      put-byte(mKeyIpad, iBytePos) = binaryXOR(iKey, iIpad).
        
      /* The inner key, mKeyOpad is formed from mKey by XORing each byte with 0x5C. */
      put-byte(mKeyOpad, iBytePos) = binaryXOR(iKey, iOpad).
        
    end.
        
    set-size(mKey)  = 0.
    set-size(mData) = 0.
    set-size(mData) = length(pcData).
    put-string(mData, 1, length(pcData)) = pcData.
        
        
    /* Inner Loop*/
    set-size(mInnerCombined) = get-size(mKeyIpad) + GET-SIZE(mData).
        
    put-bytes(mInnerCombined, 1) = mKeyIpad.
    set-size(mKeyIpad) = 0.
        
    /*Append the data the end of the block size.*/
    put-bytes(mInnerCombined, {&xiBlockSize} + 1) = mData.
        
    /* Deallocates any memory. */
    set-size(mData) = 0.
        
    /* Get the results of the SHA Digest.*/
    case pcSHA:
      when 'SHA1' then
        assign
          rRawDataSHA = sha1-digest(mInnerCombined).
      when 'SHA-256' then
        assign
          rRawDataSHA = message-digest('SHA-256', mInnerCombined).
      otherwise 
        assign
          rRawDataSHA = sha1-digest(mInnerCombined).
    end case.
                                         
    /* Deallocates any memory. */
    set-size(mInnerCombined) = 0.
        
    /* Outer Loop calculation for SHA*/
    set-size(mOuterCombined) = 0.
    set-size(mOuterCombined) = get-size(mKeyOpad) + LENGTH(rRawDataSHA,'RAW':U).
    
    put-bytes(mOuterCombined, 1) = mKeyOpad.
    put-bytes(mOuterCombined, {&xiBlockSize} + 1) = rRawDataSHA.
        
    /* SHA*/
    case pcSHA:
      when 'SHA1' then
        assign
          rRawDataSHA = sha1-digest(mOuterCombined).
      when 'SHA-256' then
        assign
          rRawDataSHA = message-digest('SHA-256', mOuterCombined).
      otherwise 
        assign
          rRawDataSHA = sha1-digest(mOuterCombined).
    end case.
        
    /* Deallocates any memory. */
    set-size(mKeyOpad)       = 0.
    set-size(mOuterCombined) = 0.
        
    /* Convert the raw binary results into a human readable BASE-64 value.*/
    cHMACSHA = base64-encode(rRawDataSHA).
        
    &UNDEFINE xiBlockSize
    return cHMACSHA.
  end method.
  
    
  method static private integer binaryXOR(intOperand1 as integer, input intOperand2 as integer):
    
    define variable iByteLoop  as integer no-undo.
    define variable iXOResult  as integer no-undo.
    define variable lFirstBit  as logical no-undo.
    define variable lSecondBit as logical no-undo.
    
    iXOResult = 0.
    
    /*spin through each byte of each char*/
    do iByteLoop = 0 to 7: /* as processing a single byte character */
    
      /*find state (true / false) of each integer's byte*/
      assign
        lFirstBit  = get-bits(intOperand1, iByteLoop + 1, 1) = 1
        lSecondBit = get-bits(intOperand2, iByteLoop + 1, 1) = 1.
    
      /* XOR each bit*/
      if (lFirstBit and not lSecondBit) or 
         (lSecondBit and not lFirstBit) then
        iXOResult = iXOResult + EXP(2, iByteLoop).
        
    end.
     
    return iXOResult.
  end method. 
    
end class.