require_relative 'lib/interface'
require_relative 'lib/data_manager'

data_manager = DataManager.new
interface = Interface.new(data_manager)

interface.run