this.alp_shadow_minion_entity <- this.inherit("scripts/entity/tactical/minion", {
	m = {
		Link = null,
		Bust = "bust_alp_shadow_01",
		Variant = 1,
		DistortTargetA = null,
		DistortTargetPrevA = this.createVec(0, 0),
		DistortAnimationStartTimeA = 0,
		DistortTargetB = null,
		DistortTargetPrevB = this.createVec(0, 0),
		DistortAnimationStartTimeB = 0,
		DistortTargetC = null,
		DistortTargetPrevC = this.createVec(0, 0),
		DistortAnimationStartTimeC = 0,
		DistortTargetD = null,
		DistortTargetPrevD = this.createVec(0, 0),
		DistortAnimationStartTimeD = 0
	},
	function addNineLivesCount()
	{
		local NineLives = this.m.Skills.getSkillByID("perk.nine_lives");
		
		if (NineLives != null)
		{
			NineLives.addNineLivesCount();
		}
	}

	function setLink( _l )
	{
		if (_l != null)
		{
			this.m.Link = typeof _l == "instance" ? _l : this.WeakTableRef(_l);
		}

		this.m.Link = null;
	}

	function setStatsAndSkills( _properties )
	{
		local power = _properties.MasterPower;
		local perkSets = this.getPerkSet();
		local b = this.m.BaseProperties;
		b.setValues(_properties);

		if (_properties.rawin("DamageTotalMult"))
		{
			b.DamageTotalMult *= _properties.rawget("DamageTotalMult");
		}

		this.m.CurrentProperties = clone b;
		this.getSkills().update();

		foreach ( entry in perkSets )
		{
			if (power >= entry[0])
			{
				this.getSkills().add(this.new("scripts/skill/" + entry[1]));
			}
		}

		this.setHitpointsPct(1.0);
	}

	function getPerkSet()
	{
		switch (this.m.Variant)
		{
		case 1: // fragile
			return [
				[ // 0
					1.25,
					"perks/perk_footwork"
				],
				[ // 1
					1.30,
					"perks/perk_fast_adaption"
				],
				[ // 2
					1.35,
					"perks/perk_dodge"
				],
				[ // 3
					1.40,
					"perks/perk_legend_alert"
				], 
				[ // 4
					1.45,
					"perks/perk_legend_big_game_hunter"
				],
				[ // 5
					1.50,
					"perks/perk_legend_perfect_focus"
				],
			];

		case 2: // tank
			return [
				[ // 0
					1.25,
					"perks/perk_taunt"
				],
				[ // 1
					1.30,
					"perks/perk_legend_muscularity"
				],
				[ // 2
					1.35,
					"perks/perk_nimble"
				],
				[ // 3
					1.40,
					"perks/perk_adrenalin"
				], 
				[ // 4
					1.45,
					"perks/perk_colossus"
				],
				[ // 5
					1.50,
					"perks/perk_last_stand"
				],
			];
	
		default: // support
			return [
				[ // 0
					1.25,
					"perks/perk_rotation"
				],
				[ // 1
					1.30,
					"perks/perk_legend_levitation"
				],
				[ // 2
					1.35,
					"perks/perk_mar_lithe"
				],
				[ // 3
					1.40,
					"perks/perk_push_the_advantage"
				], 
				[ // 4
					1.45,
					"perks/perk_legend_call_lightning"
				],
				[ // 5
					1.50,
					"perks/perk_mage_legend_magic_web_bolt"
				],
			];	
		}
	}

	function create()
	{
		this.m.Type = this.Const.EntityType.AlpShadow;
		this.m.BloodType = this.Const.BloodType.None;
		this.m.MoraleState = this.Const.MoraleState.Ignore;
		this.m.XP = this.Const.Tactical.Actor.AlpShadow.XP;
		this.m.IsActingImmediately = true;
		this.m.IsSummoned = true;
		this.m.IsEmittingMovementSounds = false;
		this.minion.create();
		this.m.Sound[this.Const.Sound.ActorEvent.Death] = [
			"sounds/enemies/ghost_death_01.wav",
			"sounds/enemies/ghost_death_02.wav"
		];
		this.m.Sound[this.Const.Sound.ActorEvent.DamageReceived] = [];
		this.m.SoundPitch = this.Math.rand(90, 110) * 0.01;
		this.m.Flags.add("alp");
		this.m.Flags.add("shadow");
		this.setName("Shadow Demon");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if (this.m.Link != null && !this.m.Link.isNull())
		{
			this.m.Link.removeEntity();
			this.m.Link.setCooldown();
		}

		if (_tile != null)
		{
			this.spawnShadowEffect(_tile);
		}

		this.actor.onDeath(_killer, _skill, _tile, _fatalityType);
	}

	function spawnShadowEffect( _tile = null )
	{
		if (_tile == null)
		{
			_tile = this.getTile();
		}
		local brush = this.getSprite("body").getBrush().Name;

		if (this.isPlayerControlled())
		{
			brush = "mc_" + brush;
		}

		local effect = {
			Delay = 0,
			Quantity = 12,
			LifeTimeQuantity = 12,
			SpawnRate = 100,
			Brushes = [
				brush
			],
			Stages = [
				{
					LifeTimeMin = 0.5,
					LifeTimeMax = 0.5,
					ColorMin = this.createColor("0000002f"),
					ColorMax = this.createColor("0000002f"),
					ScaleMin = 1.0,
					ScaleMax = 1.0,
					RotationMin = 0,
					RotationMax = 0,
					VelocityMin = 80,
					VelocityMax = 100,
					DirectionMin = this.createVec(-1.0, -1.0),
					DirectionMax = this.createVec(1.0, 1.0),
					SpawnOffsetMin = this.createVec(-10, -10),
					SpawnOffsetMax = this.createVec(10, 10),
					ForceMin = this.createVec(0, 0),
					ForceMax = this.createVec(0, 0)
				},
				{
					LifeTimeMin = 0.5,
					LifeTimeMax = 0.5,
					ColorMin = this.createColor("0000001f"),
					ColorMax = this.createColor("0000001f"),
					ScaleMin = 0.9,
					ScaleMax = 0.9,
					RotationMin = 0,
					RotationMax = 0,
					VelocityMin = 80,
					VelocityMax = 100,
					DirectionMin = this.createVec(-1.0, -1.0),
					DirectionMax = this.createVec(1.0, 1.0),
					ForceMin = this.createVec(0, 0),
					ForceMax = this.createVec(0, 0)
				},
				{
					LifeTimeMin = 0.1,
					LifeTimeMax = 0.1,
					ColorMin = this.createColor("00000000"),
					ColorMax = this.createColor("00000000"),
					ScaleMin = 0.1,
					ScaleMax = 0.1,
					RotationMin = 0,
					RotationMax = 0,
					VelocityMin = 80,
					VelocityMax = 100,
					DirectionMin = this.createVec(-1.0, -1.0),
					DirectionMax = this.createVec(1.0, 1.0),
					ForceMin = this.createVec(0, 0),
					ForceMax = this.createVec(0, 0)
				}
			]
		};
		this.Tactical.spawnParticleEffect(false, effect.Brushes, _tile, effect.Delay, effect.Quantity, effect.LifeTimeQuantity, effect.SpawnRate, effect.Stages, this.createVec(0, 40));
	}

	function onFactionChanged()
	{
		this.actor.onFactionChanged();
		local flip = this.isAlliedWithPlayer();
		this.getSprite("body").setHorizontalFlipping(flip);
		this.getSprite("head").setHorizontalFlipping(flip);
		this.getSprite("blur_1").setHorizontalFlipping(flip);
		this.getSprite("blur_2").setHorizontalFlipping(flip);
		this.setDirty(true);

		if (this.isPlayerControlled())
		{
			this.m.AIAgent = this.new("scripts/ai/tactical/player_agent");
			this.m.AIAgent.setActor(this);
		}
		else 
		{
			this.m.AIAgent = this.new("scripts/ai/tactical/agents/alp_shadow_agent");
			this.m.AIAgent.setActor(this);    
		}
	}

	function onInit()
	{
		this.actor.onInit();
		this.setRenderCallbackEnabled(true);
		this.m.Variant = this.Math.rand(1, 3);
		local b = this.m.BaseProperties;
		b.setValues(this.Const.Tactical.Actor.AlpShadow);
		b.IsImmuneToFire = true;
		b.IsImmuneToBleeding = true;
		b.IsImmuneToPoison = true;
		b.IsImmuneToKnockBackAndGrab = true;
		b.IsImmuneToStun = true;
		b.IsImmuneToRoot = true;
		b.IsImmuneToDisarm = true;
		b.IsIgnoringArmorOnAttack = true;
		b.IsAffectedByNight = false;
		b.IsAffectedByRain = false;
		b.IsAffectedByInjuries = false;
		b.IsMovable = false;
		b.DamageRegularMin = 0;
		b.DamageRegularMax = 5;
		b.HitChance = [
			100,
			0
		];
		b.TargetAttractionMult = 0.85;
		this.m.ActionPoints = b.ActionPoints;
		this.m.Hitpoints = b.Hitpoints;
		this.m.CurrentProperties = clone b;
		this.m.ActionPointCosts = this.Const.SameMovementAPCost;
		this.m.FatigueCosts = this.Const.DefaultMovementFatigueCost;
		this.m.MaxTraversibleLevels = 3;
		this.m.Bust = "bust_alp_shadow_0" + this.m.Variant;
		local blurAlpha = 110;
		local socket = this.addSprite("socket");
		socket.setBrush("bust_base_shadow");
		local body = this.addSprite("body");
		body.setBrush(this.m.Bust);
		body.Alpha = 0;
		body.fadeToAlpha(blurAlpha, 750);
		local head = this.addSprite("head");
		head.setBrush(this.m.Bust);
		head.Alpha = 0;
		head.fadeToAlpha(blurAlpha, 750);
		local blur_1 = this.addSprite("blur_1");
		blur_1.setBrush(this.m.Bust);
		blur_1.Alpha = 0;
		blur_1.fadeToAlpha(blurAlpha, 750);
		local blur_2 = this.addSprite("blur_2");
		blur_2.setBrush(this.m.Bust);
		blur_2.Alpha = 0;
		blur_2.fadeToAlpha(blurAlpha, 750);
		this.addDefaultStatusSprites();
		local morale = this.addSprite("morale");
		morale.Visible = false;
		this.getSprite("status_rooted").Scale = 0.55;
		this.setSpriteOffset("status_rooted", this.createVec(-5, -5));
		this.m.Skills.add(this.new("scripts/skills/racial/ghost_racial"));
		this.m.Skills.add(this.new("scripts/skills/perks/perk_fearsome"));
		this.m.Skills.add(this.new("scripts/skills/perks/perk_nine_lives"));
		this.m.Skills.add(this.new("scripts/skills/perks/perk_anticipation"));
		this.m.Skills.add(this.new("scripts/skills/perks/perk_underdog"));

		local touch = this.new("scripts/skills/actives/ghastly_touch");
		this.m.Skills.add(touch);
		touch.setOrder(this.Const.SkillOrder.First);

		switch(this.m.Variant)
		{
	    case 1: // fragile
	    	if (this.Math.rand(1, 100) <= 50)
	    	{
	    		this.m.Skills.add(this.new("scripts/skills/actives/sleep_skill"));
	    	}
	    	else
	    	{
	    		this.m.Skills.add(this.new("scripts/skills/actives/legend_rust"));
	    	}
	        break;

	    case 2: // tank
	    	if (this.Math.rand(1, 100) <= 50)
	    	{
	    		this.m.Skills.add(this.new("scripts/skills/actives/legend_drain"));
	    	}
	    	else
	    	{
	    		local skill = this.new("scripts/skills/actives/legend_hex_skill");
	    		skill.m.Cooldown = 0;
	    		skill.m.Delay = 0;
		    	this.m.Skills.add(skill);
	    	}
	        break;

	    case 3: // debuff
	    	if (this.Math.rand(1, 100) <= 50)
	    	{
	    		this.m.Skills.add(this.new("scripts/skills/actives/legend_wither"));
	    	}
	    	else
	    	{
	    		this.m.Skills.add(this.new("scripts/skills/actives/insects_skill"));
	    	}
	        break;
		}

		if (this.Math.rand(1, 100) <= 25)
		{
			this.m.Skills.add(this.new("scripts/skills/actives/legend_darkflight"));
		}
	}

	/*gt.Const.Tactical.Actor.AlpShadow <- {
		XP = 0,
		ActionPoints = 9,
		Hitpoints = 5,
		Bravery = 100,
		Stamina = 100,
		MeleeSkill = 50,
		RangedSkill = 50,
		MeleeDefense = 10,
		RangedDefense = 20,
		Initiative = 100,
		FatigueEffectMult = 0.0,
		MoraleEffectMult = 0.0,
		FatigueRecoveryRate = 15,
		Vision = 3,
		Armor = [
			0,
			0
		]
	};*/

	function onRender()
	{
		this.actor.onRender();

		if (this.m.DistortTargetA == null)
		{
			this.m.DistortTargetA = this.createVec(this.Math.rand(0, 10) - 5, this.Math.rand(0, 10) - 5);
			this.m.DistortAnimationStartTimeA = this.Time.getVirtualTimeF();
		}

		if (this.moveSpriteOffset("head", this.m.DistortTargetPrevA, this.m.DistortTargetA, 3.8, this.m.DistortAnimationStartTimeA))
		{
			this.m.DistortAnimationStartTimeA = this.Time.getVirtualTimeF();
			this.m.DistortTargetPrevA = this.m.DistortTargetA;
			this.m.DistortTargetA = this.createVec(this.Math.rand(0, 10) - 5, this.Math.rand(0, 10) - 5);
		}

		if (this.m.DistortTargetB == null)
		{
			this.m.DistortTargetB = this.createVec(this.Math.rand(0, 10) - 5, this.Math.rand(0, 10) - 5);
			this.m.DistortAnimationStartTimeB = this.Time.getVirtualTimeF();
		}

		if (this.moveSpriteOffset("blur_1", this.m.DistortTargetPrevB, this.m.DistortTargetB, 4.9000001, this.m.DistortAnimationStartTimeB))
		{
			this.m.DistortAnimationStartTimeB = this.Time.getVirtualTimeF();
			this.m.DistortTargetPrevB = this.m.DistortTargetB;
			this.m.DistortTargetB = this.createVec(this.Math.rand(0, 10) - 5, this.Math.rand(0, 10) - 5);
		}

		if (this.m.DistortTargetC == null)
		{
			this.m.DistortTargetC = this.createVec(this.Math.rand(0, 10) - 5, this.Math.rand(0, 10) - 5);
			this.m.DistortAnimationStartTimeC = this.Time.getVirtualTimeF();
		}

		if (this.moveSpriteOffset("body", this.m.DistortTargetPrevC, this.m.DistortTargetC, 4.3, this.m.DistortAnimationStartTimeC))
		{
			this.m.DistortAnimationStartTimeC = this.Time.getVirtualTimeF();
			this.m.DistortTargetPrevC = this.m.DistortTargetC;
			this.m.DistortTargetC = this.createVec(this.Math.rand(0, 10) - 5, this.Math.rand(0, 10) - 5);
		}

		if (this.m.DistortTargetD == null)
		{
			this.m.DistortTargetD = this.createVec(this.Math.rand(0, 10) - 5, this.Math.rand(0, 10) - 5);
			this.m.DistortAnimationStartTimeD = this.Time.getVirtualTimeF();
		}

		if (this.moveSpriteOffset("blur_2", this.m.DistortTargetPrevD, this.m.DistortTargetD, 5.5999999, this.m.DistortAnimationStartTimeD))
		{
			this.m.DistortAnimationStartTimeD = this.Time.getVirtualTimeF();
			this.m.DistortTargetPrevD = this.m.DistortTargetD;
			this.m.DistortTargetD = this.createVec(this.Math.rand(0, 10) - 5, this.Math.rand(0, 10) - 5);
		}
	}
	
	function onPlacedOnMap()
	{
		this.actor.onPlacedOnMap();
		this.onSpawnShadow();
		this.spawnShadowEffect();
	}

	function onTurnStart()
	{
		this.actor.onTurnStart();
		this.onSpawnShadow();
	}
	
	function wait()
	{
		this.actor.wait();
		this.onSpawnShadow();
	}

	function onTurnEnd()
	{
		this.actor.onTurnEnd();
		this.onSpawnShadow();
	}
	
	function onMovementFinish( _tile )
	{
		this.actor.onMovementFinish(_tile);
		this.onSpawnShadow(_tile);
	}
	
	function onSpawnShadow( _tile = null )
	{
		local myTile = _tile != null ? _tile : this.getTile();
		local p = {
			Type = "shadows",
			Tooltip = "Darkness reigns this place, be fear and be cautious.",
			IsAppliedAtRoundStart = false,
			IsAppliedAtTurnEnd = false,
			IsAppliedOnMovement = true,
			IsAppliedOnEnter = true,
			IsPositive = true,
			Timeout = this.Time.getRound() + 2,
			IsByPlayer = this.isPlayerControlled(),
			Callback = this.Const.MC_Combat.onApplyShadow,
			UserID = this.getID(),
			function Applicable( _a )
			{
				return _a;
			}
		};
		
		if (myTile.Properties.Effect != null && myTile.Properties.Effect.Type == "shadows")
		{
			myTile.Properties.Effect = clone p;
			myTile.Properties.Effect.Timeout = this.Time.getRound() + 2;
		}
		else
		{
			if (myTile.Properties.Effect != null)
			{
				this.Tactical.Entities.removeTileEffect(myTile);
			}

			myTile.Properties.Effect = clone p;
			local particles = [];

			for( local i = 0; i < this.Const.Tactical.ShadowParticles.len(); i = i )
			{
				particles.push(this.Tactical.spawnParticleEffect(true, this.Const.Tactical.ShadowParticles[i].Brushes, myTile, this.Const.Tactical.ShadowParticles[i].Delay, this.Const.Tactical.ShadowParticles[i].Quantity, this.Const.Tactical.ShadowParticles[i].LifeTimeQuantity, this.Const.Tactical.ShadowParticles[i].SpawnRate, this.Const.Tactical.ShadowParticles[i].Stages));
				i = ++i;
			}
			
			this.Tactical.Entities.addTileEffect(myTile, myTile.Properties.Effect, particles);
		}
	}

});

