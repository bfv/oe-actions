
using bfvlib.serialize.test.SimpleObject.
using bfvlib.serialize.SimpleJsonDeserializer.

define variable obj as SimpleObject no-undo.
define variable deserializer as SimpleJsonDeserializer no-undo.

deserializer = new SimpleJsonDeserializer().
obj = new SimpleObject().

obj = cast(
  deserializer:DeserializeFile(search('bfvlib/serialize/test/missingprop.json'), "bfvlib.serialize.test.SimpleObject"),
  "bfvlib.serialize.test.SimpleObject"
).

message obj:Prop1 obj:Prop2 view-as alert-box.
