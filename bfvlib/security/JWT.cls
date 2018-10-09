 
 /*------------------------------------------------------------------------
    File        : JWT
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Oct 03 20:19:51 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using bfvlib.security.cryptography.HMAC.
using OpenEdge.Core.Collections.StringStringMap.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Lang.AppError.
using Progress.Json.ObjectModel.ObjectModelParser.

block-level on error undo, throw.

class bfvlib.security.JWT final: 
  
  define public property SignKey as character no-undo private get. set.
  
  // header
  define public property Algorithm as character no-undo get. set.  // HMAC RSA256
  define public property Type as character no-undo get. private set.
  
  //payload
  define public property Issuer as character no-undo get. set.
  define public property Subject as character no-undo get. set.
  define public property Audience as character no-undo get. set.
  define public property Expiration as datetime-tz no-undo get. set.      
  define public property NotBefore as datetime-tz no-undo get. set.      
  define public property IssuedAt as datetime-tz no-undo get. set.       
  define public property Indentifier as character no-undo get. set.
  
  define private variable otherClaims as StringStringMap  no-undo.
    
  constructor public JWT():
    
  end constructor.
  
  constructor public JWT(signKey as character):
    this-object:SignKey = signKey.
  end.
  
  method public void Decode(jwtToken as character):
    
    define variable headerPart as character no-undo.
    define variable payloadPart as character no-undo.
    define variable signaturePart as character no-undo.
    
    do on error undo, throw:
      
      assign 
        headerPart = entry(1, jwtToken, ".")
        payloadPart = entry(2, jwtToken, ".")
        signaturePart = entry(3, jwtToken, ".")
        .
      
      if (signaturePart > "" and not isSignatureOK(headerPart, payloadPart, signaturePart)) then
        undo, throw new AppError("Signuture not OK", -1).
        
      this-object:processParts(headerPart, payloadPart).
        
      catch err1 as Progress.Lang.Error :
        undo, throw new AppError(substitute("ERROR, not a valid JWT: &1", err1:GetMessage(1))).
      end catch.
      
    end.
    
  end method.
  
 
  method private void processParts(headerPart as character, payloadPart as character):
    
    define variable json as JsonObject no-undo.
    define variable jsonString as longchar no-undo.
    define variable i as integer no-undo.
    
   
    json = this-object:toJsonObject(headerPart).
    processPart(json).
    
    json = this-object:toJsonObject(payloadPart).
    processPart(json).
    
  end method.
  
  
  method private void processPart(json as JsonObject):
    
    define variable i as integer no-undo.
    define variable properties as character extent no-undo.
    define variable numProperties as integer no-undo.
    define variable propertyValue as character no-undo.
    
    properties = json:GetNames().
    numProperties = extent(properties).
    
    do i = 1 to numProperties:
      
      case (properties[i]):
        
        when "alg" then 
          this-object:Algorithm = json:GetCharacter(properties[i]).
          
        when "typ" then 
          this-object:Type = json:GetCharacter(properties[i]).
        
        when "exp" then
          this-object:Expiration = add-interval(datetime-tz(1, 1, 1970, 0, 0, 0), json:GetInt64(properties[i]), "seconds").
        
        when "iss" then
          this-object:Issuer = json:GetCharacter(properties[i]).
          
        when "aud" then
          this-object:Audience = json:GetCharacter(properties[i]).
          
        when "sub" then
          this-object:Subject = json:GetCharacter(properties[i]).

        when "iat" then 
          this-object:IssuedAt = add-interval(datetime-tz(1, 1, 1970, 0, 0, 0), json:GetInt64(properties[i]), "seconds").
          
        when "nbf" then 
          this-object:NotBefore = add-interval(datetime-tz(1, 1, 1970, 0, 0, 0), json:GetInt64(properties[i]), "seconds").
          
        otherwise do:
          
        end.
          
      end case.
        
    end.
    
  end method.
  
  
  
  method private JsonObject toJsonObject(base64EncodedString as character):
    
    define variable decodedMemptr as memptr no-undo.
    define variable decodedString as longchar no-undo.
    define variable json as JsonObject no-undo.
    define variable parser as ObjectModelParser no-undo.
    
    decodedMemptr = base64-decode(base64EncodedString).
    copy-lob decodedMemptr to decodedString. 
    
    parser = new ObjectModelParser().
    json = cast(parser:Parse(decodedString), "JsonObject").
    
    return json.
    
  end method.
  
  method public override character ToString():
    
    define variable resultString as character no-undo.
    
    resultString = 
      "Header" +
      "~n  Algorithm (alg): " + this-object:Algorithm +
      "~n  Type (typ): " + this-object:Type +
      "~n~nPayload: " + 
      (if (this-object:Issuer > "") then "~n  Issuer (iss): " + this-object:Issuer else "") +
      (if (this-object:Subject > "") then "~n  Subject (sub): " + this-object:Subject else "") +
      (if (this-object:Audience > "") then "~n  Audience (aud): " + this-object:Audience else "") +
      (if (this-object:Expiration <> ?) then "~n  Expiration (exp): " + iso-date(this-object:Expiration) else "") +
      (if (this-object:IssuedAt <> ?) then "~n  IssuedAt (iat): " + iso-date(this-object:IssuedAt) else "") +
      (if (this-object:NotBefore <> ?) then "~n  NotBefore (nbf): " + iso-date(this-object:NotBefore) else "") +
      ""
      .
      
     return resultString.
     
  end method.
  
  /** returns true if signature is OK */
  method private logical isSignatureOK(headerPart as character, payloadPart as character, signaturePart as character):
    
    define variable headerPlusPayload as character no-undo.
    define variable signatureOK as logical no-undo.
    
    headerPlusPayload = headerPart + "." + payloadPart.
    signatureOK = right-trim(HMAC:SHA256_Base64("hoppa", headerPlusPayload), "=)") = right-trim(signaturePart, "=").
    
    return signatureOK.
    
  end method.
  
  /*
  method public void AddClaim(claimCode as character, claimValue as character):
    
  end method.
  
  method public character Sign(signKey as character):
    
  end method.
  
  method public character GetUnsignedJWT():
    
  end method.
  
  method public character getHeader():
    
    define variable json as JsonObject no-undo.
    define variable jsonString as longchar no-undo.
    define variable jsonMemptr as memptr no-undo.
    
    json = new JsonObject().
    json:Add("type", this-object:Type).
    json:Add("alg", this-object:Algorithm).
    
    json:Write(jsonString, true).
    copy-lob jsonString to jsonMemptr.
    
    return string(base64-encode(jsonMemptr)).
    
    finally:
      set-size(jsonMemptr) = 0.
    end.
  end method.
  */
end class.

/*
{
  "alg": "HS256",
  "typ": "JWT"
}

{
  "iss": "https://bfv.io",
  "sub": "jwt decode in openedge",
  "aud": "https://thewholeworld.com",
  "exp": 1735693200,
  "iat": 1514768400
}
*/