require_relative 'Utils'

module OldDataReader

  module_function

  def create_base_element(line, add_norm_name)
    element = nil
    parts = line.split(/", "/)
    element_id = Utils.trim(parts[0])
    element_name = Utils.trim(parts[1])
    if element_name
      element_name = element_name.strip
      element = { id: element_id, name: element_name }
      if add_norm_name
        norm_name = Utils.normalize(element_name)
        element[:norm_name] = norm_name
      end
    end
    element
  end

  def add_element_to_array(array, element)
    array.push(element) unless element.nil?
  end

  def set_colors_array(colors_array)
    file = File.new('../sql/colors.java', 'r')
    while (line = file.gets)
      add_element_to_array(colors_array, create_base_element(line, false))
    end
    file.close
  end

  def set_life_forms_array(life_forms_array)
    file = File.new('../sql/formasVida.java', 'r')
    while (line = file.gets)
      add_element_to_array(life_forms_array, create_base_element(line, false))
    end
    file.close
  end

  def set_families_array(families_array)
    file = File.new('../sql/familias.java', 'r')
    while (line = file.gets)
      add_element_to_array(families_array, create_base_element(line, true))
    end
    file.close
  end

  def set_genus_array(families_array, genus_array)
    file = File.new('../sql/generos.java', 'r')
    while (line = file.gets)
      parts = line.split(/", "/)

      family_id = Utils.trim(parts[3])
      family_obj = families_array.find { |f| f[:id].to_s == family_id }

      element = create_base_element(line, true)
      unless element.nil?
        element[:family] = family_obj
        genus_array.push(element)
      end
    end
    file.close
  end

  def set_species_array(colors_array, genus_array, life_forms_array, species_array)
    file = File.new('../sql/especies.java', 'r')
    while (line = file.gets)
      parts = line.split(/", "/)

      id = Utils.trim(parts[0])
      name = Utils.trim(parts[1])
      genero_id = Utils.trim(parts[3])
      color1_id = Utils.trim(parts[4])
      color2_id = Utils.trim(parts[5])
      life_form1_id = Utils.trim(parts[6])
      life_form2_id = Utils.trim(parts[7])
      tropicos_id = Utils.trim(parts[8])
      full_description_es = Utils.trim(parts[9])
      full_description_en = Utils.trim(parts[10])
      author = Utils.trim(parts[11])

      description_es_parts = full_description_es.split('Distribución:')
      description_es = Utils.trim(description_es_parts[0])
      distribution_es = Utils.trim(description_es_parts[1])

      description_en_parts = full_description_en.split('Distribution:')
      description_en = Utils.trim(description_en_parts[0])
      distribution_en = Utils.trim(description_en_parts[1])

      genus_obj = genus_array.find { |o| o[:id].to_s == genero_id }
      color1_obj = colors_array.find { |o| o[:id].to_s == color1_id }
      color2_obj = colors_array.find { |o| o[:id].to_s == color2_id }

      life_form1_obj = life_forms_array.find { |o| o[:id].to_s == life_form1_id }
      life_form2_obj = life_forms_array.find { |o| o[:id].to_s == life_form2_id }

      photo_base = "#{genus_obj[:name][0..4]}_#{name[0..3]}"

      species_obj = {
        id: id,
        name: name,
        norm_name: Utils.normalize(name),
        genus: genus_obj,
        scientific: "#{genus_obj[:name]} #{name}",
        author: author,
        tropicos: tropicos_id,
        color1: color1_obj,
        color2: color2_obj,
        life_form1: life_form1_obj,
        life_form2: life_form2_obj,
        description_es: description_es,
        distribution_es: distribution_es,
        description_en: description_en,
        distribution_en: distribution_en,
        photo_base: photo_base,
        places: [],
        photos: []
      }
      species_array.push(species_obj)
    end
    file.close
  end

  def updates(colors_array, genus_array, life_forms_array, species_array)
    genero = genus_array.find { |g| g[:id] == '167' }
    genero[:name] = 'Phlegmariurus'
    genero = genus_array.find { |g| g[:id] == '307' }
    genero[:name] = 'Schoenoplectus'

    especie = species_array.find { |e| e[:id] == '168' }
    especie[:name] = 'crassus'
    especie[:scientific] = 'Phlegmariurus crassus'
    especie[:photo_base] = 'Phleg_cras'
    especie[:tropicos] = '100364214'
    especie = species_array.find { |e| e[:id] == '308' }
    especie[:name] = 'californicus'
    especie[:scientific] = 'Schoenoplectus californicus'
    especie[:photo_base] = 'Schoe_cali'
    especie[:tropicos] = '9904887'

    color_cone = colors_array.find { |c| c[:id].to_s == '128' }

    especie = species_array.find { |e| e[:id] == '168' }
    especie[:color1] = color_cone
    especie[:color2] = nil

    especie = species_array.find { |e| e[:id] == '180' }
    especie[:color1] = color_cone
    especie[:color2] = nil

    especie = species_array.find { |e| e[:id] == '103' }
    especie[:color1] = color_cone
    especie[:color2] = nil

    especie = species_array.find { |e| e[:id] == '111' }
    especie[:color1] = color_cone
    especie[:color2] = nil

    forma_vida_aquatic = life_forms_array.find { |c| c[:id] == '177' }
    especie = species_array.find { |e| e[:id] == '308' }
    especie[:forma_vida2] = forma_vida_aquatic

    especie = species_array.find { |e| e[:id] == '189' }
    especie[:color2] = nil

    new_color = colors_array.find { |c| c[:id] == '15' }
    especie = species_array.find { |e| e[:id] == '107' }
    especie[:color2] = new_color
    new_color = colors_array.find { |c| c[:id] == '36' }
    especie = species_array.find { |e| e[:id] == '344' }
    especie[:color2] = new_color
    new_color = colors_array.find { |c| c[:id] == '3' }
    especie = species_array.find { |e| e[:id] == '87' }
    especie[:color2] = new_color
  end

end
