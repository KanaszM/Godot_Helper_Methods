# This function will create a .vbs script that will convert the excel file specified at path _source_path to the destination dir _destination_dir
# as the file type specified in the _conversion_type argument. The default number 62 represents the UTF8 CSV file format.
static func Convert_Excel_File(_source_path: String, _destination_dir: String, _conversion_type: int = 62) -> bool:
	var _result: bool = false
	var _valid_excel_extensions: PoolStringArray = PoolStringArray(["xls", "xlsx", "xlsm", "csv"])
	var _source_extension: String = _source_path.get_extension()
	var _source_filename: String = _source_path.get_file().get_slice(".", 0)
	if _source_extension in _valid_excel_extensions:
		var _destination_extension: String = ""
		match _conversion_type:
			6, 62: _destination_extension = ".csv"
		if not _destination_extension.empty():
			var _destination_path_copy: String = _destination_dir.plus_file(_source_filename + "." + _source_extension)
			var _destination_path_save: String = _destination_dir.plus_file(_source_filename + _destination_extension)
			var _vbs_script: PoolStringArray = PoolStringArray([
				"On Error Resume Next",
				"Process()",
				"Function Process",
				"	Const sSourceFile = \"" + _source_path.replace("/", "\\") + "\"",
				"	Const sDestinationFileCopy = \"" + _destination_path_copy.replace("/", "\\") + "\"",
				"	Const sDestinationFileSave = \"" + _destination_path_save.replace("/", "\\") + "\"",
				"	Dim oFSO",
				"	Set oFSO = CreateObject(\"Scripting.FileSystemObject\")",
				"	If oFSO.FileExists(sDestinationFileCopy) Then",
				"		oFSO.DeleteFile sDestinationFileCopy, True",
				"	End If",
				"	oFSO.CopyFile \"" + _source_path.replace("/", "\\")  + "\", \"" + _destination_dir.replace("/", "\\") + "\\\"",
				"	Dim oExcel",
				"	Set oExcel = CreateObject(\"Excel.Application\")",
				"	oExcel.Visible = False",
				"	oExcel.DisplayAlerts = False",
				"	oExcel.ScreenUpdating = False",
				"	oExcel.EnableEvents = False",
				"	Dim oWorkbook",
				"	Set oWorkbook = oExcel.Workbooks.Open(sDestinationFileCopy, False, True)",
				"	oWorkbook.SaveAs sDestinationFileSave, " + str(_conversion_type),
				"	oWorkbook.Close False",
				"	Set oWorkbook = Nothing",
				"	oExcel.Quit",
				"	Set oExcel = Nothing",
				"	Exit Function",
				"End Function"])
			var _vbs_file_path: String = OS.get_user_data_dir().plus_file("_csv_" + _source_filename + ".vbs")
			var _vbs_file: File = File.new()
			if _vbs_file.open(_vbs_file_path, _vbs_file.WRITE) == OK:
				for _vbs_line in _vbs_script: _vbs_file.store_line(_vbs_line)
				_vbs_file.close()
				OS.shell_open(_vbs_file_path)
				_result = true
	return _result

# This function will create a .vbs script that will open the directory specified in the _source_path argument
static func Open_Dir(_source_path: String) -> bool:
	var _result: bool = false
	var _vbs_file_path: String = OS.get_user_data_dir().plus_file("_dir_" + _source_path + ".vbs")
	var _vbs_source_path: String = _source_path.replace("/", "\\") + ("\\" if _source_path[_source_path.length() - 1] != "\\" else "")
	var _vbs_script: PoolStringArray = PoolStringArray([
		"Dim oShell", "Set oShell = wscript.CreateObject(\"Shell.Application\")",
		"oShell.Open \"" + _vbs_source_path + "\"",
		"Set oShell = Nothing", "WScript.Quit"])
	var _vbs_file: File = File.new()
	if _vbs_file.open(_vbs_file_path, _vbs_file.WRITE) == OK:
		for _vbs_line in _vbs_script: _vbs_file.store_line(_vbs_line)
		_vbs_file.close()
		OS.shell_open(_vbs_file_path)
		_result = true
	return _result

# This function will create a .vbs script that will open the specified file in the _source_path argument in Microsoft Windows Notepad
static func Open_With_Notepad(_source_path: String) -> void:
	var _vbs_file_path: String = OS.get_user_data_dir().plus_file("_notepad_" + _source_path.get_file().get_slice(".", 0) + ".vbs")
	var _file: File = File.new()
	if _file.open(_vbs_file_path, _file.WRITE) == OK:
		var _vbs_path: String = _source_path.replace("/", "\\")
		var _script: PoolStringArray = PoolStringArray([
			"With CreateObject(\"WScript.Shell\")",
			"	.Run \"notepad.exe " + _vbs_path + "\"",
			"End With",
			"Set oShell = Nothing", "WScript.Quit"])
		for _line in _script: _file.store_line(_line)
		_file.close()
		OS.shell_open(_vbs_file_path)

# This function will create a .vbs script that will open the specified file in the _source_path argument with a delay set in the _delay argument.
static func Open_With_Delay(_source_path: String, _delay: int = 1000) -> void:
	var _vbs_file_path: String = OS.get_user_data_dir().plus_file("_delay_" + _source_path.get_file().get_slice(".", 0) + ".vbs")
	var _file: File = File.new()
	if _file.open(_vbs_file_path, _file.WRITE) == OK:
		var _vbs_path: String = _source_path.replace("/", "\\")
		var _script: PoolStringArray = PoolStringArray([
			"WScript.sleep " + str(_delay),
			"Dim oShell", "Set oShell = WScript.CreateObject(\"WScript.Shell\")",
#			"Dim oExec", "Set oExec = oShell.Exec(\"" + _vbs_path + "\")"] # Alternative method
			"oShell.Run \"" + _vbs_path + "\"",
			"Set oShell = Nothing", "WScript.Quit"])
		for _line in _script: _file.store_line(_line)
		_file.close()
		OS.shell_open(_vbs_file_path)
