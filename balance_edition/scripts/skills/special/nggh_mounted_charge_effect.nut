this.nggh_mounted_charge_effect <- this.inherit("scripts/skills/skill", {
	m = {
		Stacks = 0,
		BaseBonusMeleeSkill = 3,
		BaseBonusDamage = 0.10,
		BaseBonusDirectDamage = 0.03,
		IsUpgraded = false
	},
	function create()
	{
		this.m.ID = "special.nggh_mounted_charge";
		this.m.Name = "Mounted Charge";
		this.m.Icon = "ui/perks/charge_perk.png";
		this.m.IconMini = "charge_perk_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
	}

	function getDescription()
	{
		return "This character is gaining great speed to prepare for a desvastating mounted charge. Bad terrain, uneven terrain, wait or end turn will reset this effect.";
	}

	function getTooltip()
	{
		local meleeSkill = this.m.BaseBonusMeleeSkill;
		local meleeDamage = this.m.BaseBonusDamage * 100;
		local damgeDirect = this.m.BaseBonusDirectDamage * 100;
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
			},
			/*{
				id = 6,
				type = "text",
				icon = "ui/icons/melee_skill.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + meleeSkill + "[/color] Melee Defense"
			},*/
			{
				id = 6,
				type = "text",
				icon = "ui/icons/regular_damage.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + meleeDamage + "%[/color] Melee Damage"
			},
			{
				id = 6,
				type = "text",
				icon = "ui/icons/direct_damage.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + damgeDirect + "%[/color] Melee Direct Damage"
			},
		];

		if (this.m.Stacks >= 3)
		{
			ret.extend([
				{
					id = 6,
					type = "text",
					icon = "ui/icons/special.png",
					text = "All active skills cost [color=" + this.Const.UI.Color.PositiveValue + "]1[/color] less AP"
				},
				{
					id = 6,
					type = "text",
					icon = "ui/icons/special.png",
					text = "All active skills build up [color=" + this.Const.UI.Color.PositiveValue + "]25%[/color] less fatigue"
				},
			]);
		}

		return ret;
	}

	function isHidden()
	{
		return this.m.Stacks == 0;
	}

	function resetCounter()
	{
		this.m.Stacks = 0;
	}

	function resetAll()
	{
		this.m.Stacks = 0;
		this.m.BaseBonusMeleeSkill = 3;
		this.m.BaseBonusDamage = 0.10;
		this.m.BaseBonusDirectDamage = 0.03;
		this.m.IsUpgraded = false;
	}

	function setImproveChargeEffect()
	{
		this.m.BaseBonusMeleeSkill = 5;
		this.m.BaseBonusDamage = 0.15;
		this.m.BaseBonusDirectDamage = 0.05;
		this.m.IsUpgraded = true;
	}

	function onMovementStarted( _tile, _numTiles )
	{
		//this.m.Stacks = _numTiles;
	}

	function onMovementFinished( _tile )
	{
	}

	function onMovementStep( _tile, _levelDifference )
	{
		if (_tile.Type >= this.Const.Tactical.TerrainType.Swamp || _levelDifference != 0)
		{
			this.resetCounter();
		}
		else
		{
			++this.m.Stacks;
		}
	}

	function onWaitTurn()
	{
		this.resetCounter();
	}

	function onTurnEnd()
	{
		this.resetAll();
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		if (this.m.IsUpgraded && _targetEntity.isAlive() && !_targetEntity.isDying())
		{
			if (_targetEntity.isNonCombatant() || _targetEntity.getCurrentProperties().IsImmuneToKnockBackAndGrab)
			{
				this.applyEffect(_targetEntity);
			}
			else
			{
				this.onKnockingBack(_targetEntity);
			}
		}

		this.resetAll();
		this.getContainer().getActor().setDirty(true);
	}

	function onTargetMissed( _skill, _targetEntity )
	{
		this.resetAll();
		this.getContainer().getActor().setDirty(true);
	}

	function onUpdate( _properties )
	{
		if (this.m.Stacks >= 3)
		{
			_properties.AdditionalActionPointCost -= 1;
			_properties.FatigueEffectMult *= 0.75;
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill.isAttack() && !_skill.isRanged() && this.m.Stacks != 0)
		{
			//_properties.MeleeSkill += this.m.Stacks * this.m.BaseBonusMeleeSkill;
			_properties.MeleeDamageMult *= 1.0 + this.m.Stacks * this.m.BaseBonusDamage;
			_properties.DamageDirectMult *= 1.0 + this.m.Stacks * this.m.BaseBonusDirectDamage;

			if (_targetEntity != null)
			{
				local d = this.getContainer().getActor().getTile().getDistanceTo(_targetEntity.getTile());

				if (d > 1)
				{
					//_properties.MeleeSkill -= this.m.Stacks * this.m.BaseBonusMeleeSkill;
					_properties.MeleeDamageMult /= 1.0 + this.m.Stacks * this.m.BaseBonusDamage;
					_properties.DamageDirectMult /= 1.0 + this.m.Stacks * this.m.BaseBonusDirectDamage;
				}
			}
		}
	}

	function findTileToKnockBackTo( _userTile, _targetTile )
	{
		local dir = _userTile.getDirectionTo(_targetTile);

		if (_targetTile.hasNextTile(dir))
		{
			local knockToTile = _targetTile.getNextTile(dir);

			if (knockToTile.IsEmpty && this.Math.abs(knockToTile.Level - _userTile.Level) <= 1)
			{
				return knockToTile;
			}
		}

		local altdir = dir - 1 >= 0 ? dir - 1 : 5;

		if (_targetTile.hasNextTile(altdir))
		{
			local knockToTile = _targetTile.getNextTile(altdir);

			if (knockToTile.IsEmpty && this.Math.abs(knockToTile.Level - _userTile.Level) <= 1)
			{
				return knockToTile;
			}
		}

		altdir = dir + 1 <= 5 ? dir + 1 : 0;

		if (_targetTile.hasNextTile(altdir))
		{
			local knockToTile = _targetTile.getNextTile(altdir);

			if (knockToTile.IsEmpty && this.Math.abs(knockToTile.Level - _userTile.Level) <= 1)
			{
				return knockToTile;
			}
		}

		return null;
	}

	function applyEffect( _targetEntity, _isKnockBack = false )
	{
		if (_isKnockBack)
		{
			if (this.Math.rand(1, 4) > 1)
			{
				_targetEntity.getSkills().add(this.new("scripts/skills/effects/staggered_effect"));
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_targetEntity) + " is staggered for one turn");
			}
			else
			{
				_targetEntity.getSkills().add(this.new("scripts/skills/effects/dazed_effect"));
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_targetEntity) + " is dazed for one turn");
			}
		}
		else
		{
			_targetEntity.getSkills().add(this.new("scripts/skills/effects/dazed_effect"));
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_targetEntity) + " is dazed for one turn");
		}
	}

	function onKnockingBack( _targetEntity )
	{
		local user = this.getContainer().getActor();
		local knockToTile = this.findTileToKnockBackTo(user.getTile(), _targetEntity.getTile());

		if (knockToTile == null)
		{
			this.applyEffect(_targetEntity);
			return;
		}

		if (!user.isHiddenToPlayer() && (_targetEntity.getTile().IsVisibleForPlayer || knockToTile.IsVisibleForPlayer))
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(user) + " has knocked back " + this.Const.UI.getColorizedEntityName(_targetEntity));
		}

		this.applyEffect(_targetEntity, true);
		local skills = _targetEntity.getSkills();
		skills.removeByID("effects.shieldwall");
		skills.removeByID("effects.spearwall");
		skills.removeByID("effects.riposte");

		_targetEntity.setCurrentMovementType(this.Const.Tactical.MovementType.Involuntary);
		local damage = this.Math.max(0, this.Math.abs(knockToTile.Level - _targetEntity.getTile().Level) - 1) * this.Const.Combat.FallingDamage;
		if (damage == 0)
		{
			this.Tactical.getNavigator().teleport(_targetEntity, knockToTile, this.onMoveForward, 
			{
				Attacker = user,
				Skill = this,
				Tile = knockToTile,
			}, true, 2.0);
		}
		else
		{
			local p = user.getCurrentProperties();
			local tag = {
				Attacker = user,
				Skill = this,
				HitInfo = clone this.Const.Tactical.HitInfo
				Tile = knockToTile,
			};
			tag.HitInfo.DamageRegular = damage;
			tag.HitInfo.DamageDirect = 1.0;
			tag.HitInfo.BodyPart = this.Const.BodyPart.Body;
			tag.HitInfo.BodyDamageMult = 1.0;
			tag.HitInfo.FatalityChanceMult = 1.0;
			this.Tactical.getNavigator().teleport(_targetEntity, knockToTile, this.onKnockedDown, tag, true);
		}
	}

	function onKnockedDown( _entity, _tag )
	{
		if (_tag.Skill.m.SoundOnHit.len() != 0)
		{
			this.Sound.play(_tag.Skill.m.SoundOnHit[this.Math.rand(0, _tag.Skill.m.SoundOnHit.len() - 1)], this.Const.Sound.Volume.Skill, _entity.getPos());
		}

		if (_tag.HitInfo.DamageRegular != 0)
		{
			_entity.onDamageReceived(_tag.Attacker, _tag.Skill, _tag.HitInfo);
		}

		_tag.Skill.onMoveForward(_entity, _tag);
	}

	function onMoveForward( _entity, _tag )
	{
		if (!_tag.Tile.IsOccupiedByActor)
		{
			this.Tactical.getNavigator().teleport(_tag.Attacker, _tag.Tile, null, null, true);
		}

		//_entity.setCurrentMovementType(this.Const.Tactical.MovementType.Involuntary);
		//this.Time.scheduleEvent(this.TimeUnit.Virtual, 150, function( _tag )
		//{
		//	
		//}, _tag);
	}

});

