
define input parameter cIn as character no-undo.
define output parameter cOut as character no-undo.

cOut = cIn + " " + iso-date(now).

message "ping: " + cOut.
  