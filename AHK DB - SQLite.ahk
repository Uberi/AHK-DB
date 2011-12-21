#NoEnv

DB := new Database()
DB.Open("place")

class Database
{
 static DatabaseCount := 0 ;number of open databases
 static Suffix := A_IsUnicode ? "16" : "" ;suffix for functions

 ;create a database object
 __New(LibraryPath = "")
 {
  If (Database.DatabaseCount = 0) ;no databases exist yet
  {
   If (LibraryPath = "") ;library path not given
    LibraryPath := A_ScriptDir . "\SQLite3.dll"
   This.hModule := DllCall("LoadLibrary","UPtr",&LibraryPath) ;load the database library
  }
  Database.DatabaseCount ++ ;increment the database count
 }

 ;open a database or create one if it does not exist
 Open(DatabaseFile = ":memory:") ;filename of the database (omit to create database in memory, or blank to create a database in a temporary file)
 {
  Value := DllCall("sqlite3\sqlite3_open","UPtr",&DatabaseFile,"UPtr*",hDatabase,"CDecl Int") ;open the database file
  If (Value != This.ReturnValue("SQLITE_OK")) ;failed to open database
   Throw Exception("SQLite error " . Value . " (" . Database.ReturnValue(Value) . ").",-1)
  Return, This
 }

 ReturnValue(Code)
 {
  static Values := Object("SQLITE_OK",         0  ;Successful result.
                         ,"SQLITE_ERROR",      1  ;SQL error or missing database
                         ,"SQLITE_INTERNAL",   2  ;Internal logic error in SQLite
                         ,"SQLITE_PERM",       3  ;Access permission denied
                         ,"SQLITE_ABORT",      4  ;Callback routine requested an abort
                         ,"SQLITE_BUSY",       5  ;The database file is locked
                         ,"SQLITE_LOCKED",     6  ;A table in the database is locked
                         ,"SQLITE_NOMEM",      7  ;A malloc() failed
                         ,"SQLITE_READONLY",   8  ;Attempt to write a readonly database
                         ,"SQLITE_INTERRUPT",  9  ;Operation terminated by sqlite3_interrupt()
                         ,"SQLITE_IOERR",     10  ;Some kind of disk I/O error occurred
                         ,"SQLITE_CORRUPT",   11  ;The database disk image is malformed
                         ,"SQLITE_NOTFOUND",  12  ;Unknown opcode in sqlite3_file_control()
                         ,"SQLITE_FULL",      13  ;Insertion failed because database is full
                         ,"SQLITE_CANTOPEN",  14  ;Unable to open the database file
                         ,"SQLITE_PROTOCOL",  15  ;Database lock protocol error
                         ,"SQLITE_EMPTY",     16  ;Database is empty
                         ,"SQLITE_SCHEMA",    17  ;The database schema changed
                         ,"SQLITE_TOOBIG",    18  ;String or BLOB exceeds size limit
                         ,"SQLITE_CONSTRAINT",19  ;Abort due to constraint violation
                         ,"SQLITE_MISMATCH",  20  ;Data type mismatch
                         ,"SQLITE_MISUSE",    21  ;Library used incorrectly
                         ,"SQLITE_NOLFS",     22  ;Uses OS features not supported on host
                         ,"SQLITE_AUTH",      23  ;Authorization denied
                         ,"SQLITE_FORMAT",    24  ;Auxiliary database format error
                         ,"SQLITE_RANGE",     25  ;2nd parameter to sqlite3_bind out of range
                         ,"SQLITE_NOTADB",    26  ;File opened that is not a database file
                         ,"SQLITE_ROW",      100  ;sqlite3_step() has another row ready
                         ,"SQLITE_DONE",     101) ;sqlite3_step() has finished executing
  Return, Values[Code]
 }

 ReturnCode(Value)
 {
  static Codes := Object(0,"SQLITE_OK"         ;Successful result.
                        ,1,"SQLITE_ERROR"      ;SQL error or missing database
                        ,2,"SQLITE_INTERNAL"   ;Internal logic error in SQLite
                        ,3,"SQLITE_PERM"       ;Access permission denied
                        ,4,"SQLITE_ABORT"      ;Callback routine requested an abort
                        ,5,"SQLITE_BUSY"       ;The database file is locked
                        ,6,"SQLITE_LOCKED"     ;A table in the database is locked
                        ,7,"SQLITE_NOMEM"      ;A malloc() failed
                        ,8,"SQLITE_READONLY"   ;Attempt to write a readonly database
                        ,9,"SQLITE_INTERRUPT"  ;Operation terminated by sqlite3_interrupt()
                       ,10,"SQLITE_IOERR"      ;Some kind of disk I/O error occurred
                       ,11,"SQLITE_CORRUPT"    ;The database disk image is malformed
                       ,12,"SQLITE_NOTFOUND"   ;Unknown opcode in sqlite3_file_control()
                       ,13,"SQLITE_FULL"       ;Insertion failed because database is full
                       ,14,"SQLITE_CANTOPEN"   ;Unable to open the database file
                       ,15,"SQLITE_PROTOCOL"   ;Database lock protocol error
                       ,16,"SQLITE_EMPTY"      ;Database is empty
                       ,17,"SQLITE_SCHEMA"     ;The database schema changed
                       ,18,"SQLITE_TOOBIG"     ;String or BLOB exceeds size limit
                       ,19,"SQLITE_CONSTRAINT" ;Abort due to constraint violation
                       ,20,"SQLITE_MISMATCH"   ;Data type mismatch
                       ,21,"SQLITE_MISUSE"     ;Library used incorrectly
                       ,22,"SQLITE_NOLFS"      ;Uses OS features not supported on host
                       ,23,"SQLITE_AUTH"       ;Authorization denied
                       ,24,"SQLITE_FORMAT"     ;Auxiliary database format error
                       ,25,"SQLITE_RANGE"      ;2nd parameter to sqlite3_bind out of range
                       ,26,"SQLITE_NOTADB"     ;File opened that is not a database file
                      ,100,"SQLITE_ROW"        ;sqlite3_step() has another row ready
                      ,101,"SQLITE_DONE")      ;sqlite3_step() has finished executing
  Return, Codes[Value]
 }

 __Delete()
 {
  Database.DatabaseCount --
  If (Database.DatabaseCount = 0) ;all databases have been closed
   DllCall("FreeLibrary","UPtr",This.hModule), This.hModule := 0 ;free the database library
 }
}