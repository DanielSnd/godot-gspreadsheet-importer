@tool
extends Control
class_name DataImporter

signal imported_data(import_type: String, data: Array)

# Change this ID to your spreadsheet id, you can find it in the link to your spreadsheet
# https://docs.google.com/spreadsheets/d/Your id will appear here/edit#gid=0
const SPREADSHEET_ID: String = "1O2IiDy7HqCbpHf4T6UYuBG8vl7J5Ykf-wY-35PZe_lQ"

@onready var buttons:VBoxContainer = $MarginContainer/Buttons
@onready var debug_checkbox:CheckBox = $MarginContainer/Buttons/DebugCheckbox

# Called when the node enters the scene tree for the first time.
func _ready():
	# When the dock is created it looks for buttons under the buttons vboxcontainer
	# If a button is called Import Something, it will split the button name and use the
	# part after the space to look for a sheet on the spreadsheet with that name.
	# In the case of "Import Items" it looks for a sheet on the spreadsheet called "Items"
	for x in buttons.get_children():
		var button:= x as Button
		if (button != null && button.text.split(" ")[0] == "Import"):
			button.pressed.connect(on_import_pressed.bind(parse_button_string(button.text)))

func parse_button_string(button_string: String) -> String:
	return button_string.split(" ")[1]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_import_pressed(import_type: String):
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self.on_import_completed.bind(import_type))
	var desired_url = get_spreadsheet_url(import_type)
	
	var error = http_request.request(desired_url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

# Called when the HTTP request is completed.
func on_import_completed(result, response_code, headers, body, data_type):
	var data_csv = body.get_string_from_utf8()
	if debug_checkbox.button_pressed == true:
		print(data_csv)
	var parsedCsv: Array = parseCSV(data_csv)
	if debug_checkbox.button_pressed == true:
		print(parsedCsv)
	imported_data.emit(data_type, parsedCsv)

func get_spreadsheet_url(sheet_id: String) -> String:
	return "https://docs.google.com/a/google.com/spreadsheets/d/{0}/gviz/tq?tqx=out:csv&sheet={1}".format({0:SPREADSHEET_ID,1: sheet_id});

func parseCSV(data: String) -> Array:
	var lines : Array = get_all_csv_lines(data)
	var columnNames := []
	var entries := []

	for i in range(lines.size()):
		var line: String= lines[i]
		var contents: Array = get_csv_line(line)

		if i == 0: # Spreadsheet titles
			for j in range(contents.size()):
				var columnID: String = contents[j].replace(" ", "")
				columnNames.append(columnID)
		elif contents.size() > 0:
			var key: String = contents[0]
			if key == "" or key == null:
				if contents.size() > 1:
					key = contents[1]
				else:
					continue # Skip entries with empty keys (the other values can be used as labels)
			var entryDict := {}
			for j in range(contents.size()):
				if j < columnNames.size() and j < contents.size():
					entryDict[columnNames[j]] = contents[j]
				else:
					print("<color=red>Something went wrong</color>")
			entries.append(entryDict)
			
	return entries
	
func get_all_csv_lines(data: String) -> Array:
	var lines := []
	var i := 0
	var searchCloseTags := 0
	var lastSentenceStart := 0
	
	while i < data.length():
		if data[i] == '"':
			searchCloseTags = (searchCloseTags + 1) if searchCloseTags == 0 else (searchCloseTags - 1)
		elif data[i] == '\n':
			if searchCloseTags == 0:
				lines.append(data.substr(lastSentenceStart, i - lastSentenceStart))
				lastSentenceStart = i + 1
		i += 1
	if i - 1 > lastSentenceStart:
		lines.append(data.substr(lastSentenceStart, i - lastSentenceStart))
	return lines

func get_csv_line(line: String) -> Array:
	var list := []
	var i := 0
	var searchCloseTags := 0
	var lastEntryBegin := 0
	while i < line.length():
		if line[i] == '"':
			searchCloseTags = (searchCloseTags + 1) if searchCloseTags == 0 else (searchCloseTags - 1)
		elif line[i] == ',':
			if searchCloseTags == 0:
				list.append(strip_quotes(line.substr(lastEntryBegin, i - lastEntryBegin)))
				lastEntryBegin = i + 1
		i += 1
	if line.length() > lastEntryBegin:
		list.append(strip_quotes(line.substr(lastEntryBegin))) # Add last entry
	return list

func strip_quotes(input: String) -> String:
	if input.length() < 1 or input[0] != '"':
		return input # Not a " formatted line
	var output := ""
	var i := 1
	var allowNextQuote := false
	while i < input.length() - 1:
		var curChar := input[i]
		if curChar == '"':
			if allowNextQuote:
				output += curChar
			allowNextQuote = !allowNextQuote
		else:
			output += curChar
		i += 1
	return output
