/**
* Trigger for escalation
*
* @author Preeti (ppreeti@redhat.com)
* @testClasses EscalationTrigger_Test
*/
trigger Escalation on rh_escal__Escalation__c (before insert, before update, before delete, after insert, after update, after delete) {
	EscalationTrigger t = new EscalationTrigger(Trigger.oldMap, Trigger.new, Trigger.isBefore);
}