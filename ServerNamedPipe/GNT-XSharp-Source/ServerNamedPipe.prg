// ServerNamedPipe.prg
#USING System
#USING System.Threading
#USING System.IO

#USING AppModule.InterProcessComm
#USING AppModule.NamedPipes

SEALED ;
CLASS ServerNamedPipe IMPLEMENTS System.IDisposable
    // Fields
    private disposed := false as Logic
    internal LastAction as System.DateTime
    internal Listen := true as Logic
    internal PipeConnection as ServerPipeConnection
    internal PipeThread as System.Threading.Thread

    // Methods
	INTERNAL  CONSTRUCTOR(name AS STRING, outBuffer AS DWORD, inBuffer AS DWORD, maxReadBytes AS INT, secure AS LOGIC)
		super()
        //
        self:PipeConnection := ServerPipeConnection{name, outBuffer, inBuffer, maxReadBytes, secure}
        self:PipeThread := System.Threading.Thread{System.Threading.ThreadStart{ self, @PipeListener() }}
        self:PipeThread:IsBackground := true
        self:PipeThread:Name := String.Concat("Pipe Thread ", self:PipeConnection:NativeHandle:ToString())
        SELF:LastAction := System.DateTime.Now
         //wb("ServerNamedPipe", name)

    PRIVATE METHOD CheckIfDisposed() AS LOGIC
        //IF SELF:disposed
        //    THROW System.ObjectDisposedException{"ServerNamedPipe"}
        //ENDIF
    RETURN SELF:disposed

    INTERNAL METHOD Close() AS VOID
        IF ! SELF:CheckIfDisposed()
            SELF:Listen := FALSE
            //ServerForm.PipeManager:RemoveServerChannel(SELF:PipeConnection:NativeHandle)
			TRY
				MainForm.PipeManager:RemoveServerChannel(SELF:PipeConnection:NativeHandle)
			CATCH
			END TRY
            //SELF:Dispose()	// Removed at 28/01/2016
        ENDIF
    RETURN

    INTERNAL METHOD Connect() AS VOID
        IF ! SELF:CheckIfDisposed()
            SELF:PipeConnection:Connect()
        ENDIF

    METHOD Dispose() AS VOID
    //VIRTUAL METHOD Dispose() AS VOID
        self:Dispose(true)
        System.GC.SuppressFinalize(self)

    private method Dispose(disposing as Logic) as void
        //
        if (! self:disposed)
            //
            self:PipeConnection:Dispose()
            if (self:PipeThread != null)
                //
                try
                    //
                    self:PipeThread:Abort()
//                catch ex as System.Threading.ThreadAbortException

//                CATCH ex AS System.Threading.ThreadStateException

                CATCH //ex AS System.Exception

                END TRY
            ENDIF
        ENDIF
        SELF:disposed := TRUE

//  //protected virtual method Finalize() as void
//  PROTECTED VIRTUAL METHOD Destructor() AS VOID
	METHOD Destructor() AS VOID
        // The Finalize() is automatically handled by Vulcan if replaced with Destructor()
        //TRY
            SELF:Dispose(FALSE)
       // FINALLY
            //
            ////Super:Finalize()
            //SUPER:Destructor()
        //END TRY

    PRIVATE METHOD PipeListener() AS VOID
        LOCAL request, cNamedPipeTag := NULL AS STRING
        IF SELF:CheckIfDisposed()
            RETURN
        ENDIF
        TRY
            //SELF:Listen := ServerForm.PipeManager:Listen
            SELF:Listen := MainForm.PipeManager:Listen
            //ServerForm.ActivityRef:AppendText(STRING.Concat("Pipe ", SELF:PipeConnection:NativeHandle:ToString(), ": new pipe started", System.Environment.NewLine))
            WHILE (SELF:Listen)
                //
                SELF:LastAction := System.DateTime.Now
                request := SELF:PipeConnection:Read()
                SELF:LastAction := System.DateTime.Now
                IF (request:Trim() != "")
                    //SELF:PipeConnection:Write(ServerForm.PipeManager:HandleRequest(request))
                    SELF:PipeConnection:Write(MainForm.PipeManager:HandleRequest(request + "Handle: "+oMainForm:Handle:ToString()))
					// Tag | UIDs
					request := SELF:AnalyseRequest(request, cNamedPipeTag)
                    //ServerForm.ActivityRef:AppendText(STRING.Concat("Pipe ", SELF:PipeConnection:NativeHandle:ToString(), ": request handled", System.Environment.NewLine))

                    // Update MainForm's UID list:
                    MainForm.cNamedPipeTag := cNamedPipeTag
                    MainForm.TBNamedPipeUIDsRef:Clear()
                    MainForm.TBNamedPipeUIDsRef:AppendText(request)
                ELSE
                    //
                    SELF:PipeConnection:Write("Error: bad request")
                ENDIF
                SELF:LastAction := System.DateTime.Now
                SELF:PipeConnection:Disconnect()
                IF (SELF:Listen)
                    //ServerForm.ActivityRef:AppendText(STRING.Concat("Pipe ", SELF:PipeConnection:NativeHandle:ToString(), ": listening", System.Environment.NewLine))
                    SELF:Connect()
                ENDIF
                //ServerForm.PipeManager:WakeUp()
                MainForm.PipeManager:WakeUp()
            ENDDO

//        CATCH ex AS System.Threading.ThreadAbortException

//        CATCH ex AS System.Threading.ThreadStateException

        CATCH //ex AS System.Exception

        FINALLY
            SELF:Close()
        END TRY
    RETURN


	METHOD AnalyseRequest(request AS STRING, cNamedPipeTag REF STRING) AS STRING
		LOCAL cStr := "" AS STRING
		LOCAL nPos := AT("|", request) AS DWORD
		IF nPos == 0
			cNamedPipeTag := ""
			RETURN request
		ENDIF
		cNamedPipeTag := Left(request, nPos - 1)
		cStr := SubStr(request, nPos + 1)
	RETURN cStr


    INTERNAL METHOD Start() AS VOID
        IF ! SELF:CheckIfDisposed()
            SELF:PipeThread:Start()
        ENDIF
    RETURN

END CLASS
