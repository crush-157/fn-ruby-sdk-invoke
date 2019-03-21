# Invoking an Oracle Function using the OCI Ruby SDK

## Introduction

This example illustrates how to use the OCI Ruby SDK to invoke a function
deployed to Oracle Functions.  The OCI SDK includes support for a large number
of OCI services but this example focuses specifically on Functions support.
For an introduction to the OCI Ruby SDK please refer to the [official
documentation](https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/rubysdk.htm).

In this example we'll show how you can invoke a function using its name, the
name of application it belongs to, and the name of OCI compartment that contains the
application.

To do this we'll use the Functions related API clients exposed by the OCI SDK.

## Prerequisites

### OCI Config

You will need a valid OCI `config` file to be able to authenticate against OCI.

The OCI `config` file is usually found in the directory `~/.oci`.

If your config file is in a different location, you will need to set the environment variable `OCI_CONFIG_PATH` to point to the directory path for the `config` file.

The easiest way to set up your `config` correctly is to install the [OCI CLI](https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/cliinstall.htm) and then run
```bash
oci setup config
```

### Target Function

To be able to run this example you're going to need a target function hosted on the Oracle Cloud Functions service.

This example has been written using a Java "hello world" function.  The [Functions Getting Started guide](https://www.oracle.com/webfolder/technetwork/tutorials/infographics/oci_faas_gettingstarted_quickview/functions_quickview_top/functions_quickview/index.html) describes how to:
- set up Oracle Functions
- configure your context
- deploy and invoke your first function

If you have your own function then feel free to use that, but you must have successfully:
1. deployed it
2. Invoked it.

### Install preview OCI Ruby SDK

At the time of writing, the Functions API of the SDK is _in preview_ so you will need the _preview version_ of the `oci` gem **(not the one available from rubygems)**.

Speak to your friendly neighbourhood OCI PM to get hold of the preview version!

1. Unzip the file containing the gem
2. (optional) Create a "sandbox" before installing the preview gem.
   
   The steps to do this depend upon which version manager you use for Ruby.
   
   I'm using RVM, so I `create` a new `gemset`, and then `use` that to install and run the preview gem:
   ```bash
   rvm gemset create preview
   rvm gemset use preview
   rvm install path-to-gemfile/gemfile.gem
   ```
   Make sure that you're in the correct sandbox when running the examples.

### Get Example Code
1. Clone this repository in a separate directory 

   `git clone https://github.com/crush-157/fn-ruby-sdk-invoke.git`

0. Change to the correct directory where you cloned the example: 

   `cd fn-ruby-sdk-invoke` 

## Example

### Code Structure

The code is contained in three files:
- [`invoke_function.rb`](invoke_function.rb) - invokes a function with either a String as payload, or no payload.
- [`invoke_function_file.rb`](invoke_function_file.rb) - invokes a function with a file as payload.
- [`api_helper.rb`](api_helper.rb) - contains the code that calls the API

The code in `invoke_function.rb` and `invoke_function_file.rb` follows the same pattern:
1.  Check the correct number of arguments have been passed
2.  Call [`invoke_function`](api_helper.rb#L103) in `api_helper.rb`, passing in
- `compartment_name`
- `app_name`
- `function_name`
- `payload (if any)`

Most of the work takes place inside `api_helper` as follows:

1. [`compartment_ocid`](api_helper.rb#L39) - uses the `OCI::Identity::IdentityClient` of the SDK to look up the OCID of the named compartment.
2. [`app_ocid`](api_helper.rb#64) - uses the `OCI::Functions::FunctionsManagementClient` of the SDK to look up the OCID of the named application.
3. [`function`](api_helper.rb#86) - uses the `OCI::Functions::FunctionsManagementClient` of the SDK to get the named function.
4. Having navigated from the `Compartment` to the `Application` to the `Function` in turn, we then call [`fn_invocation_client`](api_helper.rb#93) to create an instance of `OCI::Functions::FunctionsInvokeClient`.
5. Finally the `OCI::Functions::FunctionsInvokeClient` is then used by [`invoke_function`](api_helper.rb#103) to invoke the function and return the result.

### Running the Examples

#### `invoke_function.rb`

In the directory containing the example code run the `invoke_function.rb` with no arguments:
```
[ewan@dalek fn-ruby-sdk-invoke]$ ruby invoke_function.rb
usage: ruby invoke_function.rb <compartment-name> <app-name> <function-name> [<request-payload>]
```

Then with `compartment-name`, `app-name` and `function-name` but no payload:
```bash
[ewan@dalek fn-ruby-sdk-invoke]$ ruby invoke_function.rb FaaS_Test helloworld-app helloworld-func
Hello, world!
```

Then with a payload:
```bash
[ewan@dalek fn-ruby-sdk-invoke]$ ruby invoke_function.rb FaaS_Test helloworld-app helloworld-func Ruby
Hello, Ruby!
```

If you mis-type the `compartment-name`, `app-name` or `function-name` you will see an error:
```bash
[ewan@dalek fn-ruby-sdk-invoke]$ ruby invoke_function.rb FaaS_Test helloworld-app exterminate doctor
An error occurred: Could not find function exterminate
```

If you want more information on the error, either `export DEBUG=1` or set `DEBUG=1` at the start of the command:

```bash
[ewan@dalek fn-ruby-sdk-invoke]$ DEBUG=1 ruby invoke_function.rb FaaS_Test helloworld-app exterminate doctor
/home/ewan/fn/oci-sdk/fn-ruby-sdk-invoke/api_helper.rb:89:in `block in function'
/home/ewan/fn/oci-sdk/fn-ruby-sdk-invoke/api_helper.rb:89:in `fetch'
/home/ewan/fn/oci-sdk/fn-ruby-sdk-invoke/api_helper.rb:89:in `function'
/home/ewan/fn/oci-sdk/fn-ruby-sdk-invoke/api_helper.rb:104:in `invoke_function'
invoke_function.rb:7:in `<main>'
An error occurred: Could not find function exterminate
```
#### `invoke_function_file.rb`

Now that you've seen you can invoke a function with an optional String payload, let's have a look at invoking a function that expects a file as payload.

We're going to use a [TensorFlow based function](https://github.com/abhirockzz/fn-hello-tensorflow) 
as an example to explore the possibility of invoking a function using binary content.
This function expects the image data (in binary form) as an input and returns what object that image
resembles along with the percentage accuracy.
 
# Lord Vader says delete the rest:

```bash
ruby invoke_function.rb <compartment-name> <app-name> <function-name> [<request payload>]
```

### Enable debug mode

Set environment variable:

```bash
export DEBUG=1
ruby invoke_function.rb <compartment-name> <app-name> <function-name> <request payload>
```
or

```bash
DEBUG=1.rbthon invoke_function.rb <compartment-name> <app-name> <function-name> <request payload>
```

### Example of invoking a function

1) Using "DEFAULT" oci config profile:

```bash
ruby invoke_function.rb workshop helloworld-app helloworld-func-go '{"name":"foobar"}'
{"message":"Hello foobar"}
```

2) Using a non-DEFAULT profile name in oci config:

a) Export `OCI_CONFIG_PROFILE` as an environment variable:

```bash
export OCI_CONFIG_PROFILE=faas_test
invoke_function.rb workshop helloworld-app helloworld-func-go '{"name":"foobar"}'
{"message":"Hello foobar"}
```

b) Set `OCI_CONFIG_PROFILE` on the command line:

```bash
OCI_CONFIG_PROFILE=faas_test invoke_function.rb workshop helloworld-app helloworld-func-go '{"name":"foobar"}'
{"message":"Hello foobar"}
```

3) Invoking a Function inside a nested compartment:

a) with payload:

```bash
ruby invoke_function.rb nested-ws nest-app go-fn {"name":"EMEA"}
```

b) without payload:

```bash
ruby invoke_function.rb nested-ws nest-app go-fn '{}'
```

## What if my function needs input in binary form?

You can use this [TensorFlow based function](https://github.com/abhirockzz/fn-hello-tensorflow) 
as an example to explore the possibility of invoking a function using binary content.
This function expects the image data (in binary form) as an input and returns what object that image
resembles along with the percentage accuracy.

If you were to deploy the TensorFlow function, the command to invoke it using Fn
CLI would be something like this:

```bash
cat test-som-1.jpeg | fn invoke fn-tensorflow-app classify
```

In this case, the `test-som-1.jpeg` image is being passed
as an input to the function. 

The programmatic (using.rbthon SDK) equivalent of
this would look something like [invoke_function_file.rb](invoke_function_file.py)

### Example of invoking a function with binary input

```bash
ruby invoke_function_file.rb <compartment-name> <app-name> <function-name> <image-file-path>
```

```bash
ruby invoke_function_file.rb workshop demo-app classify test-som-1.jpeg
This is a 'sombrero' Accuracy - 94%
```


:

 - FunctionsManagementClient - is used for functions lifecycle management operations including creating, updating, and querying applications and functions
 - FunctionsInvokeClient - is used specifically for invoking functions

Along with the two clients, the OCI SDK also provides a number of wrapper/handle
objects like `OCI::Identity::Models::Compartment`, `OC::Functions::Models::Application`, and `OCI::Functions::Models::Function`. In the example, we
navigate down the hierarchy from `OCI::Identity::Models::Compartment` to `OCI::Functions::Models::Function` and then once we
have the desired `OCI::Functions:Models.Function` we invoke it using the `OCI::Functions::FunctionsInvokeClient`.

**Important Note: A Function's OCID and invoke endpoint will remain the same unless you delete the function or it's parent application. In a real world scenario, once you get the `OCI::Functions::Models::Function`, you should cache the function's OCID and invoke endpoint either in-memory or to an external data store and use the cached values for subsequent invocations.**

For more information on code structure and API along with the data types please read code doc strings available for each method:

 - [`get_compartment`](invoke_function.rb#L14) method
 - [`get_app`](invoke_function.rb#L36) method
 - [`get_function`](invoke_function.rb#L62) method

