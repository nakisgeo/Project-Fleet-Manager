// Folder.prg
// Created by    : JJV-PC
// Creation Date : 1/28/2020 12:22:55 PM
// Created for   : 
// WorkStation   : DESKTOP-8HPCFRC
//Folder Structure

USING System
USING System.Collections.Generic
USING System.Linq
USING System.Text

CLASS Folder
	PROPERTY Level AS INT AUTO
	PROPERTY Name AS STRING AUTO
	PROPERTY Subfolders AS List<Folder> AUTO
		
	PRIVATE _ParentId AS STRING
	PRIVATE _MyId AS STRING
	
	
	CONSTRUCTOR()
	RETURN
	CONSTRUCTOR(cLevel AS INT, cName AS STRING)
		Level := cLevel
		Name := cName
		RETURN
	
	PUBLIC METHOD ToString() AS STRING
		RETURN Name
	
	PUBLIC METHOD ConsolePrint() AS VOID
		LOCAL result AS STRING
		LOCAL i AS INT
		FOR i := 0 TO Level
			result += e"\t"
		NEXT
		result += i"- {Name}"
//		Subfolders:ForEach({o => i"{Environment.NewLine}{o:ToString()}"})
		RETURN
	
	// Μετά την προσθήκη της GetMeAndMyChildren είναι άχρηστο
//	PUBLIC METHOD GetDeepth() AS INT
//		TRY
//		IF Subfolders:Count > 0
//			RETURN Subfolders:Max({o => o:GetDeepth()})
//		ENDIF
//		CATCH ex AS Exception
//			RETURN Level
//		END TRY
//		RETURN Level
		
			
	PUBLIC METHOD GetMeAndMyChildren() AS List<Folder>
		LOCAL folders := List<Folder>{} AS List<Folder>
		folders:Add(SELF)		
		IF !(Subfolders == NULL_OBJECT)
			Subfolders:ForEach({o => o:GetMeAndMyChildren():ForEach({p => folders:Add(p)})})
		ENDIF		
		
		RETURN folders
		
	PUBLIC METHOD SetParentId(parentId AS STRING) AS VOID
		_ParentId := parentId
		RETURN
	PUBLIC METHOD GetParentId() AS STRING
		RETURN _ParentId
	PUBLIC METHOD SetMyId(myId AS STRING) AS VOID
		_MyId := myId
		IF Subfolders == NULL_OBJECT
			RETURN
		ENDIF		
		Subfolders:ForEach({o => o:SetParentId(myId)})
		RETURN
		


	
END CLASS