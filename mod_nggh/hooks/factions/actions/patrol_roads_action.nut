::Nggh_MagicConcept.HooksMod.hook("scripts/factions/actions/patrol_roads_action", function(q) {
	q.onUpdate = @(__original) function( _faction )
	{
		__original(_faction);

		if (m.Score > 0)
			m.Score *= ::World.Flags.get("isExposed") ? 1.5 : 1.25;
	}

	q.onExecute = @(__original) function( _faction )
	{
		/*
		local canSpawnWitchHunterSettlements = [];

		foreach (s in m.Settlements)
		{
			local faction = s.getFactionOfType(::Const.FactionType.Settlement);

			if (faction != null && faction.getPlayerRelation() >= 90.0)
			{
				continue;
			}

			canSpawnWitchHunterSettlements.push(s);
		}
		*/

		if (::Math.rand(1, 100) > (::World.Flags.get("isExposed") ? 50 : 25))
			return __original(_faction);

		local waypoints = [];

		for( local i = 0; i != 3; ++i )
		{
			local idx = ::Math.rand(0, m.Settlements.len() - 1);
			local wp = m.Settlements[idx];
			m.Settlements.remove(idx);
			waypoints.push(wp);
		}

		local hasNoble = ::Math.rand(1, 100) <= 40;
		local party = _faction.spawnEntity(waypoints[0].getTile(), waypoints[0].getName() + " " + (hasNoble ? "Inquisition Company" : "Witch Hunting Party"), hasNoble, hasNoble ? ::Const.World.Spawn.Nggh_WitchHunterAndNoble : ::Const.World.Spawn.Nggh_WitchHunter, ::Math.rand(150, 325) * getReputationToDifficultyLightMult());
		party.setDescription(hasNoble ? "Professional soldiers in service to local lords." : "Professional witch hunters hired by local lords to deal with problematic cults and witch covens.");
		party.setFootprintType(hasNoble ? ::Const.World.FootprintsType.Nobles : ::Const.World.FootprintsType.Militia);
		party.setVisionRadius(::Const.World.Settings.Vision * 1.25);
		party.getFlags().set("IsRandomlySpawned", true);
		party.getFlags().set("WitchHunters", true);

		// supply
		party.getLoot().Money = ::Math.rand(150, 500);
		party.getLoot().ArmorParts = ::Math.rand(0, 10);
		party.getLoot().Medicine = ::Math.rand(0, 7);
		party.getLoot().Ammo = ::Math.rand(0, 50);

		// food
		party.addToInventory("supplies/bread_item");
		party.addToInventory("supplies/dried_fruits_item");
		
		// party sent to hunt down player :3
		if (::World.Flags.get("isExposed") && ::Math.rand(1, 100) <= ::Math.rand(5, 10)) {
			party.setAttackableByAI(false);
			party.setAlwaysAttackPlayer(true);
			party.setUsingGlobalVision(true);

			local c = party.getController();
			c.getBehavior(::Const.World.AI.Behavior.ID.Flee).setEnabled(false);
			local attack = ::new("scripts/ai/world/orders/intercept_order");
			attack.setTarget(::World.State.getPlayer());
			c.addOrder(attack);
		}
		// party sent to patrol
		else {
			local c = party.getController();
			local move1 = ::new("scripts/ai/world/orders/move_order");
			move1.setRoadsOnly(true);
			move1.setDestination(waypoints[1].getTile());
			local wait1 = ::new("scripts/ai/world/orders/wait_order");
			wait1.setTime(20.0);
			local move2 = ::new("scripts/ai/world/orders/move_order");
			move2.setRoadsOnly(true);
			move2.setDestination(waypoints[2].getTile());
			local wait2 = ::new("scripts/ai/world/orders/wait_order");
			wait2.setTime(20.0);
			local move3 = ::new("scripts/ai/world/orders/move_order");
			move3.setRoadsOnly(true);
			move3.setDestination(waypoints[0].getTile());
			local despawn = ::new("scripts/ai/world/orders/despawn_order");
			c.addOrder(move1);
			c.addOrder(wait1);
			c.addOrder(move2);
			c.addOrder(wait2);
			c.addOrder(move3);
			c.addOrder(despawn);
		}
		
		m.Cooldown = ::World.FactionManager.isGreaterEvil() || ::World.Flags.get("isExposed") ? 200.0 : 400.0;
		return true;
	}

})