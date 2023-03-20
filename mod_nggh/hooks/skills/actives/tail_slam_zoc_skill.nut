::mods_hookExactClass("skills/actives/tail_slam_zoc_skill", function ( obj )
{
	local ws_create = obj.create;
	obj.create = function()
	{
		ws_create();
		this.m.IsHidden = true;
	};
	obj.isUsable <- function()
	{
		return this.m.IsUsable && this.getContainer().getActor().getCurrentProperties().IsAbleToUseSkills;
	};
});