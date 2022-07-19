using riskmanagement as rm from '../db/schema';

 // Annotate Risk elements
 annotate rm.Risks with {
 ID     @title : 'Risk';
 title  @title : 'Title';
 owner  @title : 'Owner';
 prio   @title : 'Priority';
 descr  @title : 'Description';
 miti   @title : 'Mitigation';
 impact @title : 'Impact';
 } 

// Annotate Miti elements
 annotate rm.Mitigations with {
 ID @( 
      UI.Hidden,
      Common : {Text : descr}
 ); 
owner @title : 'Owner';
descr @title : 'Description';
 }

annotate rm.Risks with {
   miti @(Common : {
    //show text, not id for mitigation in the context of risks
    Text            : miti.descr,
    TextArrangement : #TextOnly,
    ValueList       : {
    Label          : 'Mitigations',
    CollectionPath : 'Mitigations',
    Parameters     : [
       {
       $Type : 'Common.ValueListParameterInOut',
       LocalDataProperty : miti_ID,
       ValueListProperty : 'ID'
       },
       {
       $Type : 'Common.ValueListParameterDisplayOnly',
       ValueListProperty : 'descr'
       }
    ]
    }
  });
 }