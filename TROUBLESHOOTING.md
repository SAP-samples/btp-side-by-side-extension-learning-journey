# Troubleshooting Guide

Dear Learner,

due to some npm dependency issues, you could potentially run into some issues from time to time.
The course authors already created a new version of the course, which also uses the highest CAP release then. It will be available in the upcoming weeks. In the meantime, you can do the following to get your app running:

## ISSUE: CDS version outdated

First and foremost, make sure to check your cds version:

```bash
cds -v
```

It should print something similair like this:
```bash
@sap/cds: 6.1.3
@sap/cds-compiler: 3.1.2
@sap/cds-dk: 6.1.5
@sap/cds-dk (global): 6.1.5
@sap/cds-foss: 4.0.0
@sap/cds-mtx: -- missing --
@sap/eslint-plugin-cds: 2.5.0
...
```

If your ```@sap/cds``` dependency is lower than 5.9.x, then please make sure to upgrade your cds packages:

```bash
npm i @sap/cds-dk && npm i @sap/cds && npm update
```

Verify your cds version again with ```cds -v```.

## ISSUE: NPM can't finde a package:

If you see an error like this for any of the required packages, then please follow the steps below:

```
npm ERR! code E404
npm ERR! 404 Not Found - GET http://nginx-redirector.repo-cache.svc.cluster.local/verror/-/verror-1.10.0.tgz
npm ERR! 404 
npm ERR! 404  'https://registry.npmjs.org/verror/-/verror-1.10.0.tgz' is not in this registry.
npm ERR! 404 This package name is not valid, because 
```

1. Delete your `package-lock.json` file and the `node_modules` folder (if already exists).

2. Run `npm install`

If the error still persists, try this:

```
npm cache clear --force
npm install
```

if stil there, add this:

```
npm config set registry http://registry.npmjs.org/
npm install
```

## ISSUE: Approuter invalid redirect_uri:

**SAP NOTE**: https://launchpad.support.sap.com/#/notes/2864831

Some learners also reported that there is currently an issue with the approuter: 

Error Message:  ```The redirect_uri has an invalid domain.```.

If you face this issue, you have to overwrite your ```mta.yaml``` file with the following content:

```NOTE: Please change the oauth2-configuration redirect-uri to your approuter's url!```

Please scroll to the end of the file.

```yaml
---
_schema-version: '3.1'
ID: risk-management
version: 2.0.0
description: "Template for the Learning Journey Building side-by-side extensions on SAP BTP"
parameters:
  enable-parallel-deployments: true
build-parameters:
  before-all:
    - builder: custom
      commands:
        - npm ci
        - npx -p @sap/cds-dk cds build --production

modules:
  - name: risk-management-srv
    type: nodejs
    path: gen/srv
    parameters:
      buildpack: nodejs_buildpack
    build-parameters:
      builder: npm-ci
    provides:
      - name: srv-api # required by consumers of CAP services (e.g. approuter)
        properties:
          srv-url: ${default-url}
    requires:
      - name: risk-management-db
      - name: risk-management-uaa

  - name: risk-management-db-deployer
    type: hdb
    path: gen/db
    parameters:
      buildpack: nodejs_buildpack
    requires:
      - name: risk-management-db

  - name: risk-management
    type: approuter.nodejs
    path: app/ # from cds.env.folders. Consider also cds.env.build.target --> gen/app
    parameters:
      keep-existing-routes: true
      disk-quota: 256M
      memory: 256M
      # hosts: # additional tenant specific hostnames (only for Canary)
      ## the developer will do this via an extension descriptor:
      # - <paas-subdomain >${tenant-delimiter}${host}
      # - <saas-subdomain1>${tenant-delimiter}${host}
      # - ...
    requires:
      - name: srv-api
        group: destinations
        properties:
          name: srv-api # this is a name which must be used in xs-app.json as well
          url: ~{srv-url}
          forwardAuthToken: true
      - name: risk-management-uaa

resources:
  - name: risk-management-db
    type: com.sap.xs.hdi-container
    parameters:
      service: hana # or 'hanatrial' on trial landscapes
      service-plan: hdi-shared
    properties:
      hdi-service-name: ${service-name}

  - name: risk-management-uaa
    type: org.cloudfoundry.managed-service
    parameters:
      service: xsuaa
      service-plan: application
      path: ./xs-security.json
      config:
        xsappname: risk-management-${org}-${space}
        tenant-mode: dedicated
        role-collections:
          - name: 'RiskManager-${space}'
            description: Manage Risks
            role-template-references:
              - $XSAPPNAME.RiskManager
          - name: 'RiskViewer-${space}'
            description: View Risks
            role-template-references:
              - $XSAPPNAME.RiskViewer
        oauth2-configuration:
          redirect-uris:
          # example: - https://risk-management-approuter.cfapps.eu10-004.hana.ondemand.com/login/callback
            - https://<approuter-route>/login/callback

```
