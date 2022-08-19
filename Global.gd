extends Node

var data_GA = File.new()
var time = OS.get_datetime()
var day = time["day"]
var month = time["month"]
var year = time["year"]
var hour = time["hour"]
var minute = time["minute"]
var second = time["second"]
var data_GA_path = "user://saves/data_GA(" + str(day) + "-" + str(month) + "-" + str(year) + "_" + str(hour) + ";" + str(minute) + ";" + str(second) + ").txt"


var point
var npcLifetime
var npcDmg

var npcStat = {}

var best = false
var bestIndividu = {"fitness" : 0, "stat" : null}
var HP_player
var HP_FS
var HP_FL

func _ready():
	data_GA.open(data_GA_path, File.WRITE)

func write_files(isi):
	data_GA.store_line(str(isi))
#	file.close()

func stop_write():
	data_GA.close()

func reset():
	npcLifetime = {
		1 : 0,
		2 : 0,
		3 : 0,
		4 : 0
	}
	npcDmg = {
		1 : {"player" : 0, "tower" : 0, "rumah" : 0},
		2 : {"player" : 0, "tower" : 0, "rumah" : 0},
		3 : {"player" : 0, "tower" : 0, "rumah" : 0},
		4 : {"player" : 0, "tower" : 0, "rumah" : 0}
		
	}
