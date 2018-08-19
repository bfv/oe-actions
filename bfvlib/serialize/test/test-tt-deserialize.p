using Progress.Json.ObjectModel.JsonObject.
using bfvlib.serialize.SimpleJsonDeserializer.
using bfvlib.serialize.test.TestTempTables.


define variable ttObj as TestTempTables no-undo.
define variable serializer as SimpleJsonDeserializer no-undo.
define variable jsonResult as JsonObject no-undo.

ttObj = new TestTempTables().

serializer = new SimpleJsonDeserializer().
serializer:DeserializeFile(session:temp-directory + 'TestTempTable.json', ttObj).

message ttObj:ToString() view-as alert-box.
message 'done' view-as alert-box.
