

import re
import os

class_pattern = re.compile("final class (.+) extends ffi.Struct")
union_pattern = re.compile("final class (.+) extends ffi.Union")
typedef_pattern = re.compile("typedef (.+?)_t = (.+);")
pointer_pattern = re.compile("Pointer<(.+?)>")

def extract_struct_fields(dart_code: str, struct_name: str):
		# Step 1: Match the whole struct block
		pattern = re.compile(
				rf"final class {re.escape(struct_name)} extends ffi\.Struct\s*{{(.*?)}}",
				re.DOTALL
		)
		match = pattern.search(dart_code)
		if not match:
				raise ValueError(f"Struct {struct_name} not found.")

		struct_body = match.group(1)

		# Step 2: Extract fields
		field_pattern = re.compile(
				r'(?:@[\w<>\.\(\)_]+)?\s*'										 # Optional decorator
				r'(?:@(?P<decorator>[\w<>\.\(\)_]+))?\s*'			# Capture decorator separately
				r'external\s+(?P<type>[^\s]+)\s+(?P<name>\w+);'	# Capture type and name
		)

		fields = []
		for field_match in field_pattern.finditer(struct_body):
				if(field_match.group("name") != "_asn_ctx"):
					fields.append({
							"decorator": field_match.group("decorator"),
							"type": field_match.group("type"),
							"name": field_match.group("name")
					})

		return {
				"name": struct_name,
				"fields": fields
		}

def extract_union_fields(dart_code: str, union_name: str):
		# Step 1: Match the whole struct block
		pattern = re.compile(
				rf"final class {re.escape(union_name)} extends ffi\.Union\s*{{(.*?)}}",
				re.DOTALL
		)
		match = pattern.search(dart_code)
		if not match:
				raise ValueError(f"Struct {union_name} not found.")

		struct_body = match.group(1)

		# Step 2: Extract fields
		field_pattern = re.compile(
				r'(?:@[\w<>\.\(\)_]+)?\s*'										 # Optional decorator
				r'(?:@(?P<decorator>[\w<>\.\(\)_]+))?\s*'			# Capture decorator separately
				r'external\s+(?P<type>[^\s]+)\s+(?P<name>\w+);'	# Capture type and name
		)

		fields = []
		for field_match in field_pattern.finditer(struct_body):
				if(field_match.group("name") != "_asn_ctx"):
					fields.append({
							"decorator": field_match.group("decorator"),
							"type": field_match.group("type"),
							"name": field_match.group("name")
					})

		return {
				"name": union_name,
				"fields": fields
		}

def get_dart_type(type:str):
	type_map = {
		"ffi.Long":"int",
		"ffi.Int32":"int",
	}

	if type in type_map:
		return type_map[type]
	else:
		return type

def is_field_nullable(field:dict):
	 return "Pointer" in field.get("type","")

def get_pointer_type(pointer):
	pointer_type = pointer_pattern.findall(pointer)
	if len(pointer_type) > 0:
		return pointer_type[0]
	else:
		return ""
	 

def get_field_string(field:dict):
	if is_field_nullable(field):
		pointer_type = get_pointer_type(field.get("type"))
		return f"\t{pointer_type} {field.get("name","unknownName")} = null;\n"
	else:
		return f"\tlate {get_field_type(field)} {field.get("name","unknownName")};\n"

def trim_decorator(decorator: str):
	return decorator[0:decorator.index("(")]

def get_field_type(field:dict):
	if field.get("decorator",None) != None:
		return get_dart_type(trim_decorator(field.get("decorator")))
	else:
		return get_dart_type(field.get("type",""))

def is_field_primative(field):
	if get_field_type(field) in ["int"]:
		return True
	return False

def get_field_constructor(field:dict):
	constructor = ""
	if is_field_nullable(field):
		pointer_type = get_pointer_type(get_field_type(field))
		print(pointer_type)
		constructor += f"\t\tif(c_obj.{field.get("name","")}.address != 0){{\n"
		constructor += f"\t\t\t{field.get("name","unknownName")} = {pointer_type}.fromC(c_obj.{field.get("name","")});\n"
		constructor += f"\t\t}}\n\n"
	else:
		if is_field_primative(field):
			constructor += f"\t\t{field.get("name","unknownName")} = c_obj.{field.get("name","")};\n"
		else:
			constructor += f"\t\t{field.get("name","unknownName")} = {get_field_type(field)}.fromC(c_obj.{field.get("name","")});\n"
	

	return constructor
	
def convert_to_snake_case(name:str):
	return re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower()

def write_class(class_name, class_info):
	file_name = convert_to_snake_case(class_name)
	file_path = f"j2735/{file_name}.dart"
	with open(file_path, 'w') as o:
		class_str = ""

		class_str += "import 'package:asn1_plugin/generated_bindings.dart' as C;\n"
		class_str += "import 'dart:ffi';\n"
		class_str += "import 'package:asn1_plugin/j2735/j2735.dart';\n"

		class_str += f"class {class_name}" + "{\n"

		for field in class_info.get("fields",[]):
			class_str += get_field_string(field)

		
		class_str += f"\n\t{class_name}.fromC(C.{class_name} c_obj)" + "{\n"

		for field in class_info.get("fields",[]):
			class_str += get_field_constructor(field)

		class_str += "\t}\n"
		class_str += "}\n"

		o.write(class_str)
		o.write("//" + str(class_info))
	return file_path
		



def write_typedef_class(class_name, class_type):
	file_name = convert_to_snake_case(class_name)
	file_path = f"j2735/{file_name}.dart"
	type_name = convert_to_snake_case(class_type)
	with open(file_path, 'w') as o:
		class_str = ""
		class_str += f"class {class_name}" + "{\n"
		class_str += f"\tlate {get_dart_type(class_type)} {file_name};\n"
		class_str += f"\t{class_name}(this.{file_name})\n";
		class_str += "}\n"
		o.write(class_str)


with open("generated_bindings.dart", 'r+') as f:
	data = f.read()

	if(not os.path.exists('j2735')):
		os.mkdir("j2735")




	paths = []

	# for m in typedef_pattern.findall(data):
	# 	write_typedef_class(m[0], m[1])

	class_names = class_pattern.findall(data)
	union_names = union_pattern.findall(data)

	class_proc_list = ["TravelerDataFrame"]
	union_proc_list = []

	while len(class_proc_list) > 0:
		class_name = class_proc_list.pop(0)
		class_info = extract_struct_fields(data, class_name)
		write_class(class_name, class_info)

		for field in class_info.get("fields"):
			if get_field_type(field) in class_names:
				class_proc_list.append(get_field_type(field))

			if get_field_type(field) in union_names:
				union_proc_list.append(get_field_type(field))

	while len(union_proc_list) > 0:
		union_name = union_proc_list.pop(0)
		union_info = extract_union_fields(data, union_name)
		write_class(union_name, union_info)



	# # # for class_name in class_pattern.findall(data):
	# for class_name in ["TravelerDataFrame","TravelerDataFrame__msgId"]:
	# 	print(class_name)

	# 	class_info = extract_struct_fields(data, class_name)
	# 	write_class(class_name, class_info)
	# 	paths.append(convert_to_snake_case(class_name))

	# # # for union_name in class_pattern.findall(data):
	# for union_name in ["TravelerDataFrame__msgId_u"]:

	# # class_name = "TravelerDataFrame"
	# 	print(union_name)

	# 	class_info = extract_union_fields(data, union_name)
	# 	write_class(union_name, class_info)
	# 	paths.append(convert_to_snake_case(union_name))

	
	with open("j2735/j2735.dart", "w") as o:
		for path in paths:
			o.write(f"export \"{path}.dart\";\n")

	# import pprint
	# pprint.pprint(struct_info)

