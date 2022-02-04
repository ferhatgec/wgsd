# MIT License
#
# Copyright (c) 2022 Ferhat Geçdoğan All Rights Reserved.
# Distributed under the terms of the MIT License.
#
# wgsd (aka when gech stores data) - a data interface for my game,
# which is easier to parse and read.
#
# usage:
#  preload the script, var wgsd_init = preload("res://scenes/wgsd.gd")
#  create a variable, contains main class, var gech = wgsd_init.wgsd.new()
#  parse file, gech.parse_file("...")
#  time to find the value, use gech.find_key("profile_name", "key_name")
#  the function may return your value as well as casted (to boolean, integer, float etc). 
#
# syntax:
#
# # comment line
#
# profile1 =
# 	use_music; true;
# 	last_checkpoint; empty;
# 	character_name; gech;
# end; profile1;
#
# profile2 =
# 	empty; true;
# end; profile2;
#
# profile3 = 
# 	age; 16;
# end; profile3;
#
#
# gech.find_key("profile1", "use_music") (returns True)
#

class block_wgsd:
	var block_name = "undefined"
	var matched_datas = {}
	
class wgsd:
	var nodes = []
	var raw_file: String = ""
	
	func clear():
		self.nodes = []
		self.raw_file = ""
	
	func reparse_file(file):
		self.clear()
		self.parse_file(file)
		
	# regenerate script by given generated nodes.
	# not including comments etc. that are not stored,
	# ignored while parsing.
	func generate():
		var generate = ""
		for node in self.nodes:
			generate += node.block_name + " =\n"
			
			for node_key in node.matched_datas:
				var val = node.matched_datas[node_key]
				
				generate += str(node_key) + ";" + str(val) + ";\n"
			
			generate += "end; " + node.block_name + ";\n"
			
		return generate
				
	func _reverse_pair_values(val):
		match val:
			true:
				return "true";
				
			false:
				return "false";
				
			"":
				return "empty";
				
			_: 
				return str(val)
	
	func _pair_values(val):
		match val:
			"true":
				return true;
			
			"false":
				return false;
			
			"empty":
				return "";
			
			_:
				if val.is_valid_integer():
					return int(val)
				elif val.is_valid_float():
					return float(val)
				else:
					return val
					
	
	func change_key(block, key, replace):
		for node in self.nodes:
			if node.block_name == block:
				if node.matched_datas.has(key):
					node.matched_datas[key] = self._reverse_pair_values(replace)
	
	# block can be undefined
	func find_key(block, key):
		for node in self.nodes:
			if node.block_name == block:
				if node.matched_datas.has(key):
					return self._pair_values(node.matched_datas[key])
				else:
					return ""
					
	func _verify():
		for node in self.nodes:
			for child_node in self.nodes:
				if node.block_name == child_node.block_name:
					self.nodes.erase(child_node)
		
	func parse_file(file):
		var is_block = false
		
		var raw = File.new()
		raw.open(file, File.READ)
		self.raw_file = raw.get_as_text()
		raw.close()
		
		for line in self.raw_file.split('\n'):
			line = line.strip_edges(true, true)
			if len(line) > 0:
				match line[0]:
					'#':
						pass
					
					_:
						if not is_block:
							is_block = true
							var x = line.split(' ')
							if len(x) > 0 and x[1] == '=':
								var y = block_wgsd.new()
								y.block_name = x[0]
								self.nodes.append(y)
							
							continue
						else:
							var x = line.split(';')
							
							if len(x) >= 2:
								if x[0] == "end":
									is_block = false
								else:
									var y = self.nodes[len(self.nodes) - 1]
									y.matched_datas[x[0]] = x[1].strip_edges(true, true)
							
							continue
							
						self._verify()

