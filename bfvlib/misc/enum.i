&if defined(constructor) = 0 &then
class {&package}.{&class} inherits bfvlib.misc.Enum final: 

  constructor private {&class} (enumValue as character, enumName as character):
    super(enumValue, enumName).
  end constructor. 
    
&global-define constructor true    
&endif

&if defined(val) <> 0 &then
  &global-define intvalenum  true
&endif

&if defined(enum) <> 0 &then
  define public static property {&enum} as {&package}.{&class} no-undo 
    get():
      if not valid-object ({&package}.{&class}:{&enum})then
          &if defined(val) = 0 and defined(stringval) = 0 &then 
        assign {&package}.{&class}:{&enum} = new {&package}.{&class} ("{&enum}", trim("{&enum}")).
          &elseif defined(val) = 0 and defined(stringval) <> 0 &then 
      assign 
        {&package}.{&class}:{&enum} = new {&package}.{&class} ("{&stringval}", trim("{&enum}")).
          &else
      assign 
        {&package}.{&class}:{&enum} = new {&package}.{&class} ("{&val}", trim("{&enum}")).
          &endif
      return {&package}.{&class}:{&enum}.
    end get. 
    private set. 
&endif

&if defined(val) = 0 and defined(stringval) = 0 &then
  &global-define enumValues {&enumValues},{&enum}
  &global-define enumNames {&enumNames},{&enum} 
&elseif defined(val) = 0 and defined(stringval) <> 0 &then
  &global-define enumValues {&enumValues},{&stringval}
  &global-define enumNames {&enumNames},{&enum} 
&else
  &global-define enumValues {&enumValues},{&val}
  &global-define enumNames {&enumNames},{&enum}
&endif


&if defined(valuelist) <> 0 &then
  /* this section must be included after the last enum member */
  define public static property Values as character no-undo
    get():
      return trim("{&enumValues}",",").
    end get.

  define public static property Names as character no-undo
    get():
      return trim("{&enumNames}",",").
    end get.

  define public property Ordinal as integer no-undo
    get():
      return lookup(this-object:Value, trim("{&enumValues}",",")).
    end get.

  method public static logical IsValidEnum (enumValue as character):
    return lookup(enumValue, trim("{&enumValues}",",")) > 0.
  end method.

  method public static logical IsValidEnumName (enumName as character):
    return lookup(enumName, trim("{&enumNames}",",")) > 0.
  end method.

  method public static {&package}.{&class} GetEnum (enumValue as character):
    define variable returnValue as {&package}.{&class} no-undo.
    define variable enumName as character no-undo.
      
    do on error undo, throw:
      enumName = entry(lookup(enumValue, trim("{&enumValues}", ","), ","), trim("{&enumNames}", ",")).
      returnValue = dynamic-property("{&package}.{&class}", enumName).
      catch err1 as Progress.Lang.Error :
        undo, throw new bfvlib.misc.InvalidEnumException(string(enumValue), "{&package}.{&class}").  
      end catch.
    end.
    return returnValue.
  end method.

  method public static {&package}.{&class} GetEnumByName (enumName as character):
    define variable returnValue as {&package}.{&class} no-undo.
      
    do on error undo, throw:
      returnValue = dynamic-property("{&package}.{&class}", enumName).
      catch err1 as Progress.Lang.Error :
        undo, throw new bfvlib.misc.InvalidEnumException(string(enumName), "{&package}.{&class}").  
      end catch.
    end.
    return returnValue.
  end method.
    
  method public static character GetEnumDescription():
    define variable i as integer no-undo.
    define variable numNames as integer no-undo.
    define variable outputString as character no-undo.
      
    outputString = "{&package}.{&class}:~n".
    numNames = num-entries(this-object:Names).
    do i = 1 to numNames:
      outputString = outputString + "  " + entry(i, Names) + "=" + entry(i, {&package}.{&class}:Values) + "~n". 
    end.
      
    return outputString.
      
  end method.
&endif

&if defined(getvaluemethod) = 0 and defined(intvalenum) <> 0 &then
  method public integer GetValue():
    return integer(this-object:Value).
  end method.
&global-define getvaluemethod true
&endif

&if defined(valuelist) <> 0 and defined(getenummethod) = 0 &then
  
  &if defined(getvaluemethod) <> 0 &then
  method public static {&package}.{&class} GetEnum(enumValue as integer):
    define variable returnValue as {&package}.{&class} no-undo.
    define variable enumName as character no-undo.
    
    do on error undo, throw:
      enumName = entry(lookup(string(enumValue), trim("{&enumValues}", ",")), trim("{&enumNames}", ",")).
      returnValue = dynamic-property("{&package}.{&class}", enumName).
      catch err1 as Progress.Lang.Error :
        undo, throw new bfvlib.misc.InvalidEnumException(string(enumValue), "{&package}.{&class}").	
      end catch.
    end.
    return returnValue.
  end method.
  &endif
  &global-define getenummethod true
&endif
