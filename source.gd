### FILE MANIPULATION METHODS ###
# Get a list of complete filepaths starting from the specified _dir_path.
# You can use the _filter argument to get files of a specific extension.
# Recursive mode can be enabled/disabled with the _recursive argument.
# Set _skip_dirs to false if you do not want to return the folder paths
static func Get_Files(_dir_path: String, _filter: PoolStringArray = [], _recursive: bool = true, _skip_dirs: bool = false) -> PoolStringArray:
	var _result: PoolStringArray = []
	var _dir: Directory = Directory.new()
	if _dir.dir_exists(_dir_path):
		if _dir.open(_dir_path) == OK:
			_dir.list_dir_begin(true, true)
			var _current_file = _dir.get_next()
			while not _current_file.empty():
				if _dir.current_is_dir() and _recursive:
					_result.append_array(Get_Files(_dir_path.plus_file(_current_file), _filter, _skip_dirs))
				if not _dir.current_is_dir() or not _skip_dirs:
					var _valid_file: bool = true
					for _char in _current_file.get_file().length():
						if _current_file.get_file()[_char] in _filter: _valid_file = false
					if _valid_file and ("." + _current_file.get_extension() in _filter or _filter.empty()):
						_result.append(_dir_path.plus_file(_current_file))
				_current_file = _dir.get_next()
			_dir.list_dir_end()
	return _result

# This function will convert an .rtf file to an .gd file ready to be used in Godot.
# The optional _open argument will open de output file upon completion.
static func RTF_To_GD(_path_source_file: String, _path_output_DIR: String, _open: bool) -> void:
	var _source_file: File = File.new()
	var _output_file: File = File.new()
	var _source_prefix: String = "extends Node\nvar asPool: PoolStringArray = [\n"
	var _source_suffix: String = "\n]"
	var _output_path_file: String = _path_output_DIR.plus_file("output.gd")
	if _source_file.open(_path_source_file, _source_file.READ) == OK:
		if _output_file.open(_output_path_file, _source_file.WRITE) == OK:
			_output_file.store_line(_source_prefix)
			while not _source_file.eof_reached():
				var _source_file_line: String = _source_file.get_line().replace(char(92), "\\\\").replace(char(34), "\\\"")
				var _output_file_line: String = "\"" + _source_file_line + "\","
				_output_file.store_line(_output_file_line)
			_output_file.store_line(_source_suffix)
			_source_file.close()
			_output_file.close()
			if _open: OS.shell_open(_output_path_file)

# This function will delete all files from _dir_path if their extensions match the file extensions specified in the _file_extensions_to_clear argument.
# Recursive mode can be enabled/disabled with the _recursive argument.
static func Clear_Temp_Files(_dir_path: String, _file_extensions_to_clear: PoolStringArray, _recursive: bool = false) -> String:
	var _temp_dir: Directory = Directory.new()
	var _temp_files: PoolStringArray = Get_Files(_dir_path, _file_extensions_to_clear, _recursive)
	var _temp_clear_count: int = 0
	for _file_path in _temp_files:
		if _temp_dir.remove(_file_path) == OK: _temp_clear_count += 1
	return str("Cleared: " + str(_temp_clear_count) + " / " + str(_temp_files.size()))
