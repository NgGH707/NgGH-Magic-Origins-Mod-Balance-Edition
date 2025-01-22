::Nggh_MagicConcept.HooksMod.hook("scripts/skills/actives/legend_grow_greenwood_shield_skill", function ( q )
{
	q.create = @(__original) function()
	{
		__original();
		m.Name = "Grow Greenwood Shield";
		m.Description = "Regrow your bark, producing a protective shield";
		m.Icon = "skills/active_121.png";
		m.IconDisabled = "skills/active_121_sw.png";
		m.Overlay = "active_121";
		m.Order = ::Const.SkillOrder.NonTargeted + 1;
	}

	q.onAdded <- function()
	{
		if (::Nggh_MagicConcept.Mod.ModSettings.getSetting("balance_mode").getValue() && ::isKindOf(getContainer().getActor(), "player"))
			setBaseValue("FatigueCost", 50);
	}

	q.getTooltip <- function()
	{
		local ret = skill.getDefaultUtilityTooltip();
		ret.push({
			id = 4,
			type = "text",
			icon = "/ui/icons/melee_defense.png",
			text = "Grants a [color=" + ::Const.UI.Color.PositiveValue + "]+40[/color] Melee and Ranged Defense shield, with [color=" + ::Const.UI.Color.PositiveValue + "]64[/color] durability"
		});

		if (getContainer().getActor().getCurrentProperties().IsSpecializedInHammers)
			ret.push({
				id = 10,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Gains [color=" + ::Const.UI.Color.PositiveValue + "]Shieldwall[/color] effect for free when growing a new shield"
			});

		return ret;
	}

	q.onAfterUpdate <- function( _properties )
	{
		m.FatigueCostMult = _properties.IsSpecializedInHammers ? ::Const.Combat.WeaponSpecFatigueMult : 1.0;
	}

	q.onUse = @(__original) function( _user, _targetTile )
	{
		local ret = __original(_user, _targetTile);

		if (_user.getCurrentProperties().IsSpecializedInHammers) {
			::Time.scheduleEvent(::TimeUnit.Virtual, 2000, function ( _itsMe ) {
				local shield = _itsMe.getOffhandItem();
				if (shield != null && shield.isItemType(::Const.Items.ItemType.Shield))
					_itsMe.getSkills().add(::new("scripts/skills/effects/shieldwall_effect"));
			}, _user);
		}
		
		return ret;
	}
});