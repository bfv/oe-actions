 
 /*------------------------------------------------------------------------
    File        : HMAC_TC
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Fri Sep 07 12:13:21 CEST 2018
    Notes       : test values from https://en.wikipedia.org/wiki/HMAC
  ----------------------------------------------------------------------*/

using OpenEdge.Core.Assert.
using bfvlib.security.cryptography.HMAC.

block-level on error undo, throw.

class bfvlib.security.cryptography.HMAC_TC:
   
  @Test.
  method public void HMAC_SHA256_Hex_empty():
    Assert:Equals(
      "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad",
      HMAC:SHA256_Hex("", "") 
    ).
  end method.

  @Test.
  method public void HMAC_SHA256_Hex_quickfox():
    Assert:Equals(
      "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8",
      HMAC:SHA256_Hex("key", "The quick brown fox jumps over the lazy dog") 
    ).
  end method.
    
  @Test.
  method public void HMAC_SHA1_Hex_empty():
    Assert:Equals(
      "fbdb1d1b18aa6c08324b7d64b71fb76370690e1d",
      HMAC:SHA1_Hex("", "")
    ).
  end method.

  @Test.
  method public void HMAC_SHA1_Hex_quickfox():
    Assert:Equals(
      "de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9",
      HMAC:SHA1_Hex("key", "The quick brown fox jumps over the lazy dog")
    ).
  end method.
  
  @Test.
  method public void HMAC_SHA256_Base64_secret():
    Assert:Equals(
      "qnR8UCqJggD55PohusaBNviGoOJ67HC6Btry4qXLVZc=",
      HMAC:SHA256_Base64("secret", "Message")
    ).
  end method.
    
end class.