extends Node

var enemy_stat = {}
var HP = range(50, 100+1)
var ATK = range(10, 15+1)
var ASPD = range(1, 2+1)
var SPD = range(0, 25+1, 5)

func bangkit_populasi():
	print("-----------------PEMBANGKITAN POPULASI AWAL------------------")
	Global.write_files("-----------------PEMBANGKITAN POPULASI AWAL------------------")
	for i in range (4):
		var status = {
			"HP" : HP[int(rand_range(0, HP.size()))],
			"ATK" : ATK[int(rand_range(0, ATK.size()))],
			"ASPD" : ASPD[int(rand_range(0, ASPD.size()))],
			"SPD" : SPD[int(rand_range(0, SPD.size()))]
		}
		
		enemy_stat[i+1] = status
	return enemy_stat

func AlgoritmaGenetika(lifetime, DMGtotal, currentStat, currHP_FL, currHP_FS, currHP_Player):
	enemy_stat = GA.new(lifetime, DMGtotal, currentStat, currHP_FL, currHP_FS, currHP_Player)
	print(enemy_stat)
	return Global.npcStat

class GA:
	const Pc = 0.7
	const Pm = 0.7
	var jmlIndividu = 0
	
	func _init(alltime, alldmg, allstat, cHP_FL, cHP_FS, cHP_Player):
		var time = alltime
		var dmg = alldmg
		var stat = allstat
		var cFL = cHP_FL
		var cFS = cHP_FS
		var cP = cHP_Player
		var iter
		var fitness = []
		var total_fitness = 0
		var Pf = []
		jmlIndividu = allstat.size()
		
		print("-----------------FITNESS------------------")
		Global.write_files("-----------------FITNESS------------------")
		for i in range(jmlIndividu):
			var ID = stat.keys()[i]
			var totalDmg = 0
			for subDmg in dmg[ID]:
				var Dmg = dmg[ID][subDmg]
				totalDmg += Dmg
			var hitRecive = stat[ID]["HP"] / 15
			var hitDealt = totalDmg / stat[ID]["ATK"]
			var totalATK_Time = time[ID]["attack_state_time"]
			var lifeTime = time[ID]["life_time"]
			var wondererTime = lifeTime - totalATK_Time
			var totalPassedBuilding = time[ID]["passed_building"]
			var buildingTimeAVG = float(wondererTime) / totalPassedBuilding
			
			var pembilang = (float(totalDmg) + stat[ID]["HP"] - totalATK_Time)
			var penyebut = buildingTimeAVG
			
			if penyebut <= 0:
				penyebut *= -1
				
			var fit =  pembilang / penyebut
			fitness.push_back(fit)
			total_fitness += fit
		
		for f in fitness:
			if total_fitness == 0:
				Pf.push_back(0)
			else:
				Pf.push_back(float(f)/total_fitness)
		print("Fitness = ", fitness, "\nTotal Fitness = ", total_fitness, "\n\n")
		Global.write_files("Fitness = " + str(fitness) + "\nTotal Fitness = " + str(total_fitness) + "\n\n")
		
		bestindividu(fitness, stat)
		
#		if cekPerulangan(fitness, stat):
#			return Global.npcStat
		
		print("-----------------SELEKSI------------------")
		Global.write_files("-----------------SELEKSI------------------")
		var PKf = []
		for i in range(Pf.size()):
			var temp = 0
			for j in range(i+1):
				temp += Pf[j]
			PKf.push_back(temp)
		
		print("Probabilitas Fitness = ", Pf, 
		"\nProbabilitas Komulatif = ", PKf, "\nRANDOM : ")
		Global.write_files("Probabilitas Fitness = " + str(Pf) + 
		"\nProbabilitas Komulatif = " + str(PKf) + "\nRANDOM : ")
		
		var induk = {}
		for i in range(jmlIndividu):
			induk[i] = seleksi(PKf, stat)
		
		print("Induk terpilih :\n", induk, "\n\n")
		Global.write_files("Induk terpilih :\n" + str(induk) + "\n\n")
		
		print("-----------------CROSSOVER------------------\n",
		"Probabilitas CrossOver = ", self.Pc)
		Global.write_files("-----------------CROSSOVER------------------\n" +
		"Probabilitas CrossOver = " + str(self.Pc))
		var offsprings = {}
		iter = 0
		for i in range(0, jmlIndividu, 2):
			iter += 1
			var induk1 = induk[i]
			var induk2 = induk[i+1]
			print("** Persilangan individu ", induk1, " & individu ", induk2, " **")
			Global.write_files("** Persilangan individu " + str(induk1) + " & individu " + str(induk2) + " **")
			offsprings[iter] = crossover(induk1, induk2)
		
#		print("Hasil CrossOver :")
		var newpop = {}
		iter = 0
		for couple in offsprings:
#			print("Pasangan ", couple, ":")
			for npc in offsprings[couple]:
				iter += 1
				newpop[iter] = offsprings[couple][npc]
#				print(npc, " : ", newpop[iter])
		print("\n")
		Global.write_files("\n")
		
		print("-----------------MUTASI------------------\n",
		"Probabilitas Mutasi = ", self.Pm)
		Global.write_files("-----------------MUTASI------------------\n" +
		"Probabilitas Mutasi = " + str(self.Pm))
#		iter = 0
		var hasil = {}
		for i in newpop:
			print("> Mutasi Individu ", i, " :\nIndividu ", i, " = ", newpop[i])
			Global.write_files("> Mutasi Individu " + str(i) + " :\nIndividu " + str(i) + " = " + str(newpop[i]))
			var temp = newpop[i].values()
			hasil[i] = mutasi(temp, i)
		
#		print("Hasil Mutasi :")
#		for id in hasil:
#			print(id, ":", hasil[id])
		print("\n")
		Global.write_files("\n")
		
		Global.npcStat = hasil
		Global.reset()
		return Global.npcStat
	
	func seleksi(Prob, allstat):
		randomize()
		var allStatus = allstat
		var Rs = rand_range(0, 1)
		var Pk = Prob
		print(Rs)
		Global.write_files(str(Rs))
		var individuID = 1
		
		for pf in Pk:
			if Rs >= pf:
				individuID += 1
			if individuID == 5:
				individuID = 1
		
		var terpilih = {"HP" : allStatus[individuID]["HP"],
						"ATK" : allStatus[individuID]["ATK"],
						"ASPD" : allStatus[individuID]["ASPD"],
						"SPD" : allStatus[individuID]["SPD"]}
		return terpilih
	
	func crossover(induk1, induk2):
		var i1 = induk1
		var i2 = induk2
		var Prob_crossover = self.Pc
		var Randoms = {}
		print("Induk 1 = ", i1, "\nInduk 2 = ", i2)
		Global.write_files("Induk 1 = " + str(i1) + "\nInduk 2 = " + str(i2))
		for kromosom in i1:
			randomize()
			var Rc = rand_range(0, 1)
			Randoms[kromosom] = Rc
			if Rc <= Prob_crossover:
				var temp = i1[kromosom]
				i1[kromosom] = i2[kromosom]
				i2[kromosom] = temp
		print("\tRANDOM : ", Randoms)
		Global.write_files("\tRANDOM : " + str(Randoms))
		print(
		"\tAnakan 1 = ", i1,
		"\n\tAnakan 2 = ", i2)
		Global.write_files("\tAnakan 1 = " + str(i1) +
		"\n\tAnakan 2 = " + str(i2))
		var isi = {1 : i1, 2 : i2}
		return isi
		
	func mutasi(npc, i):
		
		var individu = npc
		var Prob_mutasi = self.Pm
		var newIndividu = {}
		var Randoms = []
		var indeks = range(0, individu.size())
		var Rm = []
		for _i in range(2):
			randomize()
			var j = int(rand_range(0, indeks.size()))
			Rm.push_back(indeks[j])
			indeks.remove(j)
		for kromosom in individu.size():
			var jenis
			if kromosom == Rm[0] or kromosom == Rm[1]:
				var nilai_sebelum = individu[kromosom]
				match kromosom:
					0 : 
						jenis = "HP"
						var HP = range(50, 100+1)
						var isi = HP[int(rand_range(0, HP.size()))]
						while nilai_sebelum == isi: 
							isi = HP[int(rand_range(0, HP.size()))]
						newIndividu[jenis] = isi
					1 : 
						jenis = "ATK"
						var ATK = range(10, 15+1)
						var isi = ATK[int(rand_range(0, ATK.size()))]
						while nilai_sebelum == isi: 
							isi = ATK[int(rand_range(0, ATK.size()))]
						newIndividu[jenis] = isi
					2 : 
						jenis = "ASPD"
						var ASPD = range(1, 2+1)
						var isi = ASPD[int(rand_range(0, ASPD.size()))]
						while nilai_sebelum == isi: 
							isi = ASPD[int(rand_range(0, ASPD.size()))]
						newIndividu[jenis] = isi
					3 : 
						jenis = "SPD"
						var SPD = range(0, 25+1, 5)
						var isi = SPD[int(rand_range(0, SPD.size()))]
						while nilai_sebelum == isi: 
							isi = SPD[int(rand_range(0, SPD.size()))]
						newIndividu[jenis] = isi
				Randoms.push_back(jenis)
			else:
				match kromosom:
					0 : 
						jenis = "HP"
						newIndividu[jenis] = individu[kromosom]
					1 :
						jenis = "ATK"
						newIndividu[jenis] = individu[kromosom]
					2 : 
						jenis = "ASPD"
						newIndividu[jenis] = individu[kromosom]
					3 : 
						jenis = "SPD"
						newIndividu[jenis] = individu[kromosom]
		print("\tRANDOM : ",Randoms)
		Global.write_files("\tRANDOM : " + str(Randoms))
		print("\tIndividu ", i, " baru = ", newIndividu)
		Global.write_files("\tIndividu " + str(i) + " baru = " + str(newIndividu))
		return newIndividu
	
	func bestindividu(fit, stat):
		var fitness = fit
		var status = stat
		for idx in fitness.size():
			if fitness[idx] > Global.bestIndividu["fitness"]:
				Global.bestIndividu["fitness"] = fitness[idx]
				Global.bestIndividu["stat"] = status[idx + 1]
				
	
	func cekPerulangan(fit, stat):
		var fitmax = 70
		var fitness = fit
		var status = stat
		for i in fitness.size():
			if fitness[i] >= fitmax:
				Global.best = true
				for j in status:
					Global.npcStat[j] = status[i+1]
				return true
		return false
	
	
		
