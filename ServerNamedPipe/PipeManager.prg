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
class PipeManager implements IChannelManager
    // Fields
    private _listen := true as Logic
    private _pipes := System.Collections.Hashtable{} as System.Collections.Hashtable
    private InBuffer := 0x200 as DWord
    private MainThread as System.Threading.Thread
    /*const*/ private MAX_READ_BYTES := 0x1388 as Long
    private Mre as System.Threading.ManualResetEvent
    private NumberPipes := 5 as DWord
    private numChannels := 0 as Long
    private OutBuffer := 0x200 as DWord
    /*const*/ private PIPE_MAX_STUFFED_TIME := 0x1388 as Long
    PRIVATE PipeName := "SoftwayFleetManagerPipe" AS STRING
    EXPORT Pipes AS System.Collections.Hashtable
    EXPORT SyncRoot := OBJECT{} AS OBJECT

    // Methods
    VIRTUAL METHOD HandleRequest(request AS STRING) AS STRING
        //ServerForm.ActivityRef:AppendText(String.Concat(request, System.Environment.NewLine))
        //wb(String.Concat(request, System.Environment.NewLine))
        RETURN STRING.Concat("Response to: ", request)

    VIRTUAL METHOD Initialize() AS VOID
        //
        SELF:Pipes := System.Collections.Hashtable.Synchronized(SELF:_pipes)
        SELF:Mre := System.Threading.ManualResetEvent{FALSE}
        SELF:MainThread := System.Threading.Thread{System.Threading.ThreadStart{ SELF, @MyStart() }}
        SELF:MainThread:IsBackground := TRUE
        SELF:MainThread:Name := "Softway FleetManager Pipe"
        SELF:MainThread:Start()
        System.Threading.Thread.Sleep(0X3E8)

    VIRTUAL METHOD RemoveServerChannel(param AS OBJECT) AS VOID
        LOCAL handle AS LONG
        //
        handle := (LONG)param 
        System.Threading.Interlocked.Decrement(SELF:numChannels)
        SELF:Pipes:Remove(handle)
        SELF:WakeUp()

    PRIVATE METHOD MyStart() AS VOID
        LOCAL keys AS LONG[]
        LOCAL key AS LONG
        LOCAL Fab_FOE_key AS System.Collections.IEnumerator
        LOCAL Fab_FOE_key_M AS System.Reflection.MethodInfo
        LOCAL serverPipe AS ServerNamedPipe
        LOCAL pipe AS ServerNamedPipe
        //
        TRY
            //
            WHILE (SELF:_listen)
                //
                keys := LONG[]{SELF:Pipes:Keys:Count}
                SELF:Pipes:Keys:CopyTo(keys, 0)
                Fab_FOE_key := keys:GetEnumerator()
                TRY
                    WHILE ( Fab_FOE_key:MoveNext() ) 
                        key :=  ( LONG ) Fab_FOE_key:Current
                        //
                        serverPipe := (ServerNamedPipe)SELF:Pipes:Item[key] 
                        IF (((serverPipe != NULL) .and. (System.DateTime.Now:Subtract(serverPipe:LastAction):Milliseconds > 0X1388)) .and. (serverPipe:PipeConnection:GetState() != InterProcessConnectionState.WaitingForClient))
                            //
                            serverPipe:Listen := FALSE
                            serverPipe:PipeThread:Abort()
                            SELF:RemoveServerChannel(serverPipe:PipeConnection:NativeHandle)
                        ENDIF
                    ENDDO
                FINALLY
                    IF ( typeof(System.IDisposable):IsAssignableFrom( Fab_FOE_key:GetType() ) ) 
                        Fab_FOE_key_M := (Fab_FOE_key:GetType()):GetMethod( "Dispose")
                        IF ( Fab_FOE_key_M != NULL  ) 
                            Fab_FOE_key_M:Invoke( (OBJECT) Fab_FOE_key, NULL )
                        ENDIF
                    ENDIF
                END TRY

//wb("SELF:numChannels <= SELF:NumberPipes: "+(SELF:numChannels <= SELF:NumberPipes):ToString())
                IF (SELF:numChannels <= SELF:NumberPipes)
                    //
                    pipe := ServerNamedPipe{SELF:PipeName, SELF:OutBuffer, SELF:InBuffer, 0X1388, FALSE}
                    TRY
                        //
                        pipe:Connect()
                        pipe:LastAction := System.DateTime.Now
                        System.Threading.Interlocked.Increment(SELF:numChannels)
                        pipe:Start()
                        SELF:Pipes:Add(pipe:PipeConnection:NativeHandle, pipe)
                    CATCH ex AS InterProcessIOException
						ErrorBox(ex:Message, "Error connection to Pipe")
                        //
                        SELF:RemoveServerChannel(pipe:PipeConnection:NativeHandle)
                        pipe:Dispose()
                    END TRY
                ELSE
                    //
                    SELF:Mre:Reset()
                    SELF:Mre:WaitOne(0X3E8, FALSE)
                ENDIF
            ENDDO
        CATCH e AS Exception //obj1 as Object
			ErrorBox(e:Message)
        END TRY

    VIRTUAL METHOD Stop() AS VOID
        LOCAL keys AS LONG[]
        LOCAL key AS LONG
        LOCAL Fab_FOE_key AS System.Collections.IEnumerator
        LOCAL Fab_FOE_key_M AS System.Reflection.MethodInfo
        LOCAL i AS LONG
        LOCAL j AS LONG
        //
        SELF:_listen := FALSE
        SELF:Mre:@@Set()
        TRY
            //
            keys := LONG[]{SELF:Pipes:Keys:Count}
            SELF:Pipes:Keys:CopyTo(keys, 0)
            Fab_FOE_key := keys:GetEnumerator()
            TRY
                WHILE ( Fab_FOE_key:MoveNext() ) 
                    key :=  ( LONG ) Fab_FOE_key:Current
                    //
                    ((ServerNamedPipe)SELF:Pipes:Item[key]):Listen := FALSE
                ENDDO
            FINALLY
                IF ( typeof(System.IDisposable):IsAssignableFrom( Fab_FOE_key:GetType() ) ) 
                    Fab_FOE_key_M := (Fab_FOE_key:GetType()):GetMethod( "Dispose")
                    IF ( Fab_FOE_key_M != NULL  ) 
                        Fab_FOE_key_M:Invoke( (OBJECT) Fab_FOE_key, NULL )
                    ENDIF
                ENDIF
            END TRY

            i := (SELF:numChannels * 3)
            j := 0
            WHILE ((j < i))
                //
                SELF:StopServerPipe()
                j++
            ENDDO
            SELF:Pipes:Clear()
            SELF:Mre:Close()
            SELF:Mre := NULL
        CATCH //obj1 as Object

        END TRY

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

    VIRTUAL METHOD WakeUp() AS VOID
        //
        IF (SELF:Mre != NULL)
            //
            SELF:Mre:@@Set()
        ENDIF


    // Properties
    VIRTUAL PROPERTY Listen AS LOGIC
        //VIRTUAL GET
        GET
            //
            RETURN SELF:_listen
        END GET

        //VIRTUAL SET
        SET
            //
            SELF:_listen := value
        END SET
    END PROPERTY

END CLASS
