# aws-cdk-eks-lambda-proxy-workaround

UPDATE: The fix has been released. This workaround is no longer necessary.

Workaround for proxy support in the onEvent EKS Lambda. This workaround is necessary until [this fix](https://github.com/aws/aws-cdk/pull/16657) is released.

## Before you continue

This workaround involves replacing the EKS's "onEventHandler" Lambda function through the AWS Console.

This workaround expects that you have already deployed the EKS cluster using `"aws-cdk": "1.125.0"` or below.

This workaround expects that you have configured your cluster for proxy support.

e.g.
```ts
import { Cluster, KubernetesVersion } from '@aws-cdk/aws-eks';
import { Port } from '@aws-cdk/aws-ec2';

...

const cluster = new Cluster(stack, 'hello-eks', {
  vpc,
  version: KubernetesVersion.V1_21,
  placeClusterHandlerInVpc: true,
  clusterHandlerEnvironment: {
    http_proxy: `http://${USERNAME}:${PASSWORD}@${proxyInstance.instancePublicIp}:3128`, // Set the http_proxy environment variable to the proxy server's URL
  },
});
cluster.connections.allowTo(proxyInstance, Port.tcp(80), 'Allow HTTP traffic to the proxy server');
```

## Steps

**1. Clone this repo and step in**

```sh
$ git clone https://github.com/ryparker/aws-cdk-eks-lambda-proxy-workaround.git
$ cd aws-cdk-eks-lambda-proxy-workaround.git
```

**2. Run the bundle script to build the Docker image and output a `handler.zip` file.**

*Docker daemon must be running*

```sh
$ ./bundle.sh
```

**3. Locate the EKS's "onEventHandler" Lambda function in the [AWS Console](https://console.aws.amazon.com/lambda/home#/functions)**

The "onEventHandler" Lambda will have the following:

- Function name: `<STACK_NAME>-OnEventHandler<HASH>-<HASH>`
- Description: `onEvent handler for EKS cluster resource provider`

<br />
<kbd>
<img src="docs/aws-console-lambda-table.png" width="800px" />
</kbd>
<br />
<br />

**4. Click `Upload from` and select `.zip file`**

<br />
<kbd>
<img src="docs/aws-console-lambda-function-upload-button.png" width="800px" />
</kbd>
<br />
<br />

**5. Upload the `handler.zip` we created in step 2. Then click save**

<br />
<kbd>
<img src="docs/aws-console-upload-zip.png" width="800px" />
</kbd>
<br />
<br />

**6. Confirm the upload was successful**

- A `node_modules` directory is present.
- The `common.js` file now configures the proxy agent.
- "Changes deployed" status appears at the top of the editor.

<br />
<kbd>
<img src="docs/aws-console-uploaded-result.png" width="800px" />
</kbd>
<br />
<br />

**All `aws-sdk-js` requests in the Lambda should now be routed through a proxy. Once the official fix is released this Lambda will be overwritten on the next `cdk deploy`.**

For details on the issue and official fix see [this PR](https://github.com/aws/aws-cdk/pull/16657)
