require 'csv'

arr_of_arrs = CSV.read('list.csv')
headers = true

familias = []
generos = []
especies = []
colores = []
formas_vida = []
paramos = []
provincias = []

family_id = 1
genus_id = 1
species_id = 1
color_id = 1
life_form_id = 1
paramo_id = 1
provincia_id = 1

def set_simple_property(new_property, property_id, array)
  if new_property
    new_property = new_property.strip
    if array.collect { |this| this[:name] }.include?(new_property)
      property_obj = array.find { |color_find| color_find[:name] == new_property }
    else
      property_obj = { id: property_id, name: new_property }
      array.push(property_obj)
      property_id += 1
    end
  else
    property_obj = nil
  end
  return property_obj, property_id
end

def set_genero(family_obj, generos, genus, genus_id)
  if genus
    genus = genus.strip
    if generos.collect { |this| this[:name] }.include?(genus)
      genus_obj = generos.find { |genus_find| genus_find[:name] == genus }
    else
      genus_obj = { id: genus_id, name: genus, family: family_obj }
      generos.push(genus_obj)
      genus_id += 1
    end
  else
    genus_obj = nil
  end
  [genus_obj, genus_id]
end

def set_provincias(provinces, provincia_id, provincias)
  provincias_obj = []
  if provinces
    provincias_parts = provinces.split(',')
    provincias_parts.each do |prov|
      provincia_obj, provincia_id = set_simple_property(prov, provincia_id, provincias)
      provincias_obj.push(provincia_obj)
    end
  end
  [provincias_obj, provincia_id]
end

def colorize(text, color_code)
  "#{color_code}#{text}\e[0m"
end

def red(text)
  colorize(text, "\e[31m")
end

def green(text)
  colorize(text, "\e[32m")
end

def task_message(message)
  border = '=' * message.size
  puts green(border)
  puts green(message)
  puts green(border)
end

def normalize(str)
  str[:name].downcase.tr('áàäâåã', 'a').tr('éèëê', 'e').tr('íìîï', 'i').tr('óòõöô', 'o')
    .tr('úùüû', 'u').tr('ñ', 'n')
end

arr_of_arrs.each do |parts|
  unless headers
    family = parts[0]
    genus = parts[1]
    species = parts[2]
    author = parts[3]
    color1 = parts[4]
    color2 = parts[5]
    life_form1 = parts[6]
    life_form2 = parts[7]
    paramo = parts[8]
    photographer = parts[9]
    tropicos_number = parts[10]
    description_es = parts[11]
    description_en = parts[12]
    provinces = parts[13]

    family_obj, family_id = set_simple_property(family, family_id, familias)
    genus_obj, genus_id = set_genero(family_obj, generos, genus, genus_id)
    color1_obj, color_id = set_simple_property(color1, color_id, colores)
    color2_obj, color_id = set_simple_property(color2, color_id, colores)
    life_form1_obj, life_form_id = set_simple_property(life_form1, life_form_id, formas_vida)
    life_form2_obj, life_form_id = set_simple_property(life_form2, life_form_id, formas_vida)
    paramo_obj, paramo_id = set_simple_property(paramo, paramo_id, paramos)
    provincias_obj, provincia_id = set_provincias(provinces, provincia_id, provincias)

    species_obj = {
      id: species_id,
      name: species,
      genus: genus_obj,
      author: author,
      paramo: paramo_obj,
      photographer: photographer,
      tropicos: tropicos_number,
      color1: color1_obj,
      color2: color2_obj,
      life_form1: life_form1_obj,
      life_form2: life_form2_obj,
      description_es: description_es,
      description_en: description_en,
      provincias: provincias_obj
    }
    especies.push(species_obj)
    species_id += 1
  end
  headers = false
end

def build_insert_sql(table, column_list, values_list)
  sql = "INSERT INTO #{table} (#{column_list.join(', ')}) values("
  values_list.each.with_index do |value, i|
    sql += "\"#{value}\""
    sql += ', ' if i < values_list.size - 1
  end
  sql += ')'
end

task_message('------------------------ Familias SQLs ------------------------')
familias.each do |familia|
  id = familia[:id]
  name = familia[:name]
  norm_name = normalize(familia)
  sql = build_insert_sql('familias', %w(id nombre nombre_norm), [id, name, norm_name])
  puts "db.execSQL(\"#{sql}\");"
end

