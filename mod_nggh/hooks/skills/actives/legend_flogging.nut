::mods_hookExactClass("skills/actives/legend_flogging", function ( obj )
{
	local ws_onAfterUpdate = obj.onAfterUpdate;
	obj.onAfterUpdate = function( _properties )
	{
		local special = this.getContainer().getSkillByID("perk.bdsm_mask_on");

		if (special != null)
		{
			this.m.FatigueCost = ::Math.max(1, this.m.FatigueCost - special.getBonus());
		}

		ws_onAfterUpdate(_properties);
	}
});