 
 /*------------------------------------------------------------------------
    File        : JWT_TC
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Oct 03 20:43:51 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using bfvlib.security.JWT.
using OpenEdge.Core.Assert.

class bfvlib.security.JWT_TC:
    
  @Test.
  method public void ReadUnsignedJwt():
    
    define variable jwtToken as character no-undo.
    define variable jwt as JWT no-undo.
    
    jwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2Jmdi5pbyIsInN1YiI6Imp3dCBkZWNvZGUgaW4gb3BlbmVkZ2UiLCJhdWQiOiJodHRwczovL3RoZXdob2xld29ybGQuY29tIiwiZXhwIjoxNzM1NjkzMjAwLCJpYXQiOjE1MTQ3Njg0MDB9.".
    
    jwt = new JWT("hoppa").
    jwt:Decode(jwtToken).
     
    Assert:Equals("https://bfv.io", jwt:Issuer).
    Assert:Equals("jwt decode in openedge", jwt:Subject).
    Assert:Equals("https://thewholeworld.com", jwt:Audience).
    Assert:Equals(datetime-tz(1, 1, 2018, 0, 0, 0), jwt:IssuedAt).
    Assert:Equals(datetime-tz(1, 1, 2025, 0, 0, 0), jwt:Expiration).

  end method.
  
  @Test.
  method public void ReadSignedJwt():
    
    define variable jwtToken as character no-undo.
    define variable jwt as JWT no-undo.
    
    jwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2Jmdi5pbyIsInN1YiI6Imp3dCBkZWNvZGUgaW4gb3BlbmVkZ2UiLCJhdWQiOiJodHRwczovL3RoZXdob2xld29ybGQuY29tIiwiZXhwIjoxNzM1NjkzMjAwLCJpYXQiOjE1MTQ3Njg0MDB9.7aLP9mnuRNeKuIsVvyp48bUVnWf9shaW1a8eeVQIT6Y=".
    
    jwt = new JWT("hoppa").
    jwt:Decode(jwtToken).
    
    Assert:Equals("https://bfv.io", jwt:Issuer).
    Assert:Equals("jwt decode in openedge", jwt:Subject).
    Assert:Equals("https://thewholeworld.com", jwt:Audience).
    Assert:Equals(datetime-tz(1, 1, 2018, 0, 0, 0), jwt:IssuedAt).
    Assert:Equals(datetime-tz(1, 1, 2025, 0, 0, 0), jwt:Expiration).
    
  end method.
  
  @Test(expected="Progress.Lang.AppError").
  method public void ReadJwtWithIncorrectSignture():
    
    define variable jwtToken as character no-undo.
    define variable jwt as JWT no-undo.
    
    jwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2Jmdi5pbyIsInN1YiI6Imp3dCBkZWNvZGUgaW4gb3BlbmVkZ2UiLCJhdWQiOiJodHRwczovL3RoZXdob2xld29ybGQuY29tIiwiZXhwIjoxNzM1NjkzMjAwLCJpYXQiOjE1MTQ3Njg0MDB9.DELIBERATE_ERROR".
    
    jwt = new JWT("hoppa").
    jwt:Decode(jwtToken).
     
  end method.
  
end class.