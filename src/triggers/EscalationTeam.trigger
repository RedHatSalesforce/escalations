/**
* Trigger for escalation teams
*
* @author Preeti (ppreeti@redhat.com)
* @testClasses EscalationTeamTrigger_Test
*/
trigger EscalationTeam on rh_escal__EscalationTeam__c (before insert, before update, before delete, after insert, after update, after delete) {
	EscalationTeamTrigger t = new EscalationTeamTrigger(Trigger.oldMap, Trigger.new, Trigger.isBefore);
}