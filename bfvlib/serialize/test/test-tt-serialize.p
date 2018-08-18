
using bfvlib.serialize.test.TestTempTables.
using bfvlib.serialize.SimpleJsonSerializer.
using Progress.Json.ObjectModel.JsonObject.


define variable ttObj as TestTempTables no-undo.
define variable serializer as SimpleJsonSerializer no-undo.
define variable jsonResult as JsonObject no-undo.

ttObj = new TestTempTables().
ttObj:LoadClasses().

serializer = new SimpleJsonSerializer().
jsonResult = serializer:Serialize(ttObj).

jsonResult:WriteFile(session:temp-directory + 'TestTempTable.json').

message 'done' view-as alert-box.