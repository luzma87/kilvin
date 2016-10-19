require_relative 'Utils'

module SqlHelper

  module_function

  def create_sqls(colors_array, families_array, genus_array, life_forms_array, places_array, species_array)
    especie_provincia_id = 1000
    especie_foto_id = 1000

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

    Utils.create_simple_sqls(places_array, 'TABLE_PROVINCE', sqls[:provinces])
    Utils.create_simpler_sqls(colors_array, 'TABLE_COLOR', sqls[:colors])
    Utils.create_simpler_sqls(life_forms_array, 'TABLE_LIFE_FORM', sqls[:life_forms])
    Utils.create_simple_sqls(families_array, 'TABLE_FAMILY', sqls[:families])
    genus_array.each do |genero|
      id = genero[:id]
      name = genero[:name]
      norm_name = genero[:norm_name]
      family_id = genero[:family][:id]
      columns = %w(KEY_ID KEY_NAME KEY_NORM_NAME KEY_FAMILY_ID)
      values = [id, name, norm_name, family_id]
      sql = Utils.build_insert_sql('TABLE_GENUS', columns, values)
      sqls[:genus].push(sql)
    end
    species_array.each do |especie|
      id = especie[:id]
      name = especie[:name]
      norm_name = especie[:norm_name]
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

      columns = %w(KEY_ID KEY_NAME KEY_NORM_NAME KEY_GENUS_ID KEY_TROPICOS_ID KEY_COLOR1_ID
               KEY_COLOR2_ID KEY_LIFE_FORM1_ID KEY_LIFE_FORM2_ID KEY_DESCRIPTION_ES
               KEY_DISTRIBUTION_ES KEY_DESCRIPTION_EN KEY_DISTRIBUTION_EN KEY_THUMBNAIL)

      values = [id, name, norm_name, genero_id, tropicos, color1,
                color2, life_form1, life_form2, description_es,
                distribution_es, description_en, distribution_en, thumb]
      sql = Utils.build_insert_sql('TABLE_SPECIES', columns, values)
      sqls[:species].push(sql)

      unless especie.nil?
        especie[:places].each do |provincia|
          unless provincia.nil?
            columns = %w(KEY_ID KEY_SPECIES_ID KEY_PROVINCE_ID)
            values = [especie_provincia_id, id, provincia[:id]]
            sql = Utils.build_insert_sql('TABLE_SPECIES_PROVINCES', columns, values)
            sqls[:species_provinces].push(sql)
            especie_provincia_id+=1
          end
        end if especie[:places]
        especie[:photos].each do |foto|
          columns = %w(KEY_ID KEY_SPECIES_ID KEY_LUGAR_ID KEY_COORDENADA_ID PATH)
          values = [especie_foto_id, id, 1, 366, foto]
          sql = Utils.build_insert_sql('TABLE_SPECIES_PHOTOS', columns, values)
          sqls[:species_photos].push(sql)
          especie_foto_id+=1
        end if especie[:photos]
      end
    end

    filename = 'floramo_sqls.java'
    File.open(filename, 'w') do |file|
      sqls.each do |k, sql|
        Utils.write_message("SQLs #{k.to_s}")
        file.write("public void insert#{k.to_s[0].upcase}#{k.to_s[1..k.size]}() {\n")
        sql.each { |s| file.write("\tdb.execSQL(\"#{s}\");\n") }
        file.write("}\n\n")
      end
    end
  end

end