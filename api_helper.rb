require 'oci'

# Get the custom profile name from $OCI_CONFIG_PROFILE
# Otherwise use the profile name 'DEFAULT'
def profile_name
  ENV.fetch('OCI_CONFIG_PROFILE', OCI::ConfigFileLoader::DEFAULT_PROFILE)
end

# Get the custom path to the config file from $OCI_CONFIG_PROFILE
# Otherwise use the default path $HOME/.oci/config
def config_file
  ENV.fetch('OCI_CONFIG_PATH', OCI::ConfigFileLoader::DEFAULT_CONFIG_FILE)
end

# Returns the config to be used by the API clients
def config
  @config ||= OCI::ConfigFileLoader.load_config(
    config_file_location: config_file,
    profile_name: profile_name
  )
end

# Returns Identity API Client that is used to search for compartments
def id_client
  @id_client ||= OCI::Identity::IdentityClient.new(config: config)
end

# Returns the list of compartments in the tenancy
def compartments
  id_client
    .list_compartments(
      OCI.config.tenancy,
      limit: 50,
      compartment_id_in_subtree: true
    ).collect(&:data).flatten
end

# Returns the OCID of the named compartment
def compartment_ocid(compartment_name:)
  compartments
    .select { |c| c.name == compartment_name }
    .fetch(0) { raise "Could not find compartment #{compartment_name}" }
    .id
end

# Returns Functions Management API Client that is used to search for
# 1. Applications
# 2. Functions
def fn_management_client
  @fn_management_client ||=
    OCI::Functions::FunctionsManagementClient.new(config: config)
end

# Returns the list of applications in the named compartment
def apps(compartment_name:)
  fn_management_client
    .list_applications(
      compartment_ocid(compartment_name: compartment_name),
      limit: 50
    ).collect(&:data).flatten
end

# Returns the OCID of the named application in the named compartment
def app_ocid(app_name:, compartment_name:)
  apps(compartment_name: compartment_name)
    .select { |a| a.display_name == app_name }
    .fetch(0) { raise "Could not find application #{app_name}" }
    .id
end

# Returns the list of functions in the named application
# in the named compartment
def functions(app_name:, compartment_name:)
  fn_management_client
    .list_functions(
      app_ocid(
        app_name: app_name,
        compartment_name: compartment_name
      ),
      limit: 50
    ).collect(&:data).flatten
end

# Returns the OCID of the named function in the named application
# in the named compartment
def function(function_name:, app_name:, compartment_name:)
  functions(app_name: app_name, compartment_name: compartment_name)
    .select { |f| f.display_name == function_name }
    .fetch(0) { raise "Could not find function #{function_name}" }
end

# Returns the Functions Invocation API client that is used to invoke functions
def fn_invocation_client(target_function:)
  OCI::Functions::FunctionsInvokeClient.new(
    config: config,
    endpoint: target_function.invoke_endpoint
  )
end

# Invokes the named function, in the named application in the named compartment
# with the payload (if any).
# Returns an instance of OCI::Response
def invoke_function(compartment_name:, app_name:, function_name:, payload: '')
  fn = function(
    function_name: function_name,
    app_name: app_name,
    compartment_name: compartment_name
  )
  fn_invocation_client(target_function: fn).invoke_function(fn.id, payload)
end
