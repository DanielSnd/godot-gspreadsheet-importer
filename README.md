# Godot Google Spreadsheets Importer
This is an addon to assist with importing a game's database from Gooogle Spreadsheets. It gives you a way to create resource files for each row of the spreadsheet, and a way to retrieve those from a database autoload given a string id.

## Example Gif
![Example](https://github.com/DanielSnd/godot-gspreadsheet-importer/blob/main/readme_images/GodotDatabaseImporter.gif?raw=true)

## Setting up your spreadsheet

[This is my example spreadsheet](https://docs.google.com/spreadsheets/d/1O2IiDy7HqCbpHf4T6UYuBG8vl7J5Ykf-wY-35PZe_lQ/edit?usp=sharing). Feel free to make a copy and edit it.

![Spreadsheet](https://github.com/DanielSnd/godot-gspreadsheet-importer/blob/main/readme_images/spreadsheet.png?raw=true)

For this example I show how to reference a **sprite icon**, use **strings**, **ints** and **floats**, and also have a **dictionary** with extra information that can be written in **json** on the spreadsheet.

## Share your spreadsheet

For the importer to be able to access the spreadsheet it needs to be set up to share in a way that anyone with a link can view.

![Share](https://github.com/DanielSnd/godot-gspreadsheet-importer/blob/main/readme_images/share.png?raw=true)

![Share](https://github.com/DanielSnd/godot-gspreadsheet-importer/blob/main/readme_images/share_anyone_with_the_link.png?raw=true)

## Set your spreadsheet id on the importer

The spreadsheet ID needs to be set on "res://addons/godot-gspreadsheet-importer/**data_importer.gd**"

![Share](https://github.com/DanielSnd/godot-gspreadsheet-importer/blob/main/readme_images/set_spreadsheet_id.png?raw=true)

