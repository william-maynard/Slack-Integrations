@isTest
public class OktanaBirthdaySchedulerTest {
	@isTest
    private static void sayBirthdayTest() {
        String cron = '0 0 7 * * ?';
        String jobId = '';
        Test.startTest();
		jobId = System.schedule('Say Birthday Test', cron, new OktanaBirthdayScheduler());
		Test.stopTest();
		
        System.assert(jobId != null && jobId != '');
    }
}
