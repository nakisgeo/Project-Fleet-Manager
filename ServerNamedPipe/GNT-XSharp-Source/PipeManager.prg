// PipeManager.prg
#using System
#using System.Collections
#using System.Threading
#using System.Web
#using System.IO
#using System.Configuration
#using System.Diagnostics

#using AppModule.InterProcessComm
#using AppModule.NamedPipes

SEALED ;
CLASS PipeManager IMPLEMENTS IChannelManager
    // Fields
    PRIVATE _listen := TRUE AS LOGIC
    PRIVATE _pipes := System.Collections.Hashtable{} AS System.Collections.Hashtable
    PRIVATE InBuffer := 512 AS DWORD
    PRIVATE OutBuffer := 512 AS DWORD
    //PRIVATE InBuffer := 65535 AS DWORD
    //PRIVATE OutBuffer := 65535 AS DWORD
    PRIVATE MainThread AS System.Threading.Thread
    ///*const*/ PRIVATE MAX_READ_BYTES := 5000 AS INT
    /*const*/ PRIVATE MAX_READ_BYTES := 16767 AS INT
    PRIVATE Mre AS System.Threading.ManualResetEvent
    PRIVATE NumberPipes := 5 AS DWORD
    PRIVATE numChannels := 0 AS INT
    /*const*/ PRIVATE PIPE_MAX_STUFFED_TIME := 5000 AS INT
    PRIVATE PipeName := "SoftwayCommunicatorPipe" AS STRING
    EXPORT Pipes AS System.Collections.Hashtable
    EXPORT SyncRoot := OBJECT{} AS OBJECT

    // Methods
    //VIRTUAL METHOD HandleRequest(request AS STRING) AS STRING
    METHOD HandleRequest(request AS STRING) AS STRING
        //ServerForm.ActivityRef:AppendText(String.Concat(request, System.Environment.NewLine))
        //wb(String.Concat(request, System.Environment.NewLine))
        RETURN STRING.Concat("Response to: ", request)

    //VIRTUAL METHOD Initialize() AS VOID
    METHOD Initialize() AS VOID
		IF cLicensedCompany:ToUpper():StartsWith("SEASCAPE") //.or. cLicensedCompany:ToUpper():StartsWith("SOFTWAY")
			SELF:PipeName += oUser:UserID
		ENDIF
        //
        SELF:Pipes := System.Collections.Hashtable.Synchronized(SELF:_pipes)
        SELF:Mre := System.Threading.ManualResetEvent{FALSE}
        SELF:MainThread := System.Threading.Thread{System.Threading.ThreadStart{ SELF, @MyStart() }}
        SELF:MainThread:IsBackground := TRUE
        SELF:MainThread:Name := "Softway Communicator Pipe"
        SELF:MainThread:Start()
		//wb(SELF:MainThread:Name, "PipeManager:Initialize")
        System.Threading.Thread.Sleep(1000)

    //VIRTUAL METHOD RemoveServerChannel(param AS OBJECT) AS VOID
    METHOD RemoveServerChannel(param AS OBJECT) AS VOID
        LOCAL handle AS INT
        //
        handle := (INT)param 
        System.Threading.Interlocked.Decrement(SELF:numChannels)
        SELF:Pipes:Remove(handle)
        SELF:WakeUp()

    PRIVATE METHOD MyStart() AS VOID
        LOCAL keys AS INT[]
        //LOCAL key AS INT
        //LOCAL Fab_FOE_key AS System.Collections.IEnumerator
        //LOCAL Fab_FOE_key_M AS System.Reflection.MethodInfo
        LOCAL serverPipe AS ServerNamedPipe
        LOCAL pipe AS ServerNamedPipe
        //
        TRY
            //
            WHILE (SELF:_listen)
                //
                keys := INT[]{SELF:Pipes:Keys:Count}
                SELF:Pipes:Keys:CopyTo(keys, 0)
    //            Fab_FOE_key := keys:GetEnumerator()
    //            TRY
    //                WHILE ( Fab_FOE_key:MoveNext() ) 
    //                    key :=  ( INT ) Fab_FOE_key:Current
    //                    //
    //                    serverPipe := (ServerNamedPipe)SELF:Pipes:Item[key] 
    //                    IF (((serverPipe != NULL) .and. (System.DateTime.Now:Subtract(serverPipe:LastAction):Milliseconds > 0X1388)) .and. (serverPipe:PipeConnection:GetState() != InterProcessConnectionState.WaitingForClient))
    //                        //
    //                        serverPipe:Listen := FALSE
    //                        serverPipe:PipeThread:Abort()
    //                        SELF:RemoveServerChannel(serverPipe:PipeConnection:NativeHandle)
    //                    ENDIF
    //                ENDDO
				//CATCH e AS Exception
				//	ErrorBox(e:Message)
    //            FINALLY
    //                IF ( typeof(System.IDisposable):IsAssignableFrom( Fab_FOE_key:GetType() ) ) 
    //                    Fab_FOE_key_M := (Fab_FOE_key:GetType()):GetMethod( "Dispose")
    //                    IF ( Fab_FOE_key_M != NULL  ) 
    //                        Fab_FOE_key_M:Invoke( (OBJECT) Fab_FOE_key, NULL )
    //                    ENDIF
    //                ENDIF
    //            END TRY

				FOREACH key AS INT IN keys
					serverPipe := (ServerNamedPipe)SELF:Pipes[key]
					//IF serverPipe <> NULL
					//	memowrit(cTempDocDir+"\t1.txt", serverPipe:PipeThread:Name)
					//ENDIF
					IF (serverPipe != NULL && DateTime.Now:Subtract(serverPipe:LastAction):Milliseconds > PIPE_MAX_STUFFED_TIME && serverPipe:PipeConnection:GetState() != InterProcessConnectionState.WaitingForClient)
						serverPipe:Listen := FALSE
						serverPipe:PipeThread:Abort()
						SELF:RemoveServerChannel(serverPipe:PipeConnection:NativeHandle)
					ENDIF
				NEXT

//wb("SELF:numChannels <= SELF:NumberPipes: "+(SELF:numChannels <= SELF:NumberPipes):ToString())
				//memowrit(cTempDocDir+"\t2.txt", "SELF:numChannels <= SELF:NumberPipes: "+(SELF:numChannels <= SELF:NumberPipes):ToString())
                IF (SELF:numChannels <= SELF:NumberPipes)
                    //
                    pipe := ServerNamedPipe{SELF:PipeName, SELF:OutBuffer, SELF:InBuffer, MAX_READ_BYTES, FALSE}
                    TRY
                        //
                        pipe:Connect()
                        pipe:LastAction := System.DateTime.Now
                        System.Threading.Interlocked.Increment(SELF:numChannels)
                        pipe:Start()
                        SELF:Pipes:Add(pipe:PipeConnection:NativeHandle, pipe)
						//memowrit(cTempDocDir+"\t3.txt", pipe:PipeConnection:ToString())
                    CATCH ex AS InterProcessIOException
						ErrorBox(ex:Message, "Error connection to Pipe")
                        //
                        SELF:RemoveServerChannel(pipe:PipeConnection:NativeHandle)
                        pipe:Dispose()
                    END TRY
                ELSE
                    //
                    SELF:Mre:Reset()
                    SELF:Mre:WaitOne(1000, FALSE)
                ENDIF
            ENDDO
        CATCH e AS Exception //obj1 as Object
			ErrorBox(e:Message)
        END TRY

    METHOD Stop() AS VOID
    //VIRTUAL METHOD Stop() AS VOID
        LOCAL keys AS INT[]
        //LOCAL key AS INT
        //LOCAL Fab_FOE_key AS System.Collections.IEnumerator
        //LOCAL Fab_FOE_key_M AS System.Reflection.MethodInfo
        LOCAL i AS INT
        LOCAL j AS INT
        //
        SELF:_listen := FALSE

		TRY
	        SELF:Mre:@@Set()
		CATCH
		END TRY

		TRY
			keys := INT[]{Pipes:Keys:Count}
			SELF:Pipes:Keys:CopyTo(keys, 0)
			FOREACH key AS INT IN keys
				((ServerNamedPipe)SELF:Pipes[key]):Listen := FALSE
			NEXT
			i := numChannels * 3
			FOR j := 0 UPTO i - 1
				StopServerPipe()
			NEXT
			Pipes:Clear()
			Mre:Close()
			Mre := NULL
		CATCH
			// Log exception
		END TRY

   //     TRY
   //         //
   //         keys := INT[]{SELF:Pipes:Keys:Count}
   //         SELF:Pipes:Keys:CopyTo(keys, 0)
   //         Fab_FOE_key := keys:GetEnumerator()
   //         TRY
   //             WHILE ( Fab_FOE_key:MoveNext() ) 
   //                 key :=  ( INT ) Fab_FOE_key:Current
   //                 //
   //                 ((ServerNamedPipe)SELF:Pipes:Item[key]):Listen := FALSE
			//	ENDDO
			//CATCH
   //         FINALLY
   //             IF ( typeof(System.IDisposable):IsAssignableFrom( Fab_FOE_key:GetType() ) ) 
   //                 Fab_FOE_key_M := (Fab_FOE_key:GetType()):GetMethod( "Dispose")
   //                 IF ( Fab_FOE_key_M != NULL  ) 
   //                     Fab_FOE_key_M:Invoke( (OBJECT) Fab_FOE_key, NULL )
   //                 ENDIF
   //             ENDIF
   //         END TRY

   //         i := (SELF:numChannels * 3)
   //         j := 0
   //         WHILE ((j < i))
   //             //
   //             SELF:StopServerPipe()
   //             j++
   //         ENDDO
   //         SELF:Pipes:Clear()
   //         SELF:Mre:Close()
   //         SELF:Mre := NULL
   //     CATCH //obj1 as Object

   //     END TRY
  RETURN

    PRIVATE METHOD StopServerPipe() AS VOID
        LOCAL pipe AS ClientPipeConnection
        //
        TRY
            //
            pipe := ClientPipeConnection{SELF:PipeName}
            IF (pipe:TryConnect())
                //
                pipe:Close()
            ENDIF
        CATCH //obj1 as Object

        END TRY

    METHOD WakeUp() AS VOID
    //VIRTUAL METHOD WakeUp() AS VOID
        //
        IF (SELF:Mre != NULL)
            //
            SELF:Mre:@@Set()
        ENDIF


    // Properties
    PROPERTY Listen AS LOGIC
    //VIRTUAL PROPERTY Listen AS LOGIC
        //VIRTUAL GET
        GET
            //
            RETURN SELF:_listen
        END GET

        //VIRTUAL SET
        SET
            //
            SELF:_listen := VALUE
        END SET
    END PROPERTY

END CLASS
