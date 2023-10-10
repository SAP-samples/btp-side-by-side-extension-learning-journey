# Troubleshooting Guide

Dear Learner,

due to dependecies or product updates, you could potentially run into some issues from time to time.

Before posting a question in our [SAP Learning Group](https://groups.community.sap.com/t5/sap-learning-groups/ct-p/SAP-Learning), please **read** this troubleshooting guide **carefully**.

First and foremost, make sure to check your cds version:

```bash
cds -v
```

It should print something similair like this:
```bash
@cap-js/sqlite: 1.3.0
@sap/cds: 7.3.0
@sap/cds-compiler: 4.3.0
@sap/cds-dk: 7.3.0
@sap/cds-fiori: 1.1.0
@sap/cds-foss: 4.0.2
@sap/cds-mtxs: 1.12.0
@sap/eslint-plugin-cds: 2.6.3
Node.js: v18.14.2
...
```

If your ```@sap/cds``` dependency is lower than 7.0.0, then please make sure to upgrade your cds packages:

```bash
npm i @sap/cds-dk@7.3.0 && npm i @sap/cds@7.3.0 && npm update
```

Verify your cds version again with ```cds -v```.

## Issue: BusinessPartner search help on object page not working due to odata count=true

If your business partner search help is not working on the object page, then this is due to an issue with an OData parameter in the query.

### Solution:

In `risk-service.js` adjust the event handler as follows:

```js
 this.on("READ", BusinessPartners, async (req) => {
        // The API Sandbox returns alot of business partners with empty names.
        // We don't want them in our application
        req.query.where("LastName <> '' and FirstName <> '' ");
        
        // --> ADD THIS LINE TO REMOVE THE COUNT PARAMETER
        req.query.SELECT.count = false;

        return await BPsrv.transaction(req).send({
            query: req.query,
            headers: {
                apikey: process.env.apikey,
            },
        });
    });
```

## Issue: NPM can't finde a package / npm package not in registry

If you see an error like this in the SAP Business Application Studio for any of the required packages, then please follow the steps below:

```
npm ERR! code E404
npm ERR! 404 Not Found - GET http://nginx-redirector.repo-cache.svc.cluster.local/verror/-/verror-1.10.0.tgz
npm ERR! 404 
npm ERR! 404  'https://registry.npmjs.org/verror/-/verror-1.10.0.tgz' is not in this registry.
npm ERR! 404 This package name is not valid, because 
```

### Solution:

Please run the following in your terminal:

```
npm cache clear --force
npm config set registry http://registry.npmjs.org/
npm install
```

## Issue: CICD Build fails

If your build fails with the following reason, then you have to adjust your `mta.yaml` file.

```
[2023-10-10T12:47:53.139Z] info  mtaBuild - [2023-10-10 12:47:52]  INFO Cloud MTA Build Tool version 1.2.23
[2023-10-10T12:47:53.172Z] info  mtaBuild - [2023-10-10 12:47:52]  INFO generating the "Makefile_20231010124752.mta" file...
[2023-10-10T12:47:53.209Z] info  mtaBuild - [2023-10-10 12:47:52]  INFO done
[2023-10-10T12:47:53.245Z] info  mtaBuild - [2023-10-10 12:47:52]  INFO executing the "make -f Makefile_20231010124752.mta p=CF mtar=risk-management.mtar strict=true mode= t=\"/home/jenkins/agent/workspace/risk-management-job\"" command...
[2023-10-10T12:47:53.283Z] info  mtaBuild - [2023-10-10 12:47:52]  INFO validating the MTA project
[2023-10-10T12:47:53.319Z] info  mtaBuild - [2023-10-10 12:47:52]  INFO running the "before-all" build...
[2023-10-10T12:47:53.354Z] info  mtaBuild - [2023-10-10 12:47:52]  INFO executing the "npx cds build --production" command...
[2023-10-10T12:47:54.321Z] error mtaBuild - npm ERR! could not determine executable to run
[2023-10-10T12:47:54.357Z] info  mtaBuild - 
[2023-10-10T12:47:54.394Z] error mtaBuild - npm ERR! A complete log of this run can be found in:
[2023-10-10T12:47:54.428Z] error mtaBuild - npm ERR!     /home/mta/.npm/_logs/2023-10-10T12_47_52_982Z-debug-0.log
[2023-10-10T12:47:54.463Z] error mtaBuild - .[2023-10-10 12:47:54] ERROR the "before-all"" build failed: could not execute the "npx cds build --production" command: exit status 1
[2023-10-10T12:47:54.498Z] info  mtaBuild - make: *** [Makefile_20231010124752.mta:28: pre_build] Error 1
[2023-10-10T12:47:54.533Z] info  mtaBuild - Error: could not build the MTA project: could not execute the "make -f Makefile_20231010124752.mta p=CF mtar=risk-management.mtar strict=true mode= t=\"/home/jenkins/agent/workspace/risk-management-job\"" command: exit status 2
```

## Solution:

In your `mta.yaml` file, add the `npm ci` command to your `before-all` commands. It should look like the following:

```
_schema-version: '3.1'
ID: risk-management
version: 3.0.0
description: "Template for the Learning Journey Building side-by-side extensions on SAP BTP"
parameters:
  enable-parallel-deployments: true
build-parameters:
  before-all:
    - builder: custom
      commands:
        - npm ci
        - npx cds build --production
modules:
[...]
```