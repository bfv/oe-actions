
define {&accessor} temp-table ttcustomer no-undo
  serialize-name "customers"
  field custnum as integer
  field custname as character
  field address as character
  .
  
define {&accessor} temp-table ttorder no-undo
  serialize-name "orders"
  field custnum as integer
  field ordernum as integer
  field price as decimal
  .
  
define dataset dsorder 
  serialize-name "customerorder"
  for ttcustomer, ttorder
  data-relation custord for ttcustomer, ttorder
   relation-fields (custnum, custnum)
   .
   