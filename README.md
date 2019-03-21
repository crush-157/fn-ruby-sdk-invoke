# Invoking an Oracle Function using the OCI Ruby SDK

## Introduction

This example illustrates how to use the OCI Ruby SDK to invoke a function
deployed to Oracle Functions.  The OCI SDK includes support for a large number
of OCI services but this example focuses specifically on Functions support.
For an introduction to the OCI Ruby SDK please refer to the [official
documentation](https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/rubysdk.htm).

In this example we'll show how you can invoke a function using its name, the
name of application it belongs to, the OCI compartment that contains the
application, and the OCID of your tenancy.  To do this we'll use the two
Functions related API clients exposed by the OCI SDK:

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
0. Clone this repository in a separate directory 

   `git clone https://github.com/denismakogon/fn.rbthon-sdk-invoke.git`

0. Change to the correct directory where you cloned the example: 

   `cd fn.rbthon-sdk-invoke` 


## You can now invoke your function!

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
