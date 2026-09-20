extends Control

enum MAP_NODES{START,COMBAT,SHIPYARD,MERCHANT,NEUTRAL,BOSS}

#var map_layer: Dictionary[MAP_NODES, Dictionary] = {
	#MAP_NODES: {
		#"occupied"
	#}
#}

var map_graph: Dictionary[MAP_NODES, Dictionary] = {
	MAP_NODES.START: {
		"occupied": true,
		"reachable": true,
		"neighbors": [MAP_NODES.COMBAT,MAP_NODES.MERCHANT,MAP_NODES.NEUTRAL]
	},
	MAP_NODES.COMBAT: {
		"occupied": false,
		"reachable": true,
		"neighbors": [MAP_NODES.MERCHANT]
	}
}
