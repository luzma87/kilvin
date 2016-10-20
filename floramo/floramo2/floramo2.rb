require 'csv'
require_relative 'OldDataReader'
require_relative 'NewDataReader'
require_relative 'SqlHelper'

colors_array = []
life_forms_array = []
families_array = []
genus_array = []
species_array = []
places_array = []

OldDataReader.set_colors_array(colors_array)
OldDataReader.set_life_forms_array(life_forms_array)
OldDataReader.set_families_array(families_array)
OldDataReader.set_genus_array(families_array, genus_array)
OldDataReader.set_species_array(colors_array, genus_array, life_forms_array, species_array)

OldDataReader.updates(colors_array, genus_array, life_forms_array, species_array)

NewDataReader.new_data(colors_array, life_forms_array, families_array, genus_array, species_array, places_array)
NewDataReader.set_places(places_array, species_array)
NewDataReader.set_photos(species_array)
NewDataReader.updates(species_array)

fern = colors_array.find { |e| e[:name] == 'Fern/Other' }
cone = colors_array.find { |e| e[:id] == '128' }
fern[:id] = cone[:id]
fern[:name] = cone[:name]

SqlHelper.create_sqls(colors_array, families_array, genus_array, life_forms_array, places_array, species_array)