require_relative 'Utils'

module SqlHelper

  module_function

  def tables
    {
      commons_norm: %w(KEY_ID KEY_NAME KEY_NORM_NAME),
      commons: %w(KEY_ID KEY_NAME),
      color: {
        table: 'TABLE_COLOR',
        columns: %w(KEY_ID KEY_NOMBRE)
      },
      place: {
        table: 'TABLE_LUGAR',
        columns: %w(KEY_ID KEY_NOMBRE KEY_NOMBRE_NORM)
      },
      photo: {
        table: 'TABLE_FOTO',
        columns: %w(KEY_ID KEY_ESPECIE_ID KEY_PATH)
      },
      family: {
        table: 'TABLE_FAMILIA',
        columns: %w(KEY_ID KEY_NOMBRE KEY_NOMBRE_NORM)
      },
      genus: {
        table: 'TABLE_GENERO',
        columns: %w(KEY_ID KEY_NOMBRE KEY_NOMBRE_NORM KEY_FAMILIA_ID)
      },
      species: {
        table: 'TABLE_SPECIES',
        columns: %w(KEY_ID KEY_NOMBRE KEY_NOMBRE_NORM KEY_GENERO_ID KEY_ID_TROPICOS KEY_COLOR1_ID
                    KEY_COLOR2_ID KEY_FORMA_VIDA1_ID KEY_FORMA_VIDA2_ID KEY_DESCRIPCION_ES
                    KEY_DISTRIBUCION_ES KEY_DESCRIPCION_EN KEY_DISTRIBUCION_EN KEY_THUMBNAIL)
      },
      life_form: {
        table: 'TABLE_FORMA_VIDA',
        columns: %w(KEY_ID KEY_NOMBRE)
      },
      species_places: {
        table: 'TABLE_SPECIES_PLACES',
        columns: %w(KEY_ID KEY_SPECIES_ID KEY_PLACE_ID)
      }
    }
  end

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

    Utils.create_simple_sqls(places_array, tables[:place][:table], sqls[:provinces], tables[:commons_norm])
    Utils.create_simple_sqls(families_array, tables[:family][:table], sqls[:families], tables[:commons_norm])
    Utils.create_simpler_sqls(colors_array, tables[:color][:table], sqls[:colors], tables[:commons])
    Utils.create_simpler_sqls(life_forms_array, tables[:life_form][:table], sqls[:life_forms], tables[:commons])
    genus_array.each do |genero|
      id = genero[:id]
      name = genero[:name]
      norm_name = genero[:norm_name]
      family_id = genero[:family][:id]
      values = [id, name, norm_name, family_id]
      sql = Utils.build_insert_sql(tables[:genus][:table], tables[:genus][:columns], values)
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

      values = [id, name, norm_name, genero_id, tropicos, color1,
                color2, life_form1, life_form2, description_es,
                distribution_es, description_en, distribution_en, thumb]
      sql = Utils.build_insert_sql(tables[:species][:table], tables[:species][:columns], values)
      sqls[:species].push(sql)

      unless especie.nil?
        especie[:places].each do |provincia|
          unless provincia.nil?
            values = [especie_provincia_id, id, provincia[:id]]
            sql = Utils.build_insert_sql(tables[:species_places][:table], tables[:species_places][:columns], values)
            sqls[:species_provinces].push(sql)
            especie_provincia_id+=1
          end
        end if especie[:places]
        especie[:photos].each do |foto|
          values = [especie_foto_id, id, foto]
          sql = Utils.build_insert_sql(tables[:photo][:table], tables[:photo][:columns], values)
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