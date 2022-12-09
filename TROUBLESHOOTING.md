# Troubleshooting Guide

Dear Learner,

due to dependecies or product updates, you could potentially run into some issues from time to time.

Before posting a question in our [SAP BTP Learning Group](https://groups.community.sap.com/t5/sap-btp-learning/gh-p/SAP-BTP-Learning), please go through this troubleshooting guide carefully.

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

## Issue: Approuter invalid redirect_uri:

**SAP NOTE**: https://launchpad.support.sap.com/#/notes/2864831

Some learners also reported that there is currently an issue with the approuter: 

    Error Message:  ```The redirect_uri has an invalid domain.```.

### Solution:

If you face this issue, you have add the ```oauth2-configuration``` to your ```uaa-service``` definition in the ```mta.yaml``` file:

```NOTE: Please change the oauth2-configuration redirect-uri to your approuter's url!```

```yaml
        oauth2-configuration: # <-- add this
          redirect-uris:
          # example: - https://risk-management-approuter.cfapps.eu10-004.hana.ondemand.com/login/callback
            - https://<approuter-route>/login/callback
```

The ```uaa``` or nowadays ```auth``` resource should like like this:

```yaml
---
resources:

  - name: risk-management-auth
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
        oauth2-configuration: # <-- add this
          redirect-uris:
          # example: - https://risk-management-approuter.cfapps.eu10-004.hana.ondemand.com/login/callback
            - https://<approuter-route>/login/callback
```
