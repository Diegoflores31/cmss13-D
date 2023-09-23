//This file deals with distress beacons. It randomizes between a number of different types when activated.
//There's also an admin commmand which lets you set one to your liking.




//basic persistent gamemode stuff.
/datum/game_mode
	var/list/datum/emergency_call/all_calls = list() //initialized at round start and stores the datums.
	var/datum/emergency_call/picked_calls[] = list() //Which distress calls are currently active
	var/ert_dispatched = FALSE

/datum/game_mode/proc/ares_online()
	var/name = "ARES Online"
	var/input = "ARES. Online. Good morning, marines."
	shipwide_ai_announcement(input, name, 'sound/AI/ares_online.ogg')

/datum/game_mode/proc/request_ert(user, ares = FALSE)
	if(!user)
		return FALSE
	message_admins("[key_name(user)] has requested a Distress Beacon! [ares ? SPAN_ORANGE("(via ARES)") : ""] ([SSticker.mode.ert_dispatched ? SPAN_RED("A random ERT was dispatched previously.") : SPAN_GREEN("No previous random ERT dispatched.")]) [CC_MARK(user)] (<A HREF='?_src_=admin_holder;[HrefToken(forceGlobal = TRUE)];distress=\ref[user]'>SEND</A>) (<A HREF='?_src_=admin_holder;[HrefToken(forceGlobal = TRUE)];ccdeny=\ref[user]'>DENY</A>) [ADMIN_JMP_USER(user)] [CC_REPLY(user)]")
	return TRUE

/datum/game_mode/proc/authorized_request_ert(user) // calls the first ERT winout the need of admin approval.
	if(!user)
		return FALSE
	if(ert_dispatched) //safety check we dont want ert spam
		return FALSE
	message_admins("[key_name(user)] has launched a keycard Distress Beacon![ADMIN_JMP_USER(user)] [CC_REPLY(user)]")
	activate_distress()

//The distress call parent. Cannot be called itself due to "name" being a filtered target.
/datum/emergency_call
	var/name = "name"
	var/mob_max = 3
	var/mob_min = 3
	var/dispatch_message = "An encrypted signal has been received from a nearby vessel. Stand by." //Msg to display when starting
	var/arrival_message = "" //Msg to display about when the shuttle arrives
	var/objectives //Txt of objectives to display to joined. Todo: make this into objective notes
	var/objective_info //For additional info in the objectives txt
	var/probability = 0 //Chance of it occurring. Total must equal 100%
	var/hostility //For ERTs who are either hostile or friendly by random chance.
	var/list/datum/mind/members = list() //Currently-joined members.
	var/list/datum/mind/candidates = list() //Potential candidates for enlisting.
	var/name_of_spawn = /obj/effect/landmark/ert_spawns/distress //If we want to set up different spawn locations
	var/item_spawn = /obj/effect/landmark/ert_spawns/distress/item
	var/mob/living/carbon/leader = null //Who's leading these miscreants
	var/medics = 0
	var/engineers = 0
	var/heavies = 0
	var/smartgunners = 0
	var/max_medics = 1
	var/max_engineers = 1
	var/max_heavies = 1
	var/max_smartgunners = 1
	var/shuttle_id = MOBILE_SHUTTLE_ID_ERT1 //Empty shuttle ID means we're not using shuttles (aka spawn straight into cryo)
	var/auto_shuttle_launch = FALSE
	var/spawn_max_amount = FALSE

	var/ert_message = "An emergency beacon has been activated"

	var/time_required_for_job = 5 HOURS

/datum/game_mode/proc/initialize_emergency_calls()
	if(all_calls.len) //It's already been set up.
		return

	var/list/total_calls = typesof(/datum/emergency_call)
	if(!total_calls.len)
		to_world(SPAN_DANGER("\b Error setting up emergency calls, no datums found."))
		return FALSE
	for(var/S in total_calls)
		var/datum/emergency_call/C= new S()
		if(!C) continue
		if(C.name == "name") continue //The default parent, don't add it
		all_calls += C

//Randomizes and chooses a call datum.
/datum/game_mode/proc/get_random_call()
	var/add_prob = 0
	var/datum/emergency_call/chosen_call
	var/total_probablity = 0

	//Ensure that if someone messed up the math we still get the good probability
	for(var/datum/emergency_call/E in all_calls)
		total_probablity += E.probability
	var/chance = rand(1, total_probablity)

	for(var/datum/emergency_call/E in all_calls) //Loop through all potential candidates
		if(chance >= E.probability + add_prob) //Tally up probabilities till we find which one we landed on
			add_prob += E.probability
			continue
		chosen_call = new E.type() //Our random chance found one.
		break

	if(!istype(chosen_call))
		error("get_random_call !istype(chosen_call)")
		return null
	else
		return chosen_call

/datum/game_mode/proc/get_specific_call(call_name, quiet_launch = FALSE, announce_incoming = TRUE, info = "")
	for(var/datum/emergency_call/E in all_calls) //Loop through all potential candidates
		if(E.name == call_name)
			var/datum/emergency_call/em_call = new E.type()
			em_call.objective_info = info
			em_call.activate(quiet_launch, announce_incoming)
			return
	error("get_specific_call could not find emergency call '[call_name]'")
	return

/datum/emergency_call/proc/show_join_message()
	if(!mob_max || !SSticker.mode) //Just a supply drop, don't bother.
		return

	for(var/mob/dead/observer/M in GLOB.observer_list)
		if(M.client)
			to_chat(M, SPAN_WARNING(FONT_SIZE_LARGE("\n[ert_message]. &gt; <a href='?src=\ref[M];joinresponseteam=1;'><b>Join Response Team</b></a> &lt; </span>")))
			to_chat(M, SPAN_WARNING(FONT_SIZE_LARGE("You cannot join if you have Ghosted recently. Click the link in chat, or use the verb in the ghost tab to join.</span>\n")))

			give_action(M, /datum/action/join_ert, src)

/datum/game_mode/proc/activate_distress()
	ert_dispatched = TRUE
	var/datum/emergency_call/random_call = get_random_call()
	if(!istype(random_call, /datum/emergency_call)) //Something went horribly wrong
		return
	random_call.activate()
	return

/datum/emergency_call/proc/check_timelock(client/C, list/roles, hours)
	if(C?.check_timelock(roles, hours))
		return TRUE
	return FALSE

/mob/dead/observer/verb/JoinResponseTeam()
	set name = "Join Response Team"
	set category = "Ghost.Join"
	set desc = "Join an ongoing distress call response. You must be ghosted to do this."

	do_join_response_team()

/mob/dead/observer/proc/do_join_response_team()

	if(jobban_isbanned(src, "Syndicate") || jobban_isbanned(src, "Emergency Response Team"))
		to_chat(src, SPAN_DANGER("You are jobbanned from the emergency response team!"))
		return
	if(!SSticker.mode || !SSticker.mode.picked_calls.len)
		to_chat(src, SPAN_WARNING("No distress beacons are active. You will be notified if this changes."))
		return

	var/list/beacons = list()

	for(var/datum/emergency_call/em_call in SSticker.mode.picked_calls)
		var/name = em_call.name
		var/iteration = 1
		while(name in beacons)
			name = "[em_call.name] [iteration]"
			iteration++

		beacons += list("[name]" = em_call) // I hate byond

	var/choice = tgui_input_list(src, "Choose a distress beacon to join", "", beacons)

	if(!choice)
		return

	if(!beacons[choice] || !(beacons[choice] in SSticker.mode.picked_calls))
		to_chat(src, "That choice is no longer available!")
		return

	var/datum/emergency_call/distress = beacons[choice]

	if(!istype(distress) || !distress.mob_max)
		to_chat(src, SPAN_WARNING("The emergency response team is already full!"))
		return
	var/deathtime = world.time - usr.timeofdeath

	if(deathtime < 30 SECONDS) //Nice try, ghosting right after the announcement
		if(SSmapping.configs[GROUND_MAP].map_name != MAP_WHISKEY_OUTPOST) // people ghost so often on whiskey outpost.
			to_chat(src, SPAN_WARNING("You ghosted too recently."))
			return

	if(!mind) //How? Give them a new one anyway.
		mind = new /datum/mind(key, ckey)
		mind.active = 1
		mind.current = src
		mind_initialize()
	if(mind.key != key)
		mind.key = key //Sigh. This can happen when admin-switching people into afking people, leading to runtime errors for a clientless key.

	if(!client || !mind)
		return //Somehow
	if(mind in distress.candidates)
		to_chat(src, SPAN_WARNING("You are already a candidate for this emergency response team."))
		return

	if(distress.add_candidate(src))
		to_chat(src, SPAN_BOLDNOTICE("You are now a candidate in the emergency response team! If there are enough candidates, you may be picked to be part of the team."))
	else
		to_chat(src, SPAN_WARNING("You did not get enlisted in the response team. Better luck next time!"))

/datum/emergency_call/proc/activate(quiet_launch = FALSE, announce_incoming = TRUE, turf/override_spawn_loc)
	set waitfor = 0
	if(!SSticker.mode) //Something horribly wrong with the gamemode ticker
		return

	SSticker.mode.picked_calls += src

	show_join_message() //Show our potential candidates the message to let them join.
	message_admins("Distress beacon: '[name]' activated [src.hostility? "[SPAN_WARNING("(THEY ARE HOSTILE)")]":"(they are friendly)"]. Looking for candidates.")

	if(!quiet_launch)
		marine_announcement("A distress beacon has been launched from the [MAIN_SHIP_NAME].", "Priority Alert", 'sound/AI/distressbeacon.ogg', logging = ARES_LOG_SECURITY)

	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/emergency_call, spawn_candidates), quiet_launch, announce_incoming, override_spawn_loc), 30 SECONDS)

/datum/emergency_call/proc/spawn_candidates(quiet_launch = FALSE, announce_incoming = TRUE, override_spawn_loc)
	if(SSticker.mode)
		SSticker.mode.picked_calls -= src

	SEND_SIGNAL(src, COMSIG_ERT_SETUP)

	if(candidates.len < mob_min && !spawn_max_amount)
		message_admins("Aborting distress beacon, not enough candidates: found [candidates.len].")
		members = list() //Empty the members list.
		candidates = list()

		if(!quiet_launch)
			marine_announcement("The distress signal has not received a response, the launch tubes are now recalibrating.", "Distress Beacon", logging = ARES_LOG_SECURITY)
		return

	//We've got enough!
	//Trim down the list
	var/list/datum/mind/picked_candidates = list()
	if(mob_max > 0)
		var/mob_count = 0
		while (mob_count < mob_max && candidates.len)
			var/datum/mind/M = pick(candidates) //Get a random candidate, then remove it from the candidates list.
			if(!istype(M))//Something went horrifically wrong
				candidates.Remove(M)
				continue //Lets try this again
			if(!GLOB.directory[M.ckey])
				candidates -= M
				continue
			if(M.current && M.current.stat != DEAD)
				candidates.Remove(M) //Strip them from the list, they aren't dead anymore.
				if(!candidates.len)
					break //NO picking from empty lists
				continue
			picked_candidates.Add(M)
			candidates.Remove(M)
			mob_count++
		if(candidates.len)
			for(var/datum/mind/I in candidates)
				if(I.current)
					to_chat(I.current, SPAN_WARNING("You didn't get selected to join the distress team. Better luck next time!"))

	if(announce_incoming)
		marine_announcement(dispatch_message, "Distress Beacon", 'sound/AI/distressreceived.ogg', logging = ARES_LOG_SECURITY) //Announcement that the Distress Beacon has been answered, does not hint towards the chosen ERT

	message_admins("Distress beacon: [src.name] finalized, setting up candidates.")

	//Let the deadchat know what's up since they are usually curious
	for(var/mob/dead/observer/M in GLOB.observer_list)
		if(M.client)
			to_chat(M, SPAN_NOTICE("Distress beacon: [src.name] finalized."))

	var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(shuttle_id)

	if(!istype(shuttle))
		if(shuttle_id) //Cryo distress doesn't have a shuttle
			message_admins("Warning: Distress shuttle not found.")
	spawn_items()

	if(shuttle && auto_shuttle_launch)
		var/obj/structure/machinery/computer/shuttle/ert/comp = shuttle.getControlConsole()
		var/list/lzs = comp.get_landing_zones()
		if(!length(lzs))
			message_admins("Auto shuttle launch set for ert [name] but no lzs allowed.")
			return

		var/list/active_lzs = list()
		var/list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP))
		for(var/obj/docking_port/stationary/dock as anything in lzs)
			// filter for almayer only
			if(!(dock.z in z_levels))
				continue
			// filter for free lzs
			if(shuttle.canDock(dock) != SHUTTLE_CAN_DOCK)
				continue
			active_lzs += list(dock)

		if(!length(active_lzs))
			message_admins("Auto shuttle launch set for ert [name] but no lzs available.")
			return

		SSshuttle.moveShuttleToDock(shuttle, pick(active_lzs), TRUE)

	var/i = 0
	if(picked_candidates.len)
		for(var/datum/mind/M in picked_candidates)
			members += M
			i++
			if(i > mob_max)
				break //Some logic. Hopefully this will never happen..
			create_member(M, override_spawn_loc)


	if(spawn_max_amount && i < mob_max)
		for(var/c in i to mob_max)
			create_member(null, override_spawn_loc)

	candidates = list()
	if(arrival_message && announce_incoming)
		marine_announcement(arrival_message, "Intercepted Transmission:")

/datum/emergency_call/proc/add_candidate(mob/M)
	if(!M.client || (M.mind && (M.mind in candidates)) || istype(M, /mob/living/carbon/xenomorph))
		return FALSE //Not connected or already there or something went wrong.
	if(M.mind)
		candidates += M.mind
	else
		if(M.key)
			M.mind = new /datum/mind(M.key, M.ckey)
			M.mind_initialize()
			candidates += M.mind
	return TRUE

/datum/emergency_call/proc/get_spawn_point(is_for_items)
	var/landmark
	if(is_for_items)
		landmark = SAFEPICK(GLOB.ert_spawns[item_spawn])
	else
		landmark = SAFEPICK(GLOB.ert_spawns[name_of_spawn])
	return landmark ? get_turf(landmark) : null

/datum/emergency_call/proc/create_member(datum/mind/M, turf/override_spawn_loc) //This is the parent, each type spawns its own variety.
	return

//Spawn various items around the shuttle area thing.
/datum/emergency_call/proc/spawn_items()
	return


/datum/emergency_call/proc/print_backstory(mob/living/carbon/human/M)
	return
