require 'csv'

arr_of_arrs = CSV.read('floramo.csv')
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

def algo(array, new_element, last_id)
  if array.collect { |this| this[:name] }.include?(new_element)
    obj = array.find { |find| find[:name] == new_element }
  else
    obj = { id: last_id, name: new_element }
    array.push(obj)
    last_id += 1
  end
  [obj, last_id]
end

arr_of_arrs[0..arr_of_arrs.length].each do |x|
  unless headers
    parts = x[0].split('|')
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
    provincias = parts[13]

    if familias.collect { |this| this[:name] }.include?(family)
      family_obj = familias.find { |family_find| family_find[:name] == family }
    else
      family_obj = { id: family_id, name: family }
      familias.push(family_obj)
      family_id += 1
    end

    if generos.collect { |this| this[:name] }.include?(genus)
      genus_obj = generos.find { |genus_find| genus_find[:name] == genus }
    else
      genus_obj = { id: genus_id, name: genus, family: family_obj }
      generos.push(genus_obj)
      genus_id += 1
    end

    if color1
      if colores.collect { |this| this[:name] }.include?(color1)
        color1_obj = colores.find { |color_find| color_find[:name] == color1 }
      else
        color1_obj = { id: color_id, name: color1 }
        colores.push(color1_obj)
        color_id += 1
      end
    else
      color1_obj = {}
    end

    if color2
      if colores.collect { |this| this[:name] }.include?(color2)
        color2_obj = colores.find { |color_find| color_find[:name] == color2 }
      else
        color2_obj = { id: color_id, name: color2 }
        colores.push(color2_obj)
        color_id += 1
      end
    else
      color2_obj = {}
    end

    species_obj = {
      id: species_id,
      name: species,
      genus: genus_obj,
      author: author,
      color1: color1_obj,
      color2: color2_obj
    }
    especies.push(species_obj)
    species_id += 1

  end
  headers = false
end
p especies[0]