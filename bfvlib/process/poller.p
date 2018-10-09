
/* poller.p enables starting processes periodically. It's build around so called topic.
 * A topic can be "get-orders" or whatever. The poller has a semphore mechanism to prevent
 * these processes to start more than once.
 * To start a poller for a certain topic you have connect the db, -p bfvlib/process/poller.p and:
 * -param topic=get-orders,period=10
 * the period is in seconds. This configuration would check for orders every 10 seconds.
 * The topic is translated to a class (which must implement IExecutable) in the fillClassnames 
 * method. Currently this is hard coded. An IExecutable implementation can als inherit 
 * then PollProcess class for standardized logging.
 * When started the poller creates a <topic>.pid file. In this file is the PID of the process. 
 * If the pid file is deleted the poller shuts down.
 * 
 * Then there's a <topic>.log file, which abviously contains the logging.
 * If the poller needs to be paused, a <topic>.hold can be created. The poller keeps running,
 * but does not run the associated IExecutable until the <topic>.hold file is deleted.
 * 
 * By default the poller also creates a <topic>.alive to which an iso-date is written every 60s,
 * or period, if period > 60s. When the poller shuts down, the <topic>.alive is deleted as well.
 * If you don't need the alive file, it can be disabled via an isalive=false entry in the -param
 * comma separated list.
 * 
 * Lastly there is a so called cronmode, which prevents writing to the log when an attempt 
 * is made to start a second process on the same topic. It's called cronmode because sometimes
 * CRON (or whatever) is used to make sure an instance of the poller is running by starting it
 * say every 10 minutes. To prevent flooding the log add cronmode=true to -param
 * 
 * All the above mentioned files are created in the working directory of the poller
 */
 
using bfvlib.process.PollerInfo.
using bfvlib.process.IExecutable.

block-level on error undo, throw.

define variable params as PollerInfo no-undo.
define variable pidfilename as character no-undo.
define variable alivefilename as character no-undo.
define variable executable as IExecutable no-undo.
define variable processId as integer no-undo.
define variable clock as integer no-undo.
define variable holding as logical no-undo.
define variable previousDate as date init today no-undo.

define buffer semaphore for bfv_semaphore.

define stream pidfile.
define stream logfile.
define stream alivefile.

define temp-table ttpoller no-undo
  field topic as character
  field classname as character
  .

function getPollerProcess returns IExecutable(topicIn as character) forward.
function logThis returns logical (messageString as character) forward.   
function getProcessId returns integer() forward.
  
params = new PollerInfo().
processId = getProcessId().

run checkForOthers.

logThis(substitute("starting process '&1', pid: &2", params:Topic, processId)).

logThis(substitute("topic: &1", params:Topic)).
logThis(substitute("period: &1s", params:Period)).
logThis(substitute("alive status: &1", string(params:ReportIsAlive, "true/false"))).
logThis(substitute("cronmode: &1s", params:CronMode)).

alivefilename = "./" + params:Topic + ".alive".
  
/***** main loop *****/
do on error undo, throw:
    
  run writePidFile.
  
  executable = getPollerProcess(params:Topic).
  if (valid-object(executable)) then
    logThis(substitute("success starting process '&1', pid: &2", params:Topic, processId)).
  
  do while (search(pidfilename) <> ?):
    
    do on error undo, throw:
      
      if (search(params:Topic + ".hold") = ?) then do:
        if (clock mod params:Period = 0) then        
          executable:Execute().
        run evalHolding(false).
      end.
      else
        run evalHolding(true).
      
      catch err1 as Progress.Lang.Error :
        logThis("Execute() error: " + err1:GetMessage(1)).  
      end catch.
      
    end.
    
    if (params:ReportIsAlive) then
      run evalIsAlive.
  
    pause 1 no-message.  
    clock = clock + 1.
      
  end.
  
  catch err1 as Progress.Lang.Error:
    LogThis(substitute("ERROR: &1", err1:GetMessage(1))).
  end catch.
  
end.  // main loop

logThis(substitute("closing, pid: &1", processId)).

finally:
  os-delete value(alivefilename) no-error.
  os-delete value(pidfilename) no-error.
  logThis(substitute("closed, pid: &1", processId)).
end.


/************************************* procedures / functions *************************************/

procedure archiveLogfile private:
  
  define variable todayString as character no-undo.
  
  todayString = substitute("&1-&2-&3", year(today - 1), month(today - 1), day(today - 1)).
  os-copy value(params:Topic + ".log") value(params:Topic + "_" + todayString + ".log").
  os-delete value(params:Topic + ".log").
  
end procedure.

procedure checkForOthers private:

  /* attempt to exclusive lock the semaphore. If this fails the process is already running */
  do transaction on error undo, throw:
    
    find semaphore where semaphore.topic = params:Topic exclusive-lock no-wait no-error.
    if (locked(semaphore)) then do:
      if (not params:CronMode) then do:
        logThis(substitute("starting process '&1', pid: &2", params:Topic, processId)).
        logThis(substitute("process '&1' already running, exiting pid: &2", params:Topic, processId)).
      end.  
      quit.  
    end.
    
    if (not available(semaphore)) then do:
      create semaphore.
      assign semaphore.topic = params:Topic.
    end.
    
  end.  // transaction

end procedure.

/* vul de volgende procedure aan voor het registreren van een proces */
procedure fillClassnames:
  
  create ttpoller. 
  assign
    ttpoller.topic = "polltest" 
    ttpoller.classname = "bfvlib.process.TestPollProcess"
    .
      
end procedure.

function getPollerProcess returns IExecutable(topicIn as character):
  
  define variable pollerProcess as IExecutable no-undo.
  
  run fillClassnames.
  
  find ttpoller where ttpoller.topic = topicIn no-error.
  if (not available(ttpoller)) then do:
    logThis(substitute("no implementation specified for '&1'", topicIn)).
    os-delete value(pidfilename) no-error.
    return ?.
  end.
  
  pollerProcess = dynamic-new(ttpoller.classname)().
  
  return pollerProcess.
  
end function.

function logThis returns logical (messageString as character):
  
  if (previousDate <> today) then do:
    run archiveLogfile.
  end.
  
  /* open and close stream so the process can write it as well */ 
  output stream logfile to value(params:Topic + ".log") append.
  
  put stream logfile unformatted iso-date(now) " " messageString skip.
  
  finally:
    output stream logfile close.
    previousDate = today.
  end.
  
end function.

function getProcessId returns integer():
  
  define variable ppid as integer no-undo.
  
  if (opsys = "UNIX") then 
    run getpid(output ppid).
  else if opsys = "WIN32" then 
    run GetCurrentProcessId(output ppid).
  else
    assign ppid = ?.
  
  return ppid.
  
end function.

procedure getpid external "/usr/lib/libc.1":U cdecl:
  define return parameter ppid as LONG no-undo.
end procedure.

procedure GetCurrentProcessId external "kernel32.dll":U:
  define return parameter ppid as LONG no-undo.
end procedure.

procedure writePidFile:
  
  pidfilename = "./" + params:Topic + ".pid".
  output stream pidfile to value(pidfilename).
  put stream pidfile unformatted processId skip.
  output stream pidfile close.
  
  logThis(substitute("created pid file: &1", pidfilename)).
  
end procedure.  

procedure evalIsAlive:
  
  if (clock mod 60 = 0) then do:
    output stream alivefile to value(alivefilename).
    put stream alivefile unformatted iso-date(now) skip. 
    output stream alivefile close.
  end.
    
end procedure.

procedure evalHolding:
  
  define input parameter holdingFileFound as logical no-undo.
  
  if (holdingFileFound) then do:
    if (not holding) then do:
      logThis("holding...").
      holding = true.
    end.    
  end.
  else do:
    if (holding) then do:
      logThis("running...").
      holding = false.
    end.
  end.
      
end procedure.
