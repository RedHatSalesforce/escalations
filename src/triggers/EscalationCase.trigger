/**
* JavaDoc Stub
*
* @author
*/
trigger EscalationCase on EscalationCase__c (before insert, before update, before delete, after insert, after update, after delete) {
	EscalationCaseTrigger t = new EscalationCaseTrigger(Trigger.oldMap, Trigger.new, Trigger.isBefore);
}