module FloramoHelper

  module_function

  def set_simple_property(new_property, property_id, array)
    if new_property
      new_property = new_property.strip.downcase
      if array.collect { |this| this[:name] }.include?(new_property)
        property_obj = array.find { |property_find| property_find[:name] == new_property }
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

  def set_simple_property2(new_property, new_property_id, old_id, array)
    if new_property
      new_property = new_property.strip.downcase
      property_obj = { id: new_property_id, name: new_property, old_id: old_id }
      array.push(property_obj)
      new_property_id += 1
    end
    new_property_id
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

  def write_comment(file, message)
    write_message(message)
    # border = '*' * message.size
    # file.write("\n\n/* #{border} */\n")
    # file.write("/* #{message} */\n")
    # file.write("/* #{border} */\n")
  end

  def write_message(message)
    border = '=' * message.size
    puts green(border)
    puts green(message)
    puts green(border)
  end

  def normalize(str)
    str.downcase.tr('áàäâåã', 'a').tr('éèëê', 'e').tr('íìîï', 'i').tr('óòõöô', 'o')
      .tr('úùüû', 'u').tr('ñ', 'n')
  end

  def build_insert_sql(table, column_list, values_list)
    columns = ''
    column_list.each do |col|
      columns += "\" + #{col} + \", "
    end

    sql = "INSERT INTO \" + #{table} + \" (#{columns}) values("
    values_list.each.with_index do |value, i|
      sql += "\\\"#{value}\\\""
      sql += ', ' if i < values_list.size - 1
    end
    sql += ')'
  end

  def create_simple_sqls(items, table_name, arr)
    items.each do |iterator|
      id = iterator[:id]
      name = iterator[:name]
      norm_name = normalize(iterator[:name])
      columns = %w(KEY_ID KEY_NAME KEY_NORM_NAME)
      values = [id, name, norm_name]
      sql = build_insert_sql(table_name, columns, values)
      arr.push(sql)
    end
  end

  def create_simpler_sqls(items, table_name, arr)
    items.each do |iterator|
      id = iterator[:id]
      name = iterator[:name]
      columns = %w(KEY_ID KEY_NAME)
      values = [id, name]
      sql = build_insert_sql(table_name, columns, values)
      arr.push(sql)
    end
  end
end