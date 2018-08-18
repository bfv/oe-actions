
using bfvlib.serialize.test.SimpleObject.
using bfvlib.serialize.SimpleJsonSerializer from propath.

define variable obj as SimpleObject no-undo.
define variable serializer as SimpleJsonSerializer no-undo.

serializer = new SimpleJsonSerializer().
obj = new SimpleObject().

obj = cast(
  serializer:DeserializeFile(search('bfvlib/serialize/test/missingprop.json'), "bfvlib.serialize.test.SimpleObject"),
  "bfvlib.serialize.test.SimpleObject"
).

message obj:Prop1 obj:Prop2 view-as alert-box.
