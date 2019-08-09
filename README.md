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

The default profile in the `config` file is `DEFAULT`.  If you have a different profile you want to use, you will need to set the environment variable `OCI_CONFIG_PROFILE` to the profile name.

_Note: the Ruby SDK requires that you always have a `DEFAULT` profile present in your `config`, even if you use a custom profile._

### Target Function

To be able to run this example you're going to need a target function hosted on the Oracle Cloud Functions service.

This example has been written using a Java "hello world" function, as described [here](https://github.com/abhirockzz/oracle-functions-hello-worlds). 

If you have your own function, or you prefer to use an example written in [another language](https://github.com/abhirockzz/oracle-functions-hello-worlds), then feel free to use that, but you must have successfully:
1. Set up Oracle Functions
2. Created your context
3. Created your function
4. Deployed your function
5. Invoked it (successfully) using the Fn CLI

For example, I have deployed a function `helloworld-func` to the application `helloworld-app`, and can successfully invoke it with the Fn CLI:

```bash
fn invoke helloworld-app helloworld-func
Hello, world!
```

### Install OCI Ruby SDK

To use the OCI SDK for Ruby, you must install the `oci` gem.

   `gem install oci`

The Functions API of the SDK is included in the `oci` gem from version 2.5.11.

If you have an earlier version of the `oci` gem installed, please update it.

   `gem update oci`

### Get Example Code
1. Clone this repository in a separate directory

   `git clone https://github.com/crush-157/fn-ruby-sdk-invoke.git`

2. Change to the correct directory where you cloned the example:

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

Note that the `compartment` can be anywhere in the compartment "tree" of your tenancy (e.g. it could be a sub compartment of a sub compartment several levels below the root compartment).

Most of the work takes place inside `api_helper` as follows:

1. [`compartment_ocid`](api_helper.rb#L39) - uses the `OCI::Identity::IdentityClient` of the SDK to look up the OCID of the named compartment.
2. [`app_ocid`](api_helper.rb#L64) - uses the `OCI::Functions::FunctionsManagementClient` of the SDK to look up the OCID of the named application.
3. [`function`](api_helper.rb#L86) - uses the `OCI::Functions::FunctionsManagementClient` of the SDK to get the named function.
4. Having navigated from the `Compartment` to the `Application` to the `Function` in turn, we then call [`fn_invocation_client`](api_helper.rb#L93) to create an instance of `OCI::Functions::FunctionsInvokeClient`.
5. Finally the `OCI::Functions::FunctionsInvokeClient` is then used by [`invoke_function`](api_helper.rb#L103) to invoke the function and return the result.

_Note that both the `function OCID` and function endpoint will not change unless you delete the function, or the application that contains it._

_So in a real world application, once we know the `function OCID`, we can store this and use it in the future to retrieve the function and it's invoke endpoint without having to reprise the sequence of calls described above._

### Running the Examples

#### `invoke_function.rb`

In the directory containing the example code run the `invoke_function.rb` with no arguments:
```
ruby invoke_function.rb
usage: ruby invoke_function.rb <compartment-name> <app-name> <function-name> [<request-payload>]
```

Then with `compartment-name`, `app-name` and `function-name` but no payload:
```bash
ruby invoke_function.rb FaaS_Test helloworld-app helloworld-func
Hello, world!
```

Then with a payload:
```bash
ruby invoke_function.rb FaaS_Test helloworld-app helloworld-func Ruby
Hello, Ruby!
```

If you mis-type the `compartment-name`, `app-name` or `function-name` you will see an error:
```bash
ruby invoke_function.rb FaaS_Test helloworld-app exterminate doctor
An error occurred: Could not find function exterminate
```

If you want more information on the error, either `export DEBUG=1` or set `DEBUG=1` at the start of the command:

```bash
DEBUG=1 ruby invoke_function.rb FaaS_Test helloworld-app exterminate doctor
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

Once you've deployed the `classify` function, the command to invoke it using Fn
CLI would be something like this (I've just deployed it to the same helloworld-app as the helloworld-func):

```bash
cat pepperoni-pizza-800x800.png | fn invoke helloworld-app classify
This is a 'pizza' Accuracy - 95%
```

In this case, the `pepperoni-pizza-800x800.png` image is being passed as an input to the function.

To do this via the SDK, we can run `invoke_function_file.rb`, the key difference being that the 4th argument is now a path to the payload file:

```bash
ruby invoke_function_file.rb
usage: ruby invoke_function.rb <compartment-name> <app-name> <function-name> <request-payload-path>
```

The file contents are read and sent to the function as the [`payload`](invoke_function_file.rb#L11).

To send an image as the payload:
```bash
ruby invoke_function_file.rb FaaS_Test helloworld-app classify pepperoni-pizza-800x800.png
This is a 'pizza' Accuracy - 95%
```
