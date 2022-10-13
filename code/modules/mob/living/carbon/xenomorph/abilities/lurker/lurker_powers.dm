/datum/action/xeno_action/onclick/lurker_invisibility/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Xeno = owner

	if (!istype(Xeno))
		return

	if (!action_cooldown_check())
		return

	if (!check_and_use_plasma_owner())
		return

	animate(Xeno, alpha = alpha_amount, time = 0.1 SECONDS, easing = QUAD_EASING)
	Xeno.update_icons() // callback to make the icon_state indicate invisibility is in lurker/update_icon

	Xeno.speed_modifier -= speed_buff
	Xeno.recalculate_speed()

	if (Xeno.mutation_type == LURKER_NORMAL)
		var/datum/behavior_delegate/lurker_base/BD = Xeno.behavior_delegate
		BD.on_invisibility()

	// if we go off early, this also works fine.
	invis_timer_id = addtimer(CALLBACK(src, .proc/invisibility_off), duration, TIMER_STOPPABLE)

	// Only resets when invisibility ends
	apply_cooldown_override(1000000000)
	..()
	return

/datum/action/xeno_action/onclick/lurker_invisibility/proc/invisibility_off()
	if(!owner || owner.alpha == initial(owner.alpha))
		return

	if (invis_timer_id != TIMER_ID_NULL)
		deltimer(invis_timer_id)
		invis_timer_id = TIMER_ID_NULL

	var/mob/living/carbon/Xenomorph/Xeno = owner
	if (istype(Xeno))
		animate(Xeno, alpha = initial(Xeno.alpha), time = 0.1 SECONDS, easing = QUAD_EASING)
		to_chat(Xeno, SPAN_XENOHIGHDANGER("You feel your invisibility end!"))

		Xeno.update_icons()

		Xeno.speed_modifier += speed_buff
		Xeno.recalculate_speed()

		if (Xeno.mutation_type == LURKER_NORMAL)
			var/datum/behavior_delegate/lurker_base/BD = Xeno.behavior_delegate
			if (istype(BD))
				BD.on_invisibility_off()

/datum/action/xeno_action/onclick/lurker_invisibility/ability_cooldown_over()
	to_chat(owner, SPAN_XENOHIGHDANGER("You are ready to use your invisibility again!"))
	..()

/datum/action/xeno_action/onclick/lurker_assassinate/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Xeno = owner

	if (!istype(Xeno))
		return

	if (!action_cooldown_check())
		return

	if (!check_and_use_plasma_owner())
		return

	if (Xeno.mutation_type != LURKER_NORMAL)
		return

	var/datum/behavior_delegate/lurker_base/BD = Xeno.behavior_delegate
	if (istype(BD))
		BD.next_slash_buffed = TRUE

	to_chat(Xeno, SPAN_XENOHIGHDANGER("Your next slash will deal increased damage!"))

	addtimer(CALLBACK(src, .proc/unbuff_slash), buff_duration)
	Xeno.next_move = world.time + 1 // Autoattack reset

	apply_cooldown()
	..()
	return

/datum/action/xeno_action/onclick/lurker_assassinate/proc/unbuff_slash()
	var/mob/living/carbon/Xenomorph/Xeno = owner
	if (!istype(Xeno))
		return
	var/datum/behavior_delegate/lurker_base/behavior = Xeno.behavior_delegate
	if (istype(behavior))
		// In case slash has already landed
		if (!behavior.next_slash_buffed)
			return
		behavior.next_slash_buffed = FALSE

	to_chat(Xeno, SPAN_XENODANGER("You have waited too long, your slash will no longer deal increased damage!"))


// VAMPIRE LURKER

/datum/action/xeno_action/activable/pounce/rush/additional_effects(mob/living/L) //pounce effects
	var/mob/living/carbon/Target = L
	var/mob/living/carbon/Xenomorph/Xeno = owner
	Target.dazed += 5
	Xeno.flick_attack_overlay(Target, "slash")   //fake slash to prevent disarm abuse
	Target.last_damage_data = create_cause_data(Xeno.caste_type, Xeno)
	Target.apply_armoured_damage(20, ARMOR_MELEE, BRUTE)
	playsound(get_turf(Target), "alien_claw_flesh", 30, TRUE)
	shake_camera(Target, 2, 1)
	apply_cooldown_override(40)

