require 'csv'
require_relative 'FloramoHelper'

familias = []
generos = []
especies = []
colores = []
formas_vida = []
provincias = []

family_id = 1
genus_id = 1
species_id = 1
color_id = 1
life_form_id = 1
provincia_id = 1

especie_provincia_id = 1
especie_foto_id = 1

def trim(str)
  str.chomp.tr('"', '').strip.downcase if str
end

file = File.new('sql/colors.java', 'r')
while (line = file.gets)
  parts = line.split(/", "/)
  color_id = FloramoHelper.set_simple_property2(trim(parts[1]).downcase, color_id, trim(parts[0]), colores)
end
file.close

file = File.new('sql/formasVida.java', 'r')
while (line = file.gets)
  parts = line.split(/", "/)
  life_form_id = FloramoHelper.set_simple_property2(trim(parts[1]), life_form_id, trim(parts[0]), formas_vida)
end
file.close

file = File.new('sql/familias.java', 'r')
while (line = file.gets)
  parts = line.split(/", "/)
  family_id = FloramoHelper.set_simple_property2(trim(parts[1]), family_id, trim(parts[0]), familias)
end
file.close

file = File.new('sql/generos.java', 'r')
while (line = file.gets)
  parts = line.split(/", "/)

  old_id = trim(parts[0])
  name = FloramoHelper.normalize(parts[1])
  familia_obj = familias.find { |f| f[:old_id].to_s == trim(parts[3]) }
  genus_obj = { id: genus_id, name: name, family: familia_obj, old_id: old_id }
  generos.push(genus_obj)
  genus_id += 1
end
file.close

file = File.new('sql/especies.java', 'r')
while (line = file.gets)
  parts = line.split(/", "/)

  old_id = trim(parts[0])
  name = trim(parts[1])
  genero_id = trim(parts[3])
  color1_id = trim(parts[4])
  color2_id = trim(parts[5])
  forma_vida1_id = trim(parts[6])
  forma_vida2_id = trim(parts[7])
  tropicos_id = trim(parts[8])
  full_description_es = trim(parts[9])
  full_description_en = trim(parts[10])
  author = trim(parts[11])

  description_es_parts = full_description_es.split('Distribución:')
  description_es = description_es_parts[0]
  distribution_es = description_es_parts[1]

  description_en_parts = full_description_en.split('Distribution:')
  description_en = description_en_parts[0]
  distribution_en = description_en_parts[1]

  genus_obj = generos.find { |o| o[:old_id].to_s == genero_id }
  color1_obj = colores.find { |o| o[:old_id].to_s == color1_id }
  color2_obj = colores.find { |o| o[:old_id].to_s == color2_id }
  life_form1_obj = formas_vida.find { |o| o[:old_id].to_s == forma_vida1_id }
  life_form2_obj = formas_vida.find { |o| o[:old_id].to_s == forma_vida2_id }

  photo_base = "#{genus_obj[:name][0..4]}_#{name[0..3]}"

  species_obj = {
    id: species_id,
    name: FloramoHelper.normalize(name),
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
    old_id: old_id,
    provincias: [],
    fotos: []
  }
  especies.push(species_obj)
  species_id += 1
end
file.close

arr_of_arrs = CSV.read('list.csv')
headers = true

arr_of_arrs.each do |parts|
  unless headers
    family = trim(parts[0])
    genus = trim(parts[1])
    species = trim(parts[2])
    author = trim(parts[3])
    color1 = trim(parts[4])
    color2 = trim(parts[5])
    life_form1 = trim(parts[6])
    life_form2 = trim(parts[7])
    tropicos_number = parts[10]
    full_description_es = parts[11]
    full_description_en = parts[12]
    provinces = parts[13]

    family_obj, family_id = FloramoHelper.set_simple_property(family, family_id, familias)
    genus_obj, genus_id = FloramoHelper.set_genero(family_obj, generos, genus, genus_id)
    color1_obj, color_id = FloramoHelper.set_simple_property(color1, color_id, colores)
    color2_obj, color_id = FloramoHelper.set_simple_property(color2, color_id, colores)
    life_form1_obj, life_form_id = FloramoHelper.set_simple_property(life_form1, life_form_id, formas_vida)
    life_form2_obj, life_form_id = FloramoHelper.set_simple_property(life_form2, life_form_id, formas_vida)

    provincias_obj, provincia_id = FloramoHelper.set_provincias(provinces, provincia_id, provincias)

    description_es_parts = full_description_es.split('Distribución:')
    description_es = description_es_parts[0]
    distribution_es = description_es_parts[1]

    description_en_parts = full_description_en.split('Distribution:')
    description_en = description_en_parts[0]
    distribution_en = description_en_parts[1]

    photo_base = "#{genus_obj[:name][0..4]}_#{species[0..3]}"

    species_obj = {
      id: species_id,
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
      provincias: provincias_obj,
      fotos: []
    }
    especies.push(species_obj)
    species_id += 1
  end
  headers = false
end

genero = generos.find { |g| g[:old_id] == '167' }
genero[:name] = 'Phlegmariurus'
genero = generos.find { |g| g[:old_id] == '307' }
genero[:name] = 'Schoenoplectus'

especie = especies.find { |e| e[:old_id] == '168' }
especie[:name] = 'crassus'
especie[:scientific] = 'Phlegmariurus crassus'
especie[:photo_base] = 'Phleg_cras'
especie[:tropicos] = '100364214'
especie = especies.find { |e| e[:old_id] == '308' }
especie[:name] = 'californicus'
especie[:scientific] = 'Schoenoplectus californicus'
especie[:photo_base] = 'Schoe_cali'
especie[:tropicos] = '9904887'

color = colores.find { |c| c[:id].to_s == '10' }
color[:name] = 'cone'
color[:old_id] = '128'

especie = especies.find { |e| e[:old_id] == '168' }
especie[:color1] = color
especie[:color2] = nil

especie = especies.find { |e| e[:old_id] == '180' }
especie[:color1] = color
especie[:color2] = nil

especie = especies.find { |e| e[:old_id] == '103' }
especie[:color1] = color
especie[:color2] = nil

especie = especies.find { |e| e[:old_id] == '111' }
especie[:color1] = color
especie[:color2] = nil

forma_vida_aquatic = formas_vida.find { |c| c[:old_id] == '5' }
especie = especies.find { |e| e[:old_id] == '308' }
especie[:forma_vida2] = forma_vida_aquatic

especie = especies.find { |e| e[:old_id] == '189' }
especie[:color2] = nil

color = colores.find { |c| c[:old_id] == '15' }
especie = especies.find { |e| e[:old_id] == '107' }
especie[:color2] = color
color = colores.find { |c| c[:old_id] == '36' }
especie = especies.find { |e| e[:old_id] == '344' }
especie[:color2] = color
color = colores.find { |c| c[:old_id] == '3' }
especie = especies.find { |e| e[:old_id] == '87' }
especie[:color2] = color

arr_of_arrs = CSV.read('listProvincias.csv')
arr_of_arrs.each do |parts|
  scientific_name = trim(parts[0])
  provinces = parts[1].split(',')
  especie = especies.find { |e| e[:scientific] == scientific_name }
  provinces.each do |prov|
    province = provincias.find { |p| p[:name].downcase == trim(prov).downcase }
    especie[:provincias] = [] if !especie.nil? && especie[:provincias].nil?
    especie[:provincias].push(province) unless especie.nil?
  end
end

file = File.new('fotos/todas', 'r')
while (line = file.gets)
  path = trim(line.downcase)
  especie = especies.find { |e| path.include?(e[:photo_base].downcase) }
  unless especie
    parts = path.split('.')
    parts = parts[0].split('_')
    especie = especies.find { |e| e[:name].downcase.include?(parts[1].downcase) && e[:genus][:name].downcase.include?(parts[0].downcase) }
    unless especie
      puts "#{line}   ->   *#{path}*"
      puts especie
      puts '*********************************************'
    end
  end
  if especie
    especie[:fotos].push(path)
  end
end
file.close

file = File.new('fotos/thumbs', 'r')
while (line = file.gets)
  path = trim(line.downcase)
  especie = especies.find { |e| path.include?(e[:photo_base].downcase) }
  unless especie
    parts = path.split('.')
    parts = parts[0].split('_')
    especie = especies.find { |e| e[:name].downcase.include?(parts[1].downcase) && e[:genus][:name].downcase.include?(parts[0].downcase) }
    unless especie
      puts "#{line}   ->   *#{path}*"
      puts especie
      puts '===================================='
    end
  end
  if especie
    especie[:thumb] = path
  end
end
file.close

sqls = {
  provinces: [],
  colors: [],
  life_forms: [],
  families: [],
  genus: [],
  species: [],
  species_provinces: [],
  species_photos: []
}

FloramoHelper.create_simpler_sqls(provincias, 'TABLE_PROVINCE', sqls[:provinces])
FloramoHelper.create_simpler_sqls(colores, 'TABLE_COLOR', sqls[:colors])
FloramoHelper.create_simpler_sqls(formas_vida, 'TABLE_LIFE_FORM', sqls[:life_forms])
FloramoHelper.create_simple_sqls(familias, 'TABLE_FAMILY', sqls[:families])
generos.each do |genero|
  id = genero[:id]
  name = genero[:name]
  norm_name = FloramoHelper.normalize(genero[:name])
  family_id = genero[:family][:id]
  columns = %w(KEY_ID KEY_NAME KEY_NORM_NAME KEY_FAMILY_ID)
  values = [id, name, norm_name, family_id]
  sql = FloramoHelper.build_insert_sql('TABLE_GENUS', columns, values)
  sqls[:genus].push(sql)
end
especies.each do |especie|
  id = especie[:id]
  name = especie[:name]
  norm_name = FloramoHelper.normalize(especie[:name])
  genero_id = especie[:genus][:id]
  author = especie[:author]
  tropicos = especie[:tropicos]
  color1 = especie[:color1].nil? ? 'null' : especie[:color1][:id]
  color2 = especie[:color2].nil? ? 'null' : especie[:color2][:id]
  life_form1 = especie[:life_form1].nil? ? 'null' : especie[:life_form1][:id]
  life_form2 = especie[:life_form2].nil? ? 'null' : especie[:life_form2][:id]
  description_es = especie[:description_es]
  distribution_es = especie[:distribution_es]
  description_en = especie[:description_en]
  distribution_en = especie[:distribution_en]
  thumb = especie[:thumb]

  # if name == 'peruvianus' || name == 'sessiliflora' || name == 'fissifolia'
  if name == 'fissifolia'
    puts especie
    # puts "#{especie[:genus][:name]} #{name}-#{especie[:thumb]}-#{especie[:fotos]}"
  end

  columns = %w(KEY_ID KEY_NAME KEY_NORM_NAME KEY_GENUS_ID KEY_TROPICOS_ID KEY_COLOR1_ID
               KEY_COLOR2_ID KEY_LIFE_FORM1_ID KEY_LIFE_FORM2_ID KEY_DESCRIPTION_ES
               KEY_DISTRIBUTION_ES KEY_DESCRIPTION_EN KEY_DISTRIBUTION_EN KEY_THUMBNAIL)

  values = [id, name, norm_name, genero_id, tropicos, color1,
            color2, life_form1, life_form2, description_es,
            distribution_es, description_en, distribution_en, thumb]
  sql = FloramoHelper.build_insert_sql('TABLE_SPECIES', columns, values)
  sqls[:species].push(sql)

  unless especie.nil?
    especie[:provincias].each do |provincia|
      unless provincia.nil?
        columns = %w(KEY_ID KEY_SPECIES_ID KEY_PROVINCE_ID)
        values = [especie_provincia_id, id, provincia[:id]]
        sql = FloramoHelper.build_insert_sql('TABLE_SPECIES_PROVINCES', columns, values)
        sqls[:species_provinces].push(sql)
        especie_provincia_id+=1
      end
    end if especie[:provincias]
    especie[:fotos].each do |foto|
      columns = %w(KEY_ID KEY_SPECIES_ID KEY_PHOTO_PATH)
      values = [especie_foto_id, id, foto]
      sql = FloramoHelper.build_insert_sql('TABLE_SPECIES_PHOTOS', columns, values)
      sqls[:species_photos].push(sql)
      especie_foto_id+=1
    end if especie[:fotos]
  end
end

filename = 'floramo_sqls.java'
File.open(filename, 'w') do |file|
  sqls.each do |k, sql|
    FloramoHelper.write_comment(file, "SQLs #{k.to_s}")
    file.write("public void insert#{k.to_s[0].upcase}#{k.to_s[1..k.size]}() {\n")
    sql.each { |s| file.write("\tdb.execSQL(\"#{s}\");\n") }
    file.write("}\n\n")
  end
end

