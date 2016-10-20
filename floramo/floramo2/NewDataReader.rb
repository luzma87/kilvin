require_relative 'Utils'

module NewDataReader

  module_function

  def create_base_element(element_name, element_id, array, add_norm_name)
    element = nil
    if element_name
      element_name = Utils.trim(element_name)
      if array.collect { |this| this[:name].downcase }.include?(element_name.downcase)
        element = array.find { |property_find| property_find[:name].downcase == element_name.downcase }
      else
        element = { id: element_id, name: element_name }
        if add_norm_name
          norm_name = Utils.normalize(element_name)
          element[:norm_name] = norm_name
        end
        array.push(element) unless element.nil?
        element_id += 1 unless element_id.nil?
      end
    end
    return element, element_id
  end

  def create_places(places_string, place_id, places_array)
    places_obj_array = []
    if places_string
      places = places_string.split(',')
      places.each do |place|
        provincia_obj, place_id = create_base_element(place, place_id, places_array, true)
        places_obj_array.push(provincia_obj)
      end
    end
    [places_obj_array, place_id]
  end

  def create_genus(family_obj, genus_array, genus_name, genus_id)
    genus_obj = nil
    if genus_name
      genus_name = genus_name.strip
      if genus_array.collect { |this| this[:name].downcase }.include?(genus_name.downcase)
        genus_obj = genus_array.find { |genus_find| genus_find[:name] == genus_name }
      else
        genus_obj = { id: genus_id, name: genus_name, family: family_obj }
        genus_array.push(genus_obj)
        genus_id += 1
      end
    end
    [genus_obj, genus_id]
  end

  def new_data(colors_array, life_forms_array, families_array, genus_array, species_array, places_array)
    family_id = 1000
    genus_id = 1000
    place_id = 1000
    species_id = 1000
    blah = 1

    arr_of_arrs = CSV.read('../list.csv')
    headers = true

    arr_of_arrs.each do |parts|
      unless headers
        family = Utils.trim(parts[0])
        genus = Utils.trim(parts[1])
        species = Utils.trim(parts[2])
        author = Utils.trim(parts[3])
        color1 = Utils.trim(parts[4])
        color2 = Utils.trim(parts[5])
        life_form1 = Utils.trim(parts[6])
        life_form2 = Utils.trim(parts[7])
        tropicos_number = parts[10]
        full_description_es = parts[11]
        full_description_en = parts[12]
        provinces = parts[13]

        family_obj, family_id = create_base_element(family, family_id, families_array, true)
        genus_obj, blah = create_genus(family_obj, genus_array, genus, genus_id)
        color1_obj, blah = create_base_element(color1, nil, colors_array, false)
        color2_obj, blah= create_base_element(color2, nil, colors_array, false)
        life_form1_obj, blah = create_base_element(life_form1, nil, life_forms_array, false)
        life_form2_obj, blah = create_base_element(life_form2, nil, life_forms_array, false)

        provincias_obj, place_id = create_places(provinces, place_id, places_array)

        description_es_parts = full_description_es.split('Distribución:')
        description_es = Utils.trim(description_es_parts[0])
        distribution_es = Utils.trim(description_es_parts[1])

        description_en_parts = full_description_en.split('Distribution:')
        description_en = Utils.trim(description_en_parts[0])
        distribution_en = Utils.trim(description_en_parts[1])

        photo_base = "#{genus_obj[:name][0..4]}_#{species[0..3]}"

        species_obj = {
          id: species_id.to_s,
          name: species,
          genus: genus_obj,
          scientific: "#{genus_obj[:name]} #{species}",
          author: author,
          tropicos: tropicos_number,
          color1: color1_obj,
          color2: color2_obj,
          life_form1: life_form1_obj,
          life_form2: life_form2_obj,
          description_es: description_es,
          distribution_es: distribution_es,
          description_en: description_en,
          distribution_en: distribution_en,
          photo_base: photo_base,
          places: provincias_obj,
          photos: []
        }
        species_array.push(species_obj)
        species_id += 1
      end
      headers = false
    end
  end

  def updates(species_array)
    especie1 = species_array.find { |e| e[:id] == '73' }
    especie2 = species_array.find { |e| e[:id] == '1108' }

    especie1[:author] = especie2[:author]
    especie1[:description_es] = especie2[:description_es]
    especie1[:distribution_es] = especie2[:distribution_es]
    especie1[:description_en] = especie2[:description_en]
    especie1[:distribution_en] = especie2[:distribution_en]
    especie1[:places] = especie2[:places]

    species_array.delete(especie2)
  end

  def set_photos(species_array)
    file = File.new('../fotos/todas', 'r')
    while (line = file.gets)
      path = Utils.trim(line.downcase)
      especie = species_array.find { |e| path.include?(e[:photo_base].downcase) }
      unless especie
        parts = path.split('.')
        parts = parts[0].split('_')
        especie = species_array.find { |e| e[:name].downcase.include?(parts[1].downcase) && e[:genus][:name].downcase.include?(parts[0].downcase) }
      end
      if especie
        especie[:photos].push(path)
      end
    end
    file.close

    set_thumbs(species_array)

    especie = species_array.find { |e| e[:id] == '180' }
    especie[:photos].push('isoet_novo.jpg')
    especie[:thumb] = 'isoet_novo.jpg'
  end

  def set_thumbs(species_array)
    file = File.new('../fotos/thumbs', 'r')
    while (line = file.gets)
      path = Utils.trim(line.downcase)
      especie = species_array.find { |e| path.include?(e[:photo_base].downcase) }
      unless especie
        parts = path.split('.')
        parts = parts[0].split('_')
        especie = species_array.find { |e| e[:name].downcase.include?(parts[1].downcase) && e[:genus][:name].downcase.include?(parts[0].downcase) }
      end
      if especie
        especie[:thumb] = path
      end
    end
    file.close
  end

  def set_places(places_array, species_array)
    arr_of_arrs = CSV.read('../listProvincias.csv')
    arr_of_arrs.each do |parts|
      scientific_name = Utils.trim(parts[0])
      provinces = parts[1].split(',')
      especie = species_array.find { |e| e[:scientific] == scientific_name }
      provinces.each do |prov|
        province = places_array.find { |p| p[:name].downcase == Utils.trim(prov).downcase }
        especie[:places] = [] if !especie.nil? && especie[:provincias].nil?
        especie[:places].push(province) unless especie.nil?
      end
    end
  end

end