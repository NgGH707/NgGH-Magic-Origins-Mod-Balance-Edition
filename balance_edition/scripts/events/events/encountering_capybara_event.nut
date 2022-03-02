this.encountering_capybara_event <- this.inherit("scripts/events/event", {
	m = {
		Finder = null
		Bystander = null,
	},
	function create()
	{
		this.m.ID = "event.encountering_capybara";
		this.m.Title = "While camping...";
		this.m.Cooldown = 44.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "%terrainImage%{While %finder% is going for a piss, a Capybara watches %finder% let down a thunderous waterfall ravaging a small bush nearby.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Pet it.",
					function getResult( _event )
					{
						return "B";
					}
				},
				{
					Text = "Piss on it.",
					function getResult( _event )
					{
						return "C";
					}
				},
				{
					Text = "Let it watch.",
					function getResult( _event )
					{
						_event.m.Finder.improveMood(2.0, "Yes! i'm a pervert");
						return 0;
					}
				},
				{
					Text = "Snatch it back to camp.",
					function getResult( _event )
					{
						return "D";
					}
				},
				{
					Text = "Run back to camp.",
					function getResult( _event )
					{
						return "E";
					}
				}
			],
			function start( _event )
			{
				this.Banner = "ui/icons/capybara.png";
				this.Characters.push(_event.m.Finder.getImagePath());
				local post_text = "";

				switch (this.Math.rand(1, 3))
				{
				case 1:
					_event.m.Finder.improveMood(0.1, "Embarrassed because someone watched me taking a piss");
					post_text = " is embarrassed";
					break;

				case 2:
					_event.m.Finder.improveMood(1.0, "Did a exhibitionism watersports in front of a capybara");
					post_text = " oddly feels aroused";
					break;
			
				default:
					_event.m.Finder.worsenMood(0.5, "Why did that capybara watch so intensely?");
					post_text = " doesn\'t like the current situation";
				}
				
				this.List.extend([
					{
						id = 10,
						icon = "ui/icons/asset_brothers.png",
						text = _event.m.Finder.getName() + post_text
					},
					{
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Finder.getMoodState()],
						text = _event.m.Finder.getName() + this.Const.MoodStateEvent[_event.m.Finder.getMoodState()]
					}
				]);
			}
		});


		this.m.Screens.push({
			ID = "B",
			Text = "%terrainImage%{%finder% pets the perverted capybara. It seems to like the head pat.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "What a naughty boy.",
					function getResult( _event )
					{
						return 0;
					}
				},
			],
			function start( _event )
			{
				this.Banner = "ui/icons/capybara.png";
				this.Characters.push(_event.m.Finder.getImagePath());
				_event.m.Finder.improveMood(1.0, "Want to have a capybara as pet");
				
				this.List.extend([
					{
						id = 10,
						icon = "ui/icons/asset_brothers.png",
						text = _event.m.Finder.getName() + " is fallen for capybara charm "
					},
					{
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Finder.getMoodState()],
						text = _event.m.Finder.getName() + this.Const.MoodStateEvent[_event.m.Finder.getMoodState()]
					}
				]);
			}
		});


		this.m.Screens.push({
			ID = "C",
			Text = "%terrainImage%{%finder% pisses on the capybara but it doesn\'t seem to mind this.",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Why did i think this will be a good idea?",
					function getResult( _event )
					{
						return 0;
					}
				},
			],
			function start( _event )
			{
				this.Banner = "ui/icons/capybara.png";
				this.Characters.push(_event.m.Finder.getImagePath());
				local post_text = "";

				if (this.Math.rand(1, 100) <= 50)
				{
					this.Text += " %finder% starts to question his own sanity.}";
					post_text = " is weirded out";
					_event.m.Finder.worsenMood(1.0, "I have done something really really really weird");
				}
				else
				{
					this.Characters.push(_event.m.Bystander.getImagePath());
					this.Text += " Suddenly %bystander% shows up from nowhere. There is a look of drunk and surprise on %bystander%, as %bystander% stares at the 'business' %finder% are doing. The two look at each other for a little while the sound of water splashing are in the background. %bystander% says nothing, turns back amd walks away leaving %finder% with a soaping wet capybara.}" 
					post_text = " can\'t meet " + _event.m.Bystander.getNameOnly() + "\'s eyes again";
					_event.m.Finder.worsenMood(2.0, "Deeply embarrassed by a \'certain\' event");
					_event.m.Bystander.worsenMood(0.5, "Saw an unseenable thing");

					this.List.extend([
						{
							id = 10,
							icon = "ui/icons/asset_brothers.png",
							text = _event.m.Bystander.getName() + " is distured by the scene"
						},
						{
							id = 10,
							icon = "ui/icons/relations.png",
							text = _event.m.Bystander.getName() + " opinion about " + _event.m.Finder.getName() + " drops sharply"
						},
					]);

					if (_event.m.Bystander.getMoodState() < this.Const.MoodState.Neutral)
					{
						this.List.push({
							id = 10,
							icon = this.Const.MoodStateIcon[_event.m.Bystander.getMoodState()],
							text = _event.m.Bystander.getName() + this.Const.MoodStateEvent[_event.m.Bystander.getMoodState()]
						});
					}
				}
				
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_brothers.png",
					text = _event.m.Finder.getName() + post_text
				});

				if (_event.m.Finder.getMoodState() < this.Const.MoodState.Neutral)
				{
					this.List.push({
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Finder.getMoodState()],
						text = _event.m.Finder.getName() + this.Const.MoodStateEvent[_event.m.Finder.getMoodState()]
					});
				}
			}
		});


		this.m.Screens.push({
			ID = "D",
			Text = "%terrainImage%{%finder% goes straight to the capybara, it doesn\'t do anything or try to run. %finder% tries to snatch the giant rodent but faces fiercing resistance. The Capybare uses \'Headbutt\', hits right in %finder%\'s snake. Causing him cry in agony while the rodent runs away, maybe return to its friends.\n\nLesson learned, never try to abduct a capybara watching someone taking a piss.}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "My snake!",
					function getResult( _event )
					{
						return 0;
					}
				},
			],
			function start( _event )
			{
				this.Banner = "ui/icons/capybara.png";
				this.Characters.push(_event.m.Finder.getImagePath());
				_event.m.Finder.improveMood(2.0, "Broke his snake due to a \'certain\' event");
				
				this.List.extend([
					{
						id = 10,
						icon = "ui/icons/asset_brothers.png",
						text = _event.m.Finder.getName() + " is totally pissed"
					},
					{
						id = 10,
						icon = this.Const.MoodStateIcon[_event.m.Finder.getMoodState()],
						text = _event.m.Finder.getName() + this.Const.MoodStateEvent[_event.m.Finder.getMoodState()]
					}
				]);
			}
		});


		this.m.Screens.push({
			ID = "E",
			Text = "[img]gfx/ui/events/event_26.png[/img]{%finder% runs back to camp with haste. Telling everyone about what he has found, some laugh as it\'s a joke, some feel interested in it.}",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "I should have petted that capybara",
					function getResult( _event )
					{
						return 0;
					}
				},
			],
			function start( _event )
			{
				this.Characters.push(_event.m.Finder.getImagePath());
			}
		});
	}

	function onUpdateScore()
	{
		if (this.World.getPlayerRoster().getAll().len() <= 2)
		{
			return;
		}

		if (this.World.Flags.get("IsLuftAdventure"))
		{
			this.m.Score = this.Math.rand(15, 35);
		}
		else
		{
			this.m.Score = this.Math.rand(10, 25);
		}
	}

	function onPrepare()
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local priority = [];
		local betterThanNothing = [];

		foreach ( bro in brothers )
		{
			if ((bro.getFlags().has("luft") || bro.getFlags().has("IsPlayerCharacter")) && this.Math.rand(1, 100) <= 15)
			{
				priority.push(bro);
			}
			else
			{
				betterThanNothing.push(bro);
			}
		}

		if (priority.len() > 0)
		{
			this.m.Finder = priority[0];
		}
		else
		{
			this.m.Finder = this.MSU.Array.getRandom(betterThanNothing);
		}

		while(this.m.Bystander == null)
		{
			local roll = this.MSU.Array.getRandom(brothers);

			if (roll.getID() != this.m.Finder.getID())
			{
				this.m.Bystander = roll;
			}
		}
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"finder",
			this.m.Finder.getName()
		]);
		_vars.push([
			"bystander",
			this.m.Bystander.getName()
		]);
	}

	function onClear()
	{
		this.m.Finder = null;
		this.m.Bystander = null;
	}

});

