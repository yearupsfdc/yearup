@isTest private class LeadTest {
    
    static testMethod void test_TriggerDisabled() {
        TriggerSettings__c triggerSettings = TriggerSettings__c.getOrgDefaults();
        triggerSettings.LeadTriggerDisabled__c = true;
        upsert triggerSettings TriggerSettings__c.Id;
        Lead l = TestDataUtility.createLead('Doe', 'lJane1', 'NY Individuals', 'New Prospect', null, 'Default Lead', true); 
        triggerSettings.LeadTriggerDisabled__c = false;
        upsert triggerSettings TriggerSettings__c.Id;
    }
    
    static testMethod void test_TextCoverage() {
        Lead l = TestDataUtility.createLead('Doe', 'lJane2', 'NY Individuals', 'New Prospect', null, 'Default Lead', true);
        l.firstName = '1Jane3';
        update l;
        delete l;
        undelete l;
    }
    
    static testMethod void test_AutoConvertAdmissionsLeads() {
        Lead l;
        List<Lead> leads = new List<lead>();
        List<Site__c> sites = new List<Site__c>();
        Site__c siteNY = TestDataUtility.createSite('NY', 40, false);
        siteNY.Used_for_Student_Journey__c = true;
        siteNY.Site_Account__c = 'NY Individuals';
        Site__c siteMA = TestDataUtility.createSite('MA', 40, false);
        siteMA.Used_for_Student_Journey__c = true;
        siteMA.Site_Account__c = 'MA Individuals (Boston)';
        sites.add(siteNY);
        sites.add(siteMA);
        insert sites;
        Account acctNY = TestDataUtility.createAccount('NY Individuals', sites[0].Id, 'Individual', true);
        Account acctMA = TestDataUtility.createAccount('MA Individuals', sites[1].Id, 'Individual', true);
        for (Integer i=0; i<10; i++) {
            l = TestDataUtility.createLead('Doe', '1Jane4' + String.valueOf(i), 'NY Individuals', 'New Prospect', 'NY', siteNY.Id, 'Admissions', false);
            l.leadsource = 'Website Interest Form';
            leads.add(l);
        }
        for (Integer i=0; i<10; i++) {
            l = TestDataUtility.createLead('Doe', 'lJane5' + String.valueOf(i), 'MA Individuals', 'New Prospect', 'MA', siteMA.Id, 'Admissions', false);
            l.leadsource = 'Website Interest Form';
            leads.add(l);
        }
        insert leads;
    }
    
    
    static testMethod void test_ConvertAdmissionsLeads() {
        Set<Id> leadids = new Set<Id>();
        Lead l;
        List<Lead> leads = new List<lead>();
        Site__c siteNY = TestDataUtility.createSite('NY', 40, false);
        siteNY.Used_for_Student_Journey__c = True;
        siteNY.Site_Account__c = 'NY Individuals';
        insert siteNY;
        
        Site__c siteMA = TestDataUtility.createSite('MA', 40, false);
        siteMA.Used_for_Student_Journey__c = True;
        siteMA.Site_Account__c = 'MA Individuals';
        insert siteMA;
        
        Account acctNY = TestDataUtility.createAccount('NY Individuals', siteNY.Id, 'Individual', true);
        Account acctMA = TestDataUtility.createAccount('MA Individuals', siteMA.Id, 'Individual', true);
        
        Cohort__c cohort = new Cohort__c(Name = 'July 2018',Start_Date__c = Date.newInstance(2017, 9, 4), End_Date__c = Date.newInstance(2018, 7, 29));
        insert cohort;
        List<Info_Session__c> infsList = new List<Info_Session__c>();
        Info_Session__c infs = new Info_Session__c(Site__c = siteNY.Id, Active__c = True, Session_Status__c = 'Active-Accepting Sign up', Info_Session_Date__c = DateTime.now(), Cohort__c = cohort.Id, Info_Session_Address_Line1__c = 'Test St1', Info_Session_City__c = 'NY', Info_Session_Zip_Code__c = '32145');
        Info_Session__c infs1 = new Info_Session__c(Site__c = siteMA.Id, Active__c = True, Session_Status__c = 'Active-Accepting Sign up', Info_Session_Date__c = DateTime.now(), Cohort__c = cohort.Id, Info_Session_Address_Line1__c = 'Test St1', Info_Session_City__c = 'MA', Info_Session_Zip_Code__c = '32145');
        infsList.add(infs);
        infsList.add(infs1);
        insert infsList;
               
        for (Integer i=0; i<10; i++) {
            l = TestDataUtility.createLead('Doe', '1Jane4' + String.valueOf(i), 'NY Individuals', 'New Prospect', 'NY', siteNY.Id, 'Admissions', false);
            l.Lead_Stage__c = 'Info Session Attended';
            l.Info_Session_Attended__c = False;
            l.Cohort_Name__c = cohort.Id;
            l.Cohort__c = 'July 2018';
            l.Info_Session__c = infsList[0].Id;
            l.Ready_to_Apply__c = 'Yes';
            l.Session_Type__c = 'In-Person';
            leads.add(l);
        }
        insert leads;
        /*for (Integer i=0; i<10; i++) {
            l = TestDataUtility.createLead('Doe', 'lJane5' + String.valueOf(i), 'MA Individuals', 'New Prospect', 'MA', siteMA.Id, 'Admissions', false);
            leads.add(l);
        }*/
        //Site__c siteMA2 = TestDataUtility.createSite('MIA', 50, false);
        lead MA_Lead = TestDataUtility.createLead('Doe', 'lJane5' + String.valueOf('1'), 'MA Individuals', 'New Prospect', 'MA', siteMA.Id, 'Admissions', false);
        MA_Lead.Lead_Stage__c = 'Interest Form Submitted';
        MA_Lead.Info_Session_Attended__c = False;
        //MA_Lead.Site_Location__c = siteMA.Id;
        System.debug('****** Lead MA '+MA_Lead);
        insert MA_Lead;    
        
        leadids.add(MA_Lead.Id);
        
        MA_Lead.Lead_Stage__c = 'Info Session Attended';
        MA_Lead.Cohort_Name__c = cohort.Id;
        MA_Lead.Cohort__c = 'July 2018';
        MA_Lead.Info_Session__c = infsList[1].Id;
        //MA_Lead.Site_Location__c = siteMA2.Id;
        MA_Lead.Ready_to_Apply__c = 'Yes';
        MA_Lead.Session_Type__c = 'In-Person';
        update MA_Lead;
        
        List<Lead> gatewayList = LeadGateway.getLeadsByStatus(leadIds, 'New Prospect');
        Set<String> siteNames = new Set<String>{'MA','NY'};
        List<Site__c> SitesLeadGatewayList = LeadGateway.getSites(siteNames);
    }

    static testMethod void test_ConvertAdmissionsLeadsWithoutMatch() {
        Set<Id> leadids = new Set<Id>();       
        List<Lead> leads = new List<lead>();

        Site__c siteNY = TestDataUtility.createSite('NY', 40, false);
        siteNY.Used_for_Student_Journey__c = True;
        siteNY.Site_Account__c = 'NY Individuals';
        insert siteNY;
        
        Account acctNY = TestDataUtility.createAccount('NY Individuals', siteNY.Id, 'Individual', true);       
        List<Cohort__c> CohortList = New List<Cohort__c>();
        Cohort__c cohortJul = new Cohort__c(Name = 'July 2018',Start_Date__c = Date.newInstance(2017, 9, 4), End_Date__c = Date.newInstance(2018, 7, 29));
        CohortList.add(cohortJul);
        Cohort__c cohortJan = new Cohort__c(Name = 'Janaury 2019',Start_Date__c = Date.newInstance(2018, 9, 4), End_Date__c = Date.newInstance(2019, 7, 29));
        CohortList.add(cohortJan);
        insert CohortList;

        List<Info_Session__c> infsList = new List<Info_Session__c>();
        Info_Session__c infs = new Info_Session__c(Site__c = siteNY.Id, Active__c = True, Session_Status__c = 'Active-Accepting Sign up', Info_Session_Date__c = DateTime.now(), Cohort__c = CohortList[0].Id, Info_Session_Address_Line1__c = 'Test St1', Info_Session_City__c = 'NY', Info_Session_Zip_Code__c = '32145');
        infsList.add(infs);

        insert infsList;
               
       
        Lead l = TestDataUtility.createLead('Doe', '1Jane4', 'NY Individuals', 'New Prospect', 'NY', siteNY.Id, 'Admissions', false);
            l.Lead_Stage__c = 'Info Session Attended';
            l.Info_Session_Attended__c = False;
            l.Cohort_Name__c = CohortList[0].Id;            
            l.Info_Session__c = infsList[0].Id;
            l.Ready_to_Apply__c = 'Yes';
            l.Session_Type__c = 'In-Person';
            l.Email = 'test@test.com';          
      
        insert l;

        Test.startTest();

        Lead newl = TestDataUtility.createLead('Doe', '1Jane4', 'NY Individuals', 'New Prospect', 'NY', siteNY.Id, 'Admissions', false);
            newl.Lead_Stage__c = 'Info Session Attended';
            newl.Info_Session_Attended__c = False;
            newl.Cohort_Name__c = CohortList[1].Id;            
            newl.Info_Session__c = infsList[0].Id;
            newl.Ready_to_Apply__c = 'Yes';
            newl.Session_Type__c = 'In-Person';
            newl.Email = 'test@test.com';          
      
        insert newl;
        Test.stopTest();
        
    }

    static testMethod void test_ConvertAdmissionsLeadsReappliedDescription() {
        Set<Id> leadids = new Set<Id>();       
        List<Lead> leads = new List<lead>();

        Site__c siteNY = TestDataUtility.createSite('NY', 40, false);
        siteNY.Used_for_Student_Journey__c = True;
        siteNY.Site_Account__c = 'NY Individuals';
        insert siteNY;
        
        Account acctNY = TestDataUtility.createAccount('NY Individuals', siteNY.Id, 'Individual', true);       
        List<Cohort__c> CohortList = New List<Cohort__c>();
        Cohort__c cohortJul = new Cohort__c(Name = 'July 2018',Start_Date__c = Date.newInstance(2017, 9, 4), End_Date__c = Date.newInstance(2018, 7, 29));
        CohortList.add(cohortJul);
        Cohort__c cohortJan = new Cohort__c(Name = 'Janaury 2019',Start_Date__c = Date.newInstance(2018, 9, 4), End_Date__c = Date.newInstance(2019, 7, 29));
        CohortList.add(cohortJan);
        insert CohortList;
        
        List<Info_Session__c> infsList = new List<Info_Session__c>();
        Info_Session__c infs = new Info_Session__c(Site__c = siteNY.Id, Active__c = True, Session_Status__c = 'Active-Accepting Sign up', Info_Session_Date__c = DateTime.now(), Cohort__c = CohortList[0].Id, Info_Session_Address_Line1__c = 'Test St1', Info_Session_City__c = 'NY', Info_Session_Zip_Code__c = '32145');
        infsList.add(infs);

        insert infsList;
               
        List<Lead> LeadList = New List<Lead>();

        Lead l = TestDataUtility.createLead('Doe', '1Jane4', 'NY Individuals', 'New Prospect', 'NY', siteNY.Id, 'Admissions', false);
            l.Lead_Stage__c = 'Info Session Attended';
            l.Info_Session_Attended__c = False;
            l.Cohort_Name__c = CohortList[0].Id;            
            l.Info_Session__c = infsList[0].Id;
            l.Ready_to_Apply__c = 'Yes';
            l.Session_Type__c = 'In-Person';
            l.Email = 'test@test.com'; 
         insert l;
        
        Lead newl = TestDataUtility.createLead('Doe', '1Jane4', 'NY Individuals', 'New Prospect', 'NY', siteNY.Id, 'Admissions', false);
            newl.Lead_Stage__c = 'Info Session Attended';
            newl.Info_Session_Attended__c = False;
            newl.Cohort_Name__c = CohortList[1].Id;            
            newl.Info_Session__c = infsList[0].Id;
            newl.Ready_to_Apply__c = 'Yes';
            newl.Session_Type__c = 'In-Person';
            newl.Email = 'test@test.com';               
         
        
        insert newl;
      

        Test.startTest();

        Lead reappliedLead = TestDataUtility.createLead('Doe', '1Jane4', 'NY Individuals', 'New Prospect', 'NY', siteNY.Id, 'Admissions', false);
            reappliedLead.Lead_Stage__c = 'Info Session Attended';
            reappliedLead.Info_Session_Attended__c = False;
            reappliedLead.Cohort_Name__c = CohortList[1].Id;            
            reappliedLead.Info_Session__c = infsList[0].Id;
            reappliedLead.Ready_to_Apply__c = 'Yes';
            reappliedLead.Session_Type__c = 'In-Person';
            reappliedLead.Email = 'test@test.com';          
      
        insert reappliedLead;
        Test.stopTest();
        
    }
    
    
    /*static testMethod void test_ReminderRegardingLeads() {
        Set<Id> leadids = new Set<Id>();
        Lead l;
        List<Lead> leads = new List<lead>();
        Site__c siteNY = TestDataUtility.createSite('NY', 40, false);
        siteNY.Used_for_Student_Journey__c = True;
        siteNY.Site_Account__c = 'NY Individuals';
        insert siteNY;
        
                
        Account acctNY = TestDataUtility.createAccount('NY Individuals', siteNY.Id, 'Individual', true);
        
        Cohort__c cohort = new Cohort__c(Name = 'July 2018',Start_Date__c = Date.newInstance(2017, 9, 4), End_Date__c = Date.newInstance(2018, 7, 29));
        insert cohort;
        
        Datetime dt = Datetime.now();
        Datetime dt1 = dt.addHours(3);
        dt1 = dt1.addMinutes(8);
        System.debug('****************DTTTTT'+dt1);
        
        Datetime dt48 = Datetime.now();
        Datetime dt48hr = dt48.addHours(48);
        dt48hr = dt48hr.addMinutes(8);
        
        List<Info_Session__c> infsList = new List<Info_Session__c>();
        Info_Session__c infs = new Info_Session__c(Site__c = siteNY.Id, Active__c = True, Session_Status__c = 'Active-Accepting Sign up', Info_Session_Date__c = dt1, Cohort__c = cohort.Id, Info_Session_Address_Line1__c = 'Test St1', Info_Session_City__c = 'NY', Info_Session_Zip_Code__c = '32145');
        Info_Session__c infs1 = new Info_Session__c(Site__c = siteNY.Id, Active__c = True, Session_Status__c = 'Active-Accepting Sign up', Info_Session_Date__c = dt48hr, Cohort__c = cohort.Id, Info_Session_Address_Line1__c = 'Test St1', Info_Session_City__c = 'MA', Info_Session_Zip_Code__c = '32145');
        infsList.add(infs);
        infsList.add(infs1);
        insert infsList;
        System.debug('***********'+infsList);
               
        for (Integer i=0; i<10; i++) {
            l = TestDataUtility.createLead('Doe', '1Jane4' + String.valueOf(i), 'NY Individuals', 'New Prospect', 'NY', siteNY.Id, 'Admissions', false);
            l.Lead_Stage__c = 'Info Session Scheduled';
            l.Info_Session_Attended__c = False;
            l.Cohort__c = 'July 2018';
            l.Info_Session__c = infsList[0].Id;
            leads.add(l);
        }
        
        
        Lead l_48 = TestDataUtility.createLead('Doe', '1Jane4' + String.valueOf(12), 'NY Individuals', 'New Prospect', 'NY', siteNY.Id, 'Admissions', false);
            l_48.Lead_Stage__c = 'Info Session Scheduled';
            l_48.Info_Session_Attended__c = False;
            l_48.Cohort__c = 'July 2018';
            l_48.Info_Session__c = infsList[1].Id;
            leads.add(l_48);
        
        insert leads;
        
        
            
        Test.startTest();
        Datetime dt2 = Datetime.now();
        //Datetime dt1 = dt.addHours(3);
        String secs = String.valueOf(dt2.second());
        String mins = String.valueOf(dt2.minute() + 3);
        String hours = String.valueOf(dt2.hour());        
             
        String CRON_EXP = secs + ' ' + mins + ' ' + hours + ' ' + '* * ?';
        System.schedule('Test set3hrReminderFlag', CRON_EXP, new Schedule_3hrReminder());
        
        
        Datetime dt4 = Datetime.now();
        String secs4 = String.valueOf(dt4.second());
        String mins4 = String.valueOf(dt4.minute() + 3);
        String hours4 = String.valueOf(dt4.hour());        
             
        String CRON_EXP1 = secs4 + ' ' + mins4 + ' ' + hours4 + ' ' + '* * ?';
        System.schedule('Test set48hrReminderFlag', CRON_EXP1, new Schedule_48hrReminder());

        Test.stopTest();
     
        
    }*/
    
    /*static testMethod void test_siteSpecialitiesOnLead_Insert() {
        Set<Id> leadids = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();
        Lead l;
        List<Lead> leads = new List<lead>();
        Site__c siteNY = TestDataUtility.createSite('NY', 40, false);
        siteNY.Used_for_Student_Journey__c = True;
        siteNY.Site_Account__c = 'NY Individuals';
        siteNY.Tracks__c = 'Quality Assurance';
        insert siteNY;
        
                
        Account acctNY = TestDataUtility.createAccount('NY Individuals', siteNY.Id, 'Individual', true);
        
        Cohort__c cohort = new Cohort__c(Name = 'July 2018',Start_Date__c = Date.newInstance(2017, 9, 4), End_Date__c = Date.newInstance(2018, 7, 29));
        insert cohort;
       
        for (Integer i=0; i<10; i++) {
            l = TestDataUtility.createLead('Doe', '1Jane4' + String.valueOf(i), 'NY Individuals', 'New Prospect', 'NY', siteNY.Id, 'Admissions', false);
            l.Lead_Stage__c = 'Info Session Scheduled';
            l.Info_Session_Attended__c = False;
            l.Cohort__c = 'July 2018';
            siteIds.add(l.Site_Location__r.id);
            l.Prospect_Track_Interest__c = 'Network';
            leads.add(l);
        }        
        try{
            LeadGateway.getSitesSpecialitiesMap(siteIds); 
            LeadTriggerHandler.siteSpecialitiesOnLead(leads);
        }catch(Exception e) {
            System.Assert(e.getMessage().contains('One or more Specialty Interests are not valid for this site '));        
        } 
        
        
    }
    
    static testMethod void test_siteSpecialitiesOnLead_Update() {
        Set<Id> leadids = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();
        map<Id, SObject> newItems = new map<Id, SObject>();
        map<Id, SObject> oldItems = new map<Id, SObject>();
        Lead l;
        List<Lead> leads = new List<lead>();
        Site__c siteNY = TestDataUtility.createSite('NY', 40, false);
        siteNY.Used_for_Student_Journey__c = True;
        siteNY.Site_Account__c = 'NY Individuals';
        siteNY.Tracks__c = 'Quality Assurance';
        insert siteNY;
        
                
        Account acctNY = TestDataUtility.createAccount('NY Individuals', siteNY.Id, 'Individual', true);
        
        Cohort__c cohort = new Cohort__c(Name = 'July 2018',Start_Date__c = Date.newInstance(2017, 9, 4), End_Date__c = Date.newInstance(2018, 7, 29));
        insert cohort;
       
        for (Integer i=0; i<10; i++) {
            l = TestDataUtility.createLead('Doe', '1Jane4' + String.valueOf(i), 'NY Individuals', 'New Prospect', 'NY', siteNY.Id, 'Admissions', false);
            l.Lead_Stage__c = 'Info Session Scheduled';
            l.Info_Session_Attended__c = False;
            l.Cohort__c = 'July 2018';
            siteIds.add(l.Site_Location__r.id);
            l.Prospect_Track_Interest__c = 'Network';
            leads.add(l);
            newItems.put(l.id,l);
        }     
        
        Lead oldLead = new Lead();
        oldLead.id =  leads[0].id;
        oldLead.Prospect_Track_Interest__c  = 'Account';
        oldItems.put(oldLead.id,oldLead);
        
        try{
            LeadGateway.getSitesSpecialitiesMap(siteIds); 
            LeadTriggerHandler.siteSpecialitiesOnLead(newItems, oldItems);
        }catch(Exception e) {
            System.Assert(e.getMessage().contains('One or more Specialty Interests are not valid for this site '));        
        } 
        
        
    }*/
}