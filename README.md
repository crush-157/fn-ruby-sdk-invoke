# Invoking an Oracle Function using the OCI Python SDK

## Introduction

This example illustrates how to use the OCI Python SDK to invoke a function
deployed to Oracle Functions.  The OCI SDK includes support for a large number
of OCI services but this example focuses specifically on Functions support.
For an introduction to the OCI SDK please refer to the [official
documentation](https://oracle-cloud-infrastructure-python-sdk.readthedocs.io/en/latest/).

In this example we'll show how you can invoke a function using its name, the
name of application it belongs to, the OCI compartment that contains the
application, and the OCID of your tenancy.  To do this we'll use the two
Functions related API clients exposed by the OCI SDK:

 - FunctionsManagementClient - is used for functions lifecycle management operations including creating, updating, and querying applications and functions
 - FunctionsInvokeClient - is used specifically for invoking functions

Along with the two clients, the OCI SDK also provides a number of wrapper/handle
objects like `oci.identity.models.Compartment`, `oci.functions.models.Application`, and `oci.functions.models.Function`. In the example, we
navigate down the hierarchy from `oci.identity.models.Compartment` to `oci.functions.models.Function` and then once we
have the desired `oci.functions.models.Function` we invoke is using the `oci.functions.FunctionsInvokeClient`.

**Important Note: A Function's OCID and invoke endpoint will remain the same unless you delete the function or it's parent application. Once you get the `oci.functions.models.Function`, you should cache the function's OCID and invoke endpoint either in-memory or to an external data store and use the cached values for subsequent invocations.**

For more information on code structure and API along with the data types please read code doc strings available for each method:

 - [`get_compartment`](invoke_function.py#L14) method
 - [`get_app`](invoke_function.py#L36) method
 - [`get_function`](invoke_function.py#L62) method


### Prerequisites

This example invokes a function so we have to install the Fn CLI and create a target function:

1. Install/update the Fn CLI

   `curl -LSs https://raw.githubusercontent.com/fnproject/cli/master/install |
   sh`

2. Create a function to invoke

   Create a function using [Golang Hello World Function](https://github.com/fnproject/fn/blob/master/README.md#your-first-function)

### Install preview OCI Python SDK

1. Download and unzip the preview SDK

   `unzip oci-python-sdk-2.2.1+preview.1.712.zip`

2. Change into the correct directory

   `cd oci-python-sdk-2.2.1+preview.1.712`

3. Virtualenv

   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install oci-2.2.1+preview.1.712-py2.py3-none-any.whl
   ```

4. Clone this repository in a separate directory 

   `git clone https://github.com/denismakogon/fn-python-sdk-invoke.git`

5. Change to the correct directory where you cloned the example: 

   `cd fn-python-sdk-invoke` 



### Authentication

This example assumes the OCI config file is available on the machine where this client code will run. You can override the config defaults using the following environment variables:

 - `OCI_CONFIG_PATH` for the OCI config file (default value: `~/.oci/config`)
 - `OCI_CONFIG_PROFILE` stands from the OCI config profile (default value: `DEFAULT`)


## You can now invoke your function!

```bash
python invoke_function.py <compartment-name> <app-name> <function-name> <request payload>
```

### Enable debug mode

Set environment variable:

```bash
export DEBUG=1
python invoke_function.py <compartment-name> <app-name> <function-name> <request payload>
```
or

```bash
DEBUG=1 python invoke_function.py <compartment-name> <app-name> <function-name> <request payload>
```

### Example of invoking a function

1) Using "DEFAULT" oci config profile:

```bash
python invoke_function.py workshop helloworld-app helloworld-func-go '{"name":"foobar"}'
{"message":"Hello foobar"}
```

2) Using a non-DEFAULT profile name in oci config:

a) with payload:

```bash
OCI_CONFIG_PROFILE=workshop-devrel-profile python invoke_function.py workshop helloworld-app helloworld-func-go '{"name":"foobar"}'
```

b) without payload:

```bash
OCI_CONFIG_PROFILE=workshop-devrel-profile python invoke_function.py workshop helloworld-app helloworld-func-go '{}'
```

3) Invoking a Function inside a nested compartment:

a) with payload:

```bash
python invoke_function.py nested-ws nest-app go-fn {"name":"EMEA"}
```

b) without payload:

```bash
python invoke_function.py nested-ws nest-app go-fn '{}'
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

The programmatic (using python SDK) equivalent of
this would look something like [invoke_function_tf.py](invoke_function_tf.py)

### Example of invoking a function with binary input

```bash
python invoke_function_tf.py <compartment-name> <app-name> <function-name> <image-file-path>
```

```bash
python invoke_function_tf.py workshop demo-app classify test-som-1.jpeg
This is a 'sombrero' Accuracy - 94%
```
