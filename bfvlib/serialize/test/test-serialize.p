
using OpenEdge.Core.Collections.List from propath.
using OpenEdge.Core.String from propath.
using Progress.IO.JsonSerializer from propath.
using Progress.Json.ObjectModel.JsonObject from propath.
using bfvlib.misc.JSON  from propath.
using bfvlib.serialize.SimpleJsonSerializer from propath.
using bfvlib.serialize.test.Address from propath.
using bfvlib.serialize.test.TestMessageOut from propath.
using bfvlib.serialize.SimpleJsonDeserializer.

define variable msg as TestMessageOut no-undo.
define variable targetObj as TestMessageOut no-undo.

define variable serializer as JsonSerializer no-undo.
define variable jsonOut as JsonObject no-undo.

msg = new TestMessageOut().
msg:Id = 1.
msg:To = "flusso".
msg:Type = "test".
msg:Created = now.
msg:Datum = today.
msg:Bedrag = 10.25.
msg:Active = true.

msg:Bla = new Progress.Lang.Object().
set-size(msg:mptr) = 7.
put-string(msg:mptr, 1) = "hoppa".
msg:AddKV("host", "home.oostermeyer").
msg:AddKV("protocol", "https").
msg:AddKV("port", "443").

msg:Recipients = new List().
msg:Recipients:Add(new String("flusso")).
msg:Recipients:Add(new String("gall")).
msg:Recipients:Add(new String("ahold")).

define variable addr as Address no-undo.

addr = new Address().
addr:Street = "Dorpstraat".
addr:HouseNumber = 1.
addr:Municipale = "Ons Dorp".
addr:Postcode = "1234AB".

msg:HouseAddress = addr.

define variable msgIn as bfvlib.serialize.test.TestMessageOut no-undo.

if (true) then do:

  define variable simpleSer as SimpleJsonSerializer no-undo.
  define variable simpleDeser as SimpleJsonDeserializer no-undo.
  
  simpleSer = new SimpleJsonSerializer().
  jsonOut = simpleSer:Serialize(msg, true).
  
  message string(JSON:Stringify(jsonOut, true)) view-as alert-box.
  clipboard:value = string(JSON:Stringify(jsonOut, true)).
  
  simpleDeser = new SimpleJsonDeserializer().
  msgIn = new TestMessageOut().
  simpleDeser:Deserialize(jsonOut, msgIn).
    
end.
else do:
  
  run serialize/oe-serialize.p(msg).
    
end.