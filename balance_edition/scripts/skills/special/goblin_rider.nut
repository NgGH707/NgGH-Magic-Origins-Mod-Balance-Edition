this.goblin_rider <- this.inherit("scripts/skills/skill", {
	m = {
		QuirksName = [],
		Manager = null,
		IsInBattle = false,
	},
	function addQuirks( _array )
	{
		this.m.QuirksName.extend(_array);
	}

	function clearQuirks()
	{
		this.m.QuirksName.clear();
	}

	function setManager( _a )
	{
		this.m.Manager = this.WeakTableRef(_a);
	}

	function getManager()
	{
		return this.m.Manager;
	}
	
	function create()
	{
		this.m.ID = "special.goblin_rider";
		this.m.Name = "Mounting";
		this.m.Description = "Have great mobility and tactical advantages but harder to using most ranged weapon while mounted. Gain a biting attack than can be used for free once per turn.";
		this.m.Icon = "ui/perks/impulse_perk.png";
		this.m.IconMini = "impulse_perk_mini";
		this.m.Type = this.Const.SkillType.StatusEffect | this.Const.SkillType.Special;
		this.m.IsActive = false;
		this.m.IsSerialized = false;
	}
	
	function getMountType()
	{
		return this.getManager().getMountType();
	}

	function isMounted()
	{
		return this.m.Manager.isMounted();
	}

	function isHidden()
	{
		return this.skill.isHidden() || !this.isMounted();
	}

	/*function getName()
	{
		if (this.getManager() == null)
		{
			return this.m.Name;
		}
		
		return "[color=#1e468f]" + this.getManager().getMount().getName() + "[/color]";
	}*/

	function getDescription()
	{
		if (this.getManager() == null)
		{
			return this.m.Description;
		}
		
		return "You\'re riding on [color=#1e468f]" + this.getManager().getMount().getName() + "[/color]! There are advantages for doing it, mobility for example. But in the end, there is another life for you to worry for.";
	}

	function getTooltip()
	{
		local IsSpecialized = this.getContainer().hasSkill("perk.mounted_archery");
		local ret = [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			}
		];

		if (this.m.IsInBattle)
		{
			local manager = this.m.Manager;

			ret.extend([
				{
					id = 3,
					type = "text",
					text = "[u][size=14]Health State[/size][/u]"
				},
				{
					id = 4,
					type = "progressbar",
					icon = "ui/icons/armor_head.png",
					value = manager.getArmor(this.Const.BodyPart.Head),
					valueMax = manager.getArmorMax(this.Const.BodyPart.Head),
					text = "" + manager.getArmor(this.Const.BodyPart.Head) + " / " + manager.getArmorMax(this.Const.BodyPart.Head) + "",
					style = "armor-head-slim"
				},
				{
					id = 5,
					type = "progressbar",
					icon = "ui/icons/armor_body.png",
					value = manager.getArmor(this.Const.BodyPart.Body),
					valueMax = manager.getArmorMax(this.Const.BodyPart.Body),
					text = "" + manager.getArmor(this.Const.BodyPart.Body) + " / " + manager.getArmorMax(this.Const.BodyPart.Body) + "",
					style = "armor-body-slim"
				},
				{
					id = 6,
					type = "progressbar",
					icon = "ui/icons/health.png",
					value = manager.getHitpoints(),
					valueMax = manager.getHitpointsMax(),
					text = "" + manager.getHitpoints() + " / " + manager.getHitpointsMax() + "",
					style = "hitpoints-slim"
				}
			]);
		}

		if (this.m.QuirksName.len() != 0)
		{
			/*local quirkString = "";
			
			foreach(i, name in this.m.QuirksName)
			{
				quirkString += name;

				if (i < this.m.QuirksName.len() - 1)
				{
					quirkString += ", ";
				}
			}*/

			local quirkString = "";
			this.m.QuirksName.sort();

			foreach(i, name in this.m.QuirksName)
			{
				if (name && name.len() > 1)
				{
					quirkString = quirkString + ("[color=" + this.Const.UI.Color.NegativeValue + "]" + name.slice(0, 1) + "[/color]" + name.slice(1) + ", ");
				}
			}

			if (quirkString.len() > 2)
			{
				quirkString = quirkString.slice(0, -2);
			}

			ret.extend([
				{
					id = 7,
					type = "text",
					text = "[u][size=14]Quirks Gained[/size][/u]"
				},
				{
					id = 8,
					type = "text",
					icon = "ui/icons/perks.png",
					text = quirkString
				}
			]);
		}
		
		if (this.getMountType() != null)
		{
			local type = this.getMountType();
			local penalty = this.m.Manager.getMountArmor().StaminaModifier;

			ret.extend([
				{
					id = 9,
					type = "text",
					text = "[u][size=14]Stats Modifiers[/size][/u]"
				},
				{
					id = 10,
					type = "text",
					icon = "ui/icons/action_points.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + this.Const.GoblinRiderMounts[type].MountedBonus.ActionPoints + "[/color] Action Points"
				}
			]);

			local a = this.Const.GoblinRiderMounts[type].MountedBonus.Stamina + penalty;

			if (a > 0)
			{
				ret.push({
					id = 11,
					type = "text",
					icon = "ui/icons/fatigue.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + a + "[/color] Max Fatigue"
				});
			}
			else if (a < 0) 
			{
			    ret.push({
					id = 12,
					type = "text",
					icon = "ui/icons/fatigue.png",
					text = "[color=" + this.Const.UI.Color.NegativeValue + "]-" + a + "[/color] Max Fatigue"
				});
			}
				
			a = this.Const.GoblinRiderMounts[type].MountedBonus.Initiative;

			if (a > 0)
			{
				ret.push({
					id = 13,
					type = "text",
					icon = "ui/icons/initiative.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + a + "[/color] Initiative"
				});
			}
			else if (a < 0) 
			{
			    ret.push({
					id = 14,
					type = "text",
					icon = "ui/icons/initiative.png",
					text = "[color=" + this.Const.UI.Color.NegativeValue + "]-" + a + "[/color] Initiative"
				});
			}

			if (IsSpecialized)
			{
				ret.push({
					id = 15,
					type = "text",
					icon = "ui/icons/ranged_skill.png",
					text = "[color=" + this.Const.UI.Color.NegativeValue + "]-10%[/color] Ranged Skill"
				});
			}
			else
			{
			    ret.extend([
				    {
						id = 16,
						type = "text",
						icon = "ui/icons/ranged_skill.png",
						text = "[color=" + this.Const.UI.Color.NegativeValue + "]-35%[/color] Ranged Skill"
					},
					{
						id = 17,
						type = "text",
						icon = "ui/icons/direct_damage.png",
						text = "[color=" + this.Const.UI.Color.NegativeValue + "]-10%[/color] Ranged Damage"
					}
				]);
			}

			a = this.Const.GoblinRiderMounts[type].MountedBonus.MeleeDefense;
			
			if (a > 0)
			{
				ret.push({
					id = 18,
					type = "text",
					icon = "ui/icons/melee_defense.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + a + "[/color] Melee Defense"
				});
			}
			else if (a < 0) 
			{
			    ret.push({
					id = 19,
					type = "text",
					icon = "ui/icons/melee_defense.png",
					text = "[color=" + this.Const.UI.Color.NegativeValue + "]-" + a + "[/color] Melee Defense"
				});
			}
				
			a = this.Const.GoblinRiderMounts[type].MountedBonus.RangedDefense;
			
			if (a != 0)
			{
				ret.push({
					id = 20,
					type = "text",
					icon = "ui/icons/ranged_defense.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + a + "[/color] Ranged Defense"
				});
			}
			else if (a < 0) 
			{
			    ret.push({
					id = 21,
					type = "text",
					icon = "ui/icons/ranged_defense.png",
					text = "[color=" + this.Const.UI.Color.NegativeValue + "]-" + a + "[/color] Ranged Defense"
				});
			}

			a = this.Const.GoblinRiderMounts[type].MountedBonus.Threat;
			
			if (a != 0)
			{
				ret.push({
					id = 22,
					type = "text",
					icon = "ui/icons/special.png",
					text = "Reduces the Resolve of any opponent engaged in melee by [color=" + this.Const.UI.Color.NegativeValue + "]-" + a + "[/color]"
				
				});
			}
		}
		
		ret.push({
			id = 23,
			type = "text",
			icon = "ui/tooltips/warning.png",
			text = "Costs [color=" + this.Const.UI.Color.NegativeValue + "]1[/color] more AP to use any active skill"
		});
		
		return ret;
	}
	
	function onAfterUpdate( _properties )
	{
		if (this.isMounted())
		{
			local IsSpecialized = this.getContainer().hasSkill("perk.mounted_archery");
			_properties.RangedSkillMult *= IsSpecialized ? 0.9 : 0.65;
			_properties.RangedDamageMult *= IsSpecialized ? 1.0 : 0.9;
			_properties.MovementFatigueCostAdditional = 0;
			_properties.MovementAPCostAdditional = 0;
		}
	}

	function onUpdate( _properties )
	{
		if (!this.isMounted())
		{
			return;
		}

		local type = this.getMountType();
		local penalty = this.m.Manager.getMountArmor().StaminaModifier;

		_properties.AdditionalActionPointCost += 1;
		_properties.ActionPoints += this.Const.GoblinRiderMounts[type].MountedBonus.ActionPoints;
		_properties.Stamina += this.Const.GoblinRiderMounts[type].MountedBonus.Stamina + penalty;
		_properties.Initiative += this.Const.GoblinRiderMounts[type].MountedBonus.Initiative;
		_properties.MeleeDefense += this.Const.GoblinRiderMounts[type].MountedBonus.MeleeDefense;
		_properties.RangedDefense += this.Const.GoblinRiderMounts[type].MountedBonus.RangedDefense;
		_properties.Threat += this.Const.GoblinRiderMounts[type].MountedBonus.Threat;
	}

	function onDeath()
	{
		if (this.isMounted() && this.IsAccessoryCompanionsExist)
		{
			local lossPct = this.Math.floor((1 - this.m.Manager.getHitpointsPct()) * 100);
			this.m.Manager.getMount().setWounds(lossPct);
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill != null && _skill.getID() == "actives.throw_balls" && this.isMounted())
		{
			local IsSpecialized = this.getContainer().hasSkill("perk.mounted_archery");
			_properties.RangedSkillMult /= IsSpecialized ? 0.9 : 0.65;
			_properties.RangedDamageMult /= IsSpecialized ? 1.0 :0.9;
		}
	}

	function onTurnStart()
	{
		this.m.Manager.onTurnStart();
	}

	function onCombatStarted()
	{
		this.m.IsInBattle = true;
		this.m.Manager.onCombatStarted();
	}

	function onCombatFinished()
	{
		this.m.IsInBattle = false;
		this.m.Manager.onCombatFinished();
	}

});

