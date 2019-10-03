trigger AccountTrigger on Account (after update, before update) {
	//AccountTriggerHandler.HandleAccountUpdate(trigger.new, trigger.oldMap);
	AccountTriggerHandler.HandleAccountAfterUpdate(trigger.new, trigger.oldMap);
         
}