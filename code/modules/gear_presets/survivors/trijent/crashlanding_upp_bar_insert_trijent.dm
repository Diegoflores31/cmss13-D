// as far as i understand this is only done for one insert
//crashlanding-upp-bar.dmm map.
/datum/equipment_preset/survivor/upp
	name = "Survivor - UPP"
	paygrade = "UE1"
	origin_override = ORIGIN_UPP
	rank = JOB_SURVIVOR
	skills = /datum/skills/military/survivor/upp_private
	languages = list(LANGUAGE_RUSSIAN, LANGUAGE_GERMAN, LANGUAGE_CHINESE)
	faction = FACTION_UPP
	faction_group = list(FACTION_UPP, FACTION_SURVIVOR)
	role_comm_title = "UPP 173RD RECON"
	idtype = /obj/item/card/id/dogtag
	flags = EQUIPMENT_PRESET_EXTRA
	uses_special_name = TRUE
	access = list(
		ACCESS_CIVILIAN_PUBLIC,
	)

/datum/equipment_preset/survivor/upp/load_name(mob/living/carbon/human/new_human, randomise)
	var/random_name = capitalize(pick(new_human.gender == MALE ? first_names_male_upp : first_names_female_upp)) + " " + capitalize(pick(last_names_upp))
	new_human.change_real_name(new_human, random_name)

/datum/equipment_preset/survivor/upp/load_gear(mob/living/carbon/human/new_human)
	var/obj/item/clothing/under/marine/veteran/UPP/uniform = new()
	var/random_number = rand(1,2)
	switch(random_number)
		if(1)
			uniform.roll_suit_jacket(new_human)
		if(2)
			uniform.roll_suit_sleeves(new_human)
	new_human.equip_to_slot_or_del(uniform, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/patch/upp (new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp_knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/five_slot(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/med_small_stack(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/UPP/recon(new_human), WEAR_L_EAR)

// /obj/effect/landmark/survivor_spawner/upp/soldier
//crashlanding-upp-bar.dmm
/datum/equipment_preset/survivor/upp/soldier
	name = "Survivor - UPP Soldier"
	paygrade = "UE2"
	assignment = JOB_UPP
	rank = JOB_UPP
	skills = /datum/skills/military/survivor/upp_private

/datum/equipment_preset/survivor/upp/soldier/load_gear(mob/living/carbon/human/new_human)
	var/obj/item/clothing/under/marine/veteran/UPP/uniform = new()
	var/random_number = rand(1,2)
	switch(random_number)
		if(1)
			uniform.roll_suit_jacket(new_human)
		if(2)
			uniform.roll_suit_sleeves(new_human)
	new_human.equip_to_slot_or_del(uniform, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/five_slot(new_human), WEAR_BACK)
	add_upp_weapon(new_human)
	spawn_random_upp_headgear(new_human)
	spawn_random_upp_armor(new_human)
	spawn_random_upp_belt(new_human)

	..()
// /obj/effect/landmark/survivor_spawner/upp_sapper
//crashlanding-upp-bar.dmm
/datum/equipment_preset/survivor/upp/sapper
	name = "Survivor - UPP Sapper"
	paygrade = "UE3S"
	assignment = JOB_UPP_ENGI
	rank = JOB_UPP_ENGI
	skills = /datum/skills/military/survivor/upp_sapper

/datum/equipment_preset/survivor/upp/sapper/load_gear(mob/living/carbon/human/new_human)

	var/obj/item/clothing/under/marine/veteran/UPP/engi/uniform = new()
	var/R = rand(1,2)
	switch(R)
		if(1)
			uniform.roll_suit_jacket(new_human)
		if(2)
			uniform.roll_suit_sleeves(new_human)
	new_human.equip_to_slot_or_del(uniform, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/insulated(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(new_human), WEAR_EYES)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/five_slot(new_human), WEAR_BACK)
	spawn_random_upp_armor(new_human)
	add_upp_weapon(new_human)
	spawn_random_upp_headgear(new_human)

	..()
// /obj/effect/landmark/survivor_spawner/upp_medic
//crashlanding-upp-bar.dmm
/datum/equipment_preset/survivor/upp/medic
	name = "Survivor - UPP Medic"
	paygrade = "UE3M"
	assignment = JOB_UPP_MEDIC
	rank = JOB_UPP_MEDIC
	skills = /datum/skills/military/survivor/upp_medic

/datum/equipment_preset/survivor/upp/medic/load_gear(mob/living/carbon/human/new_human)
	var/obj/item/clothing/under/marine/veteran/UPP/medic/uniform = new()
	var/random_number = rand(1,2)
	switch(random_number)
		if(1)
			uniform.roll_suit_jacket(new_human)
		if(2)
			uniform.roll_suit_sleeves(new_human)
	new_human.equip_to_slot_or_del(uniform, WEAR_BODY)
	new_human.equip_to_slot_or_del(new/obj/item/clothing/glasses/hud/health(new_human), WEAR_EYES)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical/lifesaver/upp/partial(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/medic/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/defibrillator(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/healthanalyzer(new_human), WEAR_IN_BACK)
	spawn_random_upp_armor(new_human)
	add_upp_weapon(new_human)
	spawn_random_upp_headgear(new_human)

	..()
// /obj/effect/landmark/survivor_spawner/upp_specialist
//crashlanding-upp-bar.dmm
/datum/equipment_preset/survivor/upp/specialist
	name = "Survivor - UPP Specialist"
	assignment = JOB_UPP_SPECIALIST
	rank = JOB_UPP_SPECIALIST
	paygrade = "UE4"
	skills = /datum/skills/military/survivor/upp_spec

/datum/equipment_preset/survivor/upp/specialist/load_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/UPP/heavy(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP (new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/faction/UPP/heavy (new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/tool/crowbar(new_human), WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/flamer(new_human), WEAR_L_HAND)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/five_slot(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/type47/t73(new_human), WEAR_WAIST)

	..()
//crashlanding-upp-bar.dmm
// /obj/effect/landmark/survivor_spawner/squad_leader
/datum/equipment_preset/survivor/upp/squad_leader
	name = "Survivor - UPP Squad Leader"
	paygrade = "UE5"
	assignment = JOB_UPP_LEADER
	rank = JOB_UPP_LEADER
	languages = list(LANGUAGE_RUSSIAN, LANGUAGE_ENGLISH,  LANGUAGE_GERMAN,  LANGUAGE_CHINESE)
	role_comm_title = "UPP 173Rd RECON SL"
	skills = /datum/skills/military/survivor/upp_sl

/datum/equipment_preset/survivor/upp/squad_leader/load_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP/officer (new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/faction/UPP (new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/tool/crowbar(new_human), WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/beret(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/five_slot(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/type47/revolver(new_human), WEAR_WAIST)
	add_upp_weapon(new_human)

	..()

//it's used on all of the above in their spawner.
/datum/equipment_preset/synth/survivor/upp
	name = "Survivor - Synthetic - UPP Synth"
	flags = EQUIPMENT_PRESET_EXTRA
	languages = ALL_SYNTH_LANGUAGES_UPP
	assignment = JOB_UPP_COMBAT_SYNTH
	rank = JOB_UPP_COMBAT_SYNTH
	faction = FACTION_UPP
	faction_group = list(FACTION_UPP, FACTION_SURVIVOR)
	skills = /datum/skills/colonial_synthetic
	paygrade = "SYN"
	idtype = /obj/item/card/id/dogtag
	role_comm_title = "173/RECON Syn"

/datum/equipment_preset/synth/survivor/upp/load_gear(mob/living/carbon/human/new_human)
	var/obj/item/clothing/under/marine/veteran/UPP/medic/uniform = new()
	var/random_number = rand(1,2)
	switch(random_number)
		if(1)
			uniform.roll_suit_jacket(new_human)
		if(2)
			uniform.roll_suit_sleeves(new_human)
	new_human.equip_to_slot_or_del(uniform, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/beret, WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/tool/screwdriver, WEAR_R_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/UPP/recon, WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/multitool, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/stack/cable_coil, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/healthanalyzer, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/webbing, WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/device/flashlight, WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical/lifesaver/upp/partial, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/patch/upp, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran, WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/tools/uppsynth, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp, WEAR_FEET)
