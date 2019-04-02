# serializing / deserializing
Although OpenEdge has serializing capabilities, the output may not be what is wanted. For example, OpenEdge places version info in the output JSON and all the property one level deeper.
The idea behind this (de-)serializer is to operator the same as one can expect when serializing JavaScript object.

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
