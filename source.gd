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
