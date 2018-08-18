using bfvlib.serialize.test.TestTempTables.
using bfvlib.serialize.SimpleJsonSerializer.
using Progress.Json.ObjectModel.JsonObject.


define variable ttObj as TestTempTables no-undo.
define variable serializer as SimpleJsonSerializer no-undo.
define variable jsonResult as JsonObject no-undo.

ttObj = new TestTempTables().

serializer = new SimpleJsonSerializer().
serializer:DeserializeFile('d:/tmp/TestTempTable.json', ttObj).

message ttObj:ToString() view-as alert-box.
message 'done' view-as alert-box.
