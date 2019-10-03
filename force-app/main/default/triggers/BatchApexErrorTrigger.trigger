trigger BatchApexErrorTrigger on BatchApexErrorEvent (after insert) {
         new BatchApexErrorEventsHandler(Trigger.new).handle();
}