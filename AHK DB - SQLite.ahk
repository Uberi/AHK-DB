#NoEnv

DB := new Database()
DB.Open("place")

class Database
{
    static DatabaseCount := 0 ;number of open databases
    static Suffix := A_IsUnicode ? "16" : "" ;suffix for functions
    static ReturnValues := Object("SQLITE_OK",         0  ;Successful result.
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

    ;create a database object
    __New(LibraryPath = "")
    {
        If Database.DatabaseCount = 0 ;no databases exist yet
        {
            If (LibraryPath = "") ;library path not given
                LibraryPath := A_ScriptDir . "\SQLite3.dll"
            this.hModule := DllCall("LoadLibrary","Str",LibraryPath) ;load the database library
            If !this.hModule
                throw Exception("Could not load database library from """ . LibraryPath . """.")
        }
        Database.DatabaseCount ++ ;increment the database count

        this.hDatabase := 0
    }

    ;open a database or create one if it does not exist
    Open(DatabaseFile = ":memory:") ;filename of the database (omit to create database in memory, or blank to create a database in a temporary file)
    {
        Value := DllCall("sqlite3\sqlite3_open","Str",DatabaseFile,"UPtr*",hDatabase,"CDecl Int") ;open the database file
        If (Value != this.ReturnValues["SQLITE_OK"]) ;failed to open database
            throw Exception("SQLite error " . Value . ".")
        this.hDatabase := hDatabase
        Return, this
    }

    

    __Delete()
    {
        Database.DatabaseCount --
        If Database.DatabaseCount = 0 ;all databases have been closed
            DllCall("FreeLibrary","UPtr",this.hModule), this.hModule := 0 ;free the database library
    }
}