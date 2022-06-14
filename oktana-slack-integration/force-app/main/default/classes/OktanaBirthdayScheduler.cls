global class OktanaBirthdayScheduler implements Schedulable {
	global void execute(SchedulableContext ctx) {
	
        OktanaBirthdayService.sayBirthdayOnSlack();
        
    //    HappyBirthdayScheduler sayBirthday = new HappyBirthdayScheduler();
    //    String sch = '0 0 7 * * ?';
    //    system.schedule('SayBirthday', sch, sayBirthday);
    }
}
