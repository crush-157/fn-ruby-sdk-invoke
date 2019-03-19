def profile_name
  ENV.fetch("OCI_CONFIG_PROFILE", OCI::ConfigFileLoader::DEFAULT_PROFILE)
end

def config_file
  ENV.fetch("OCI_CONFIG_PATH", OCI::ConfigFileLoader::DEFAULT_CONFIG_FILE)
end

def id_client
  @id_client ||= OCI::Identity::IdentityClient.new(config: config)
end

def config
  @config ||= OCI::ConfigFileLoader.load_config(config_file_location: config_file, profile_name: profile_name)
end

def compartments
  id_client.list_compartments(OCI.config.tenancy, limit: 50, compartment_id_in_subtree: true).collect {|r| r.data }.flatten
end

def compartment_ocid(compartment_name:)
  compartments.select {|c| c.name == compartment_name }.fetch(0).id
end

def fn_management_client
  @fn_management_client ||= OCI::Functions::FunctionsManagementClient.new(config: config)
end

def apps(compartment_name:)
  fn_management_client.list_applications(compartment_ocid(compartment_name: compartment_name), limit: 50).collect {|r| r.data }.flatten
end

def app_ocid(app_name:, compartment_name:)
  apps(compartment_name: compartment_name).select { |a| a.display_name == app_name }.fetch(0).id
end

def functions(app_name:, compartment_name:)
  fn_management_client.list_functions(app_ocid(app_name: app_name, compartment_name: compartment_name), limit: 50).collect { |r| r.data }.flatten
end

def function(function_name:, app_name:, compartment_name:)
  functions(app_name: app_name, compartment_name: compartment_name).select { |f| f.display_name == function_name }.fetch(0)
end

def fn_invocation_client(target_function:)
  OCI::Functions::FunctionsInvokeClient.new(config: config, endpoint: target_function.invoke_endpoint)
end

def invoke_function(function_name:, app_name:, compartment_name:, payload: '')
  fn = function(function_name: function_name, app_name: app_name, compartment_name: compartment_name)
  fn_invocation_client(target_function: fn).invoke_function(fn.id, payload)
end
