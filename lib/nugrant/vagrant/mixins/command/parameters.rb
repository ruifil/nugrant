##
# This mixins module contains code that is the same in all
# version of the plugin system in Vagrant.
#
# Use it by including it in your class
#  include 'nugrant/vagrant/mixins/command/parameters'
#
# The module set different instance variables.
#

def create_parser()
  return OptionParser.new do |parser|
    parser.banner = "Usage: vagrant user parameters [<options>]"
    parser.separator ""

    parser.separator "Available options:"
    parser.separator ""

    parser.on("-h", "--help", "Print this help") do
      @show_help = true
    end

    parser.on("-d", "--defaults", "Show only defaults parameters") do
      @show_defaults = true
    end

    parser.on("-s", "--system", "Show only system parameters") do
      @show_system = true
    end

    parser.on("-u", "--user", "Show only user parameters") do
       @show_user = true
     end

     parser.on("-p", "--project", "Show only project parameters") do
       @show_project = true
     end

     parser.separator ""
     parser.separator "When no options is provided, the command prints the names and values \n" +
                      "of all parameters that would be available for usage in the Vagrantfile.\n" +
                      "The hierarchy of the parameters is respected, so the final values are\n" +
                      "displayed."
  end
end

def execute
  parser = create_parser()
  arguments = parse_options(parser)

  return help(parser) if @show_help

  @logger.debug("'Parameters' each target VM...")
  with_target_vms(arguments) do |vm|
    config = vm.config.user
    parameters = config ? config.parameters : Nugrant::Parameters.new()

    @env.ui.info("# Vm '#{vm.name}'", :prefix => false)

    defaults(parameters) if @show_defaults
    system(parameters) if @show_system
    user(parameters) if @show_user
    project(parameters) if @show_project

    all(parameters) if !@show_defaults && !@show_system && !@show_user && !@show_project
  end

  return 0
end

def help(parser)
  @env.ui.info(parser.help, :prefix => false)
end

def defaults(parameters)
  print_results("Defaults", parameters.defaults)
end

def system(parameters)
  print_results("System", parameters.system)
end

def user(parameters)
  print_results("User", parameters.user)
end

def project(parameters)
  print_results("Project", parameters.project)
end

def all(parameters)
  print_results("All", parameters.all)
end

def print_results(kind, parameters)
  if !parameters || parameters.empty?()
    print_header(kind)
    @env.ui.info(" Empty", :prefix => false)
    @env.ui.info("", :prefix => false)
    return
  end

  print_parameters(kind, {
    'config' => {
      'user' => parameters
    }
  })
end

def print_parameters(kind, data)
  string = Nugrant::Helper::Yaml.format(data.to_yaml, :indent => 1)

  print_header(kind)
  @env.ui.info(string, :prefix => false)
  @env.ui.info("", :prefix => false)
end

def print_header(kind, length = 50)
  @env.ui.info(" #{kind.capitalize} Parameters", :prefix => false)
  @env.ui.info(" " + "-" * length, :prefix => false)
end
