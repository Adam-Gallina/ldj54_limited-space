extends Node

var _game = null
var Game:
	get:
		if _game == null: 
			_game = get_node('/root/Game')
		return _game

enum MaterialType { 
	None, 
	Metal, 
	Gas, 
	Food, 
	Electronic, 
	Bomb 
}

func MaterialName(mat: MaterialType): return MaterialType.keys()[mat]
