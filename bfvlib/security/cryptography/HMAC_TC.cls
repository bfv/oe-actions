 
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
  method public void HMAC_SHA256_empty():
    Assert:Equals(
      HMAC:SHA256_Hex("", ""),
      "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad" 
    ).
  end method.

  @Test.
  method public void HMAC_SHA256_quickfox():
    Assert:Equals(
      HMAC:SHA256_Hex("key", "The quick brown fox jumps over the lazy dog"),
      "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8" 
    ).
  end method.
    
  @Test.
  method public void HMAC_SHA1_empty():
    Assert:Equals(
      HMAC:SHA1_Hex("", ""),
      "fbdb1d1b18aa6c08324b7d64b71fb76370690e1d" 
    ).
  end method.

  @Test.
  method public void HMAC_SHA1_quickfox():
    Assert:Equals(
      HMAC:SHA1_Hex("key", "The quick brown fox jumps over the lazy dog"),
      "de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9" 
    ).
  end method.
    
  @Test.
  method public void HMAC_MD5_empty():
    Assert:Equals(
      HMAC:MD5_Hex("", ""),
      "74e6f7298a9c2d168935f58c001bad88"
    ).
  end method.

  @Test.
  method public void HMAC_MD5_quickfox():
    Assert:Equals(
      HMAC:MD5_Hex("key", "The quick brown fox jumps over the lazy dog"),
      "80070713463e7749b90c2dc24911e275"
    ).
  end method.
    
end class.