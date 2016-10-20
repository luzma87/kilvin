module Utils

  module_function

  def trim(str)
    str.chomp.tr('"', '').strip if str
  end

  def normalize(str)
    str.downcase.tr('áàäâåã', 'a').tr('éèëê', 'e').tr('íìîï', 'i').tr('óòõöô', 'o')
      .tr('úùüû', 'u').tr('ñ', 'n').tr('-', '')
  end

  def green(text)
    "\e[32m#{text}\e[0m"
  end

  def write_message(message)
    border = '=' * message.size
    puts green(border)
    puts green(message)
    puts green(border)
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

  def create_simpler_sqls(items, table_name, sql_array, columns_names)
    items.each do |iterator|
      id = iterator[:id]
      name = iterator[:name]
      values = [id, name]
      sql = build_insert_sql(table_name, columns_names, values)
      sql_array.push(sql)
    end
  end

  def create_simple_sqls(items, table_name, sql_array, columns_names)
    items.each do |iterator|
      id = iterator[:id]
      name = iterator[:name]
      norm_name = normalize(iterator[:name])
      values = [id, name, norm_name]
      sql = build_insert_sql(table_name, columns_names, values)
      sql_array.push(sql)
    end
  end

end