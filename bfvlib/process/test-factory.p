

using bfvlib.process.Factory.

Factory:ReadDefinitions("bfvlib/process/factory-sample.json").


define variable dispatchert as bfvlib.pas.IRequestDispatcher no-undo.
dispatchert = {bfvlib/factory-get.i bfvlib.pas.IRequestDispatcher}.

message valid-object(dispatchert) view-as alert-box.

define variable overrided as bfvlib.process.async.IASyncProcess no-undo.
overrided = {bfvlib/factory-get.i bfvlib.process.async.IASyncProcess}

message valid-object(overrided) view-as alert-box.
