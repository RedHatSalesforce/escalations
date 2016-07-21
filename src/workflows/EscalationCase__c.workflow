<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_case_as_primary</fullName>
        <description>Sets an EscalationCase as primary</description>
        <field>Primary__c</field>
        <literalValue>1</literalValue>
        <name>Set case as primary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set first case primary</fullName>
        <actions>
            <name>Set_case_as_primary</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EscalationCase__c.Primary__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Escalation__c.CaseCount__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <description>Sets the first case associated with an escalation as the primary case</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
