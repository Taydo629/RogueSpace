extends Node

var grid: Array = [[null,null,null,null,null],
				[null,null,null,null,null],
				[null,null,null,null,null],
				[null,null,null,null,null],
				[null,null,null,null,null]]
var y_range: Array = [192,448]
var x_range: Array = [448,704]

func update_ship(new_grid: Array):
	grid = new_grid
