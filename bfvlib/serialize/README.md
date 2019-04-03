# serializing / deserializing
Although OpenEdge has serializing capabilities, the output may not be what is wanted. For example, OpenEdge places version info in the output JSON and all the property one level deeper.
The idea behind this (de-)serializer is to operate the same as one can expect when serializing JavaScript objects.

Suppose you want to serialize this class:

```
class SimpleObject serializable:
  define public property Prop1 as character no-undo get. set.
  define public property Prop2 as character no-undo get. set.
  define public property Prop3 as character no-undo get. set.
end class.
```
OpenEdge produces the following JSON:

```
{
  "prods:version": 1,
  "prods:objId": 1,
  "SimpleObject": {
    "Prop1": "",
    "Prop2": "",
    "Prop3": ""
  }
}
```

Whereas the ideal output would be:
```
{
  "Prop1": "",
  "Prop2": "",
  "Prop3": ""
}
```

The serializer serializes all the public properties. Temp-tables cannot be found by refleaction and therefor the class to be serialized need to implement the `bfvlib.serialize.ISerializableDataStructure` interface. An example can be found in `bfvlib.serialize.test.TestTempTables`:
```
  method public IMap GetDataStructures():

    define variable dataStructs as IMap no-undo.

    dataStructs = new Map().
    dataStructs:Put(new String("definitions"), new WidgetHandle(temp-table ttfactorydef:handle)).

    return dataStructs.

  end method.
```

The class will be serialized as:

```
{
    "definitions": [
        {
            "topic": "bol.com:order",
            "classname": "channel.processors.BolOrderProcessor"
        },
        {
            "topic": "gallweb:order",
            "classname": "channel.processors.GallProcessor"
        }
    ]
}
```

Serializing an object is as simple as:

```
define variable obj as SimpleObject no-undo.
define variable serializer as SimpleJsonSerializer no-undo.
define variable resultString as longchar no-undo.

obj = new SimpleObject().
serializer = new SimpleJsonSerializer().

resultString = serializer:SerializeToLongchar(obj).
```

The object can be serialized to a `JsonObject` as well by the `Serialize` method.

## deserializing
Since OpenEdge lacks the flexibility when it comes to turning JSON into objects you have to know what JSON (i.e. the structure) of what you will receive.

So suppose you expect to receive something like:
```
{
  "version": "1.0",
  "active": true,
  "rows": [
    { "field1": "hello", "field2": "world" },
    { "field1": "openedge", "field2": "12.0" }
  ]
}
```
A receiving class could look like, note the GetDataStructures method where you define in what node you expect to receive the contents for the temp-table.

```
using bfvlib.serialize.ISerializableDataStructure.
using OpenEdge.Core.*.

block-level on error undo, throw.

class bfvlib.serialize.test.CompoundObject implements ISerializableDataStructure:

  define public property version as character no-undo get. set.
  define public property active as logical no-undo get. set.

  define private temp-table ttfield no-undo
    field field1 as character
    field field2 as character
    .


  method public IMap GetDataStructures():

    define variable dataStructs as IMap no-undo.

    dataStructs = new Map().
    dataStructs:Put(new String("rows"), new WidgetHandle(temp-table ttfield:handle)).

    return dataStructs.

  end method.

end class.
```
