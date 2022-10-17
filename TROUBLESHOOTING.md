# Troubleshooting Guide

Dear Learner,

due to some npm dependency updates, you could potentially run into some issues.
The course authors already created a new version of the course, which also uses the highest CAP release then. It will be available in the upcoming weeks. In the meantime, you can do the following to get your app running:

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

Some learners also reported that there is currently an issue with the approuter: 

Error Message:  ```The redirect_uri has an invalid domain.```.

If you face this issue, you have to overwrite your ```mta.yaml``` file with the following content:

```NOTE: Please change the oauth2-configuration redirect-uri to your approuter's url!```

```yaml
---
_schema-version: '3.1'
ID: risk-management
version: 1.0.0
description: "Template for the the SAP Extension Suite Learning Journey"
parameters:
  enable-parallel-deployments: true
build-parameters:
  before-all:
    - builder: custom
      commands:
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
      - name: risk-management-xsuaa
      - name: risk-management-destination-service

  - name: risk-management-db-deployer
    type: hdb
    path: gen/db
    parameters:
      buildpack: nodejs_buildpack
    requires:
      - name: risk-management-db

  - name: risk-management-approuter
    type: nodejs
    path: approuter
    requires:
      - name: risk-management-xsuaa
      - name: srv-api
        group: destinations
        properties:
          forwardAuthToken: true
          strictSSL: true
          name: srv-binding
          url: "~{srv-url}"
    build-parameters:
      requires:
        - name: risk-management-app
          artifacts:
            - ./*
          target-path: resources

  - name: risk-management-app
    type: html5
    path: app
    build-parameters:
      supported-platforms: []


resources:
  - name: risk-management-db
    type: com.sap.xs.hdi-container
    parameters:
      service: hana
      service-plan: hdi-shared
  - name: risk-management-xsuaa
    type: org.cloudfoundry.managed-service
    parameters:
      service: xsuaa
      service-plan: application
      path: ./xs-security.json
      config:
        xsappname: risk-management-${space}
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
  - name: risk-management-destination-service
    type: org.cloudfoundry.managed-service
    parameters:
      service: destination
      service-plan: lite
```

