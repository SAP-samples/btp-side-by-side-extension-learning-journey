namespace riskmanagement;

using {
    managed,
    cuid,
    User,
    sap.common.CodeList
} from '@sap/cds/common';

entity Risks : cuid, managed {
    title                   : String(100);
    owner                   : String;
    prio                    : Association to Priority;
    descr                   : String;
    miti                    : Association to Mitigations;
    impact                  : Integer;
    // bp : Association to BusinessPartners;
    virtual criticality     : Integer;
    virtual PrioCriticality : Integer;
}

entity Mitigations : cuid, managed {
    descr    : String;
    owner    : String;
    timeline : String;
    risks    : Association to many Risks
                   on risks.miti = $self;
}

entity Priority : CodeList {
    key code : String enum {
            high   = 'H';
            medium = 'M';
            low    = 'L';
        };
}