/datum/action/xeno_action/onclick/flurry/use_ability(atom/A) //flurry ability
	var/mob/living/carbon/Xenomorph/Xeno = owner
	if (!istype(Xeno))
		return
	if (!Xeno.check_state())
		return
	if (!action_cooldown_check())
		return

	Xeno.visible_message(SPAN_DANGER("[Xeno] slashes frantically the area in front of him!"), \
	SPAN_XENOWARNING("You unleash a barrage of slashes!"))
	apply_cooldown()

	// Transient turf list
	var/list/target_turfs = list()
	var/list/temp_turfs = list()
	var/list/telegraph_atom_list = list()

	// Code to get a 2x3 area of turfs
	var/turf/root = get_turf(Xeno)
	var/facing = Xeno.dir
	var/turf/infront = get_step(root, facing)
	var/turf/infront_left = get_step(root, turn(facing, 45))
	var/turf/infront_right = get_step(root, turn(facing, -45))
	temp_turfs += infront
	if (!(!infront || infront.density))
		temp_turfs += infront_left
	if (!(!infront || infront.density))
		temp_turfs += infront_right

	for (var/turf/T in temp_turfs)
		if (!istype(T))
			continue

		if (T.density)
			continue

		target_turfs += T
		telegraph_atom_list += new /obj/effect/xenomorph/xeno_telegraph/red(T, 2)

	for (var/turf/T in target_turfs)
		for (var/mob/living/carbon/Target in T)
			if (Target.stat == DEAD)
				continue

			if (!isXenoOrHuman(Target) || Xeno.can_not_harm(Target))
				continue

			Xeno.visible_message(SPAN_DANGER("[Xeno] scratches [Target] all around his body!"), \
			SPAN_XENOWARNING("You slash [Target] multiple times!"))
			Xeno.flick_attack_overlay(Target, "slash")
			Target.last_damage_data = create_cause_data(Xeno.caste_type, Xeno)
			Target.apply_armoured_damage(20, ARMOR_MELEE, BRUTE)
			playsound(get_turf(Target), "alien_claw_flesh", 30, TRUE)
			playsound(Xeno, "alien_tail_swipe3", 30)
			Xeno.emote("roar")
			Xeno.flick_heal_overlay(1 SECONDS, "#00B800")
			Xeno.gain_health(20)
			..()
			return

/datum/action/xeno_action/activable/tail_Jab/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Xeno = owner
	var/mob/living/carbon/Target = A
	var/distance = get_dist(Xeno, Target)

	if(!action_cooldown_check())
		return

	if(!Xeno.check_state())
		return

	if(!isXenoOrHuman(Target) || Xeno.can_not_harm(Target))
		return

	if(distance > 2)
		return

	if(Target.stat == DEAD)
		return

	if(Target.stat) //execute provides you with a good chuck of health by murdering your victim
		if(!Xeno.Adjacent(Target))
			to_chat(Xeno, SPAN_XENONOTICE("You cannot execute [Target] from that far away."))
			return
		Xeno.visible_message(SPAN_DANGER("[Xeno] Prepares for devastating attack on [Target]."), \
		SPAN_XENOWARNING("You carefully aim your tail towards [Target] vital organs."), null, 5)
		if(!do_after(Xeno, 10, INTERRUPT_NO_NEEDHAND, BUSY_ICON_HOSTILE))
			return
		if(Target.stat == DEAD)
			return
		to_chat(Xeno, SPAN_XENOHIGHDANGER("You brutally pierce [Target] chest with your tail."))
		Xeno.visible_message(SPAN_DANGER("[Xeno] pierces [Target] chest with his tail."))
		Xeno.flick_attack_overlay(Target, "tail")
		Target.apply_armoured_damage(80, ARMOR_MELEE, BRUTE, "chest", 5)
		Xeno.gain_health(100)
		Xeno.xeno_jitter(1 SECONDS)
		Xeno.flick_heal_overlay(3 SECONDS, "#00B800")
		Target.last_damage_data = create_cause_data(Xeno.caste_type, Xeno)
		Xeno.emote("roar")
		apply_cooldown()
		return


	to_chat(Xeno, SPAN_XENOHIGHDANGER("You stab [Target] with your tail, pushing it backwards."))
	Xeno.flick_attack_overlay(Target, "tail")
	playsound(Target,'sound/weapons/alien_claw_block.ogg', 50, 1)
	Target.apply_armoured_damage(20, ARMOR_MELEE, BRUTE, "chest")
	Target.KnockDown(0.5, 0.5)
	Target.last_damage_data = create_cause_data(Xeno.caste_type, Xeno)
	step_away(Target, Xeno, 2, 2)
	apply_cooldown() // normal cooldown if you havent executed anyone
