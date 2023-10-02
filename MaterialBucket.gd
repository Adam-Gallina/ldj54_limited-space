extends Node

var stored_materials = {}

func deposit_material(mat: Constants.MaterialType, amount: int):
	if !stored_materials.has(mat):
		stored_materials[mat] = amount
	else:
		stored_materials[mat] += amount
		
	return 0

func can_withdraw(mat: Constants.MaterialType, amount: int):
	if !stored_materials.has(mat):
		return false
	return stored_materials[mat] >= amount

func withdraw_material(mat: Constants.MaterialType, amount: int):
	if !stored_materials.has(mat):
		return amount
	
	stored_materials[mat] -= amount
	
	if stored_materials[mat] < 0:
		var val = -stored_materials[mat]
		stored_materials[mat] = 0
		return val
	
	return 0
