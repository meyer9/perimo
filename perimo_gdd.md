# Game Design Document: Perimo

The purpose of this document is to communicate a concrete vision for Perimo, describe its contents in detail, and suggest a plan for its implementation.

This is a living document that is subject to continuous editing and revisal as development progresses. As different directions are explored, over time it shall become an elaborate archive of all aspects of the game.

1. **Game Overview**
	- Concept
	
		An overhead massively multiplayer game consisting of various monsters that players will have to work together to defeat, collecting gear, and leveling up their character along the way.
	
	- Genre
	
		A top-down RPG set in an ancient Roman world where gladiators fight monsters.
		
	- Target Audience

		PC gamers who like to play 2D RPG games.
		
	- Visual Style
		
		Art is done in a pixel-art based style with sandy colors and dark monsters.
		
	- Scope
	
		Players will play with other players around the world in a open-world island with randomly generated terrain, locations, and monsters.
		
2. **Gameplay and Mechanics**

	- Gameplay
		- Game Progression
		
			Players will begin as a simple character with a basic weapon, armor, and a few simple potions. By defeating monsters and collecting experience, they can level up their character which levels up that character's stats. When they die, players will lose all of their items, but will keep their experience.
			
		- Mission/Challenge Structure

			Throughout their adventure on the island, players will be assigned quests to complete which will grant them additional XP. In addition, player's quests will be based on their level.
			
			- Quest Types
				- Defeat boss
				- Buy an item
				- Earn X gold
				- Visit some location

		- Objectives
		
			Overall, the final objective of the island is to defeat the Epirus which is a large boss in the center of the island which deals deadly blows to players fighting. This boss will require team work to kill and its stats will be based on the total stats of players in the current game.
			
		- Play Flow

			Players will at first fight small lower xp monsters on the edges of the map where they can level up their character and find some small amount of loot. Eventually when they are ready, they will progress inward and fight larger monsters. When they reach the max level, their character will be able to challenge giant monsters in the center of the island.
			
	- Mechanics
		- Movement
			- General Movement
				
				Players will move as in most rogue-like RPG games with WASD, using their mouse to aim.
				
			- Special Movement
			
				Some characters will allow for special movement such as teleporting to a certain marked place on the map, or teleporting to wherever the mouse is, but any special movement will require mana/stamina.
		
		- Items
			
			Items will be able to be traded with other players, dropped on the ground, and used in certain slots on the character. Characters will be able to use any weapon, but some stats may influence certain weapons more than others. (Magic, Strength, Archery)
			
		- Actions
		
			During a fight, players will be able to attack the opponent or block the opponents' attack. Each type of attack will be influenced differently by blocking. For example, magic will be able to easily penetrate through a shield, but a sword will not be able to.
			
		- Weapons

			Weapons will be found in chests around the world and bag dropped by enemies. Higher tier enemies (indicated by their tier number) will consequently hold higher tier items.
			
			- Classes
				
				Weapons will have a certain class which is influenced by a certain stat. There will currently be 3 types of weapon as is standard in an RPG.
				
				- Archery - strong to magic; weak to melee
				- Melee - strong to archery; weak to magic
				- Magic - strong to melee; weak to archery

		- Defense
		
			Both the Archery and Melee classes will use shields as their form of defense. Magic will use spells, costing mana, to form defense which is why magic is strong against melee attacks.
			
		- Combat

			Combat will be mostly cooperative and will incentivize diverse teams of players. Combat will take place using a simple point to shoot idea, where the player will shoot where he is aiming.
			
			- PVP
				
				Players will be able to join an arena with up to 3 other players to fight against each other and wager on the outcome. In addition, players will have a rank in the arena and will be able to earn gold if they are in the top players.
			
		- Stats

			Each class will have a respective stat to level up with potions.
			
			- Potions
			
				Potions are not permanent and will be removed on death. In addition, potions will be found in chests and loot bags.
			
		- Screen Flow			
			- Main Menu
				- Options
				- Play
			- Pause Menu
				- Options
				- Exit to Main Menu
				- Exit to Desktop
3. **Technical**

	- Target Platform
		
		Mac, Windows, Linux, Steam Play (completely cross platform)
		
	- Development Procedures and Standards
	
		Follow DRY. Descriptive names. Readable Code.
		
	- Network
	
		Use LuaSocket built into Love2D.
		
	- Programming Languages

		Lua with Love for game server and client. NodeJS for matchmaking? and player login? (Steam)