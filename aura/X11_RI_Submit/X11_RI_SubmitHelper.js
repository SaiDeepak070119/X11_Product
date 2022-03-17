({
	doInit_Helper : function(cmp, event) {
        debugger;
       var labels = cmp.get("v.mapLabels");
       document.title = cmp.get("v.mapLabels.sNewSubmitTitle");
       var objCaseConfig = cmp.get("v.objCaseConfig");
       var contactinformation = cmp.get("v.objContact");
       var userId = $A.get("$SObjectType.CurrentUser.Id");
       
        console.log(userId);
        if(userId==undefined || userId==''){
            cmp.set("v.currentUserId",false);
        }else{
            cmp.set("v.currentUserId",true);
        }
       console.log('test for login or not--- ' + cmp.get("v.objContact")['bIsLogin']);
       var statusBar = document.querySelector('.StatusBar');
        if (statusBar) {
            setTimeout(() => {
                statusBar.scrollIntoView();
            }, 100);
        }
       if(cmp.get("v.objContact")['bIsLogin'] == false){
            this.callServer(cmp, "c.verifyEmail", function(result) {
                if(result == 'userExist'){
                    cmp.set('v.userExist',true);
                }else if(result == 'noUserExist'){
                    cmp.set('v.userExist',false);
                }
            },{
                sEmail : cmp.get("v.objContact")['sEmail']       
            }); 
       }
       
    },
    verifyDetails_Helper : function(cmp, event){
        debugger;
      this.createAccount_Helper(cmp, event);  
    },
    signInPage_Helper : function(cmp, event) {
        debugger;
        var sUserName = cmp.get("v.objContact")['sEmail'];
        var sPassword = cmp.get("v.sPassword");
        if($A.util.isEmpty(sUserName) || $A.util.isEmpty(sPassword)){
            cmp.set("v.bLogInError", true);
        }else{
            
           
            this.callServer(cmp, "c.logIntoCommunity", function(result) {
                
                if(result == $A.get("$Label.c.X11_Login_Failed")){
                    cmp.set("v.bLogin", true);
                }else{
                    cmp.set("v.bLogin", false);
                    window.location.href = result;
                   // this.redirectToPageURL(result);
                }
                
            },{
                "sUserName" : sUserName,
                "sPassword" : sPassword
            });  
        } 
	},
    redirectToAccount_Helper : function(cmp, event) {
        // debugger;
        // var sAccountLink = $A.get("$Label.c.X11_My_Account_Link").replace("/s/","");
    	this.redirectToPageURL('/trackstatus?q=true'); 
    },
    redirectToHome_Helper : function(cmp, event) {
        this.redirectToPageURL('/'); 
    },
    createAccount_Helper: function(cmp, event){
        debugger;
        var contactinformation = cmp.get("v.objContact");
        console.log(contactinformation);
        var isChecked = cmp.find("idemailOptIn").get("v.checked");
        var sContactId = cmp.get('{!v.sContactId}');
		console.log('sContactId>>'+sContactId);
        
        this.callServer(cmp, "c.registerUser", function(result) {
            	this.openCommunityHomePage();
        },{
            objContact : JSON.stringify(contactinformation),
            sPassword : cmp.get("v.sPassword"),
            sCaseNumber : cmp.get("v.sCaseNumber"),
            sEmailOptIn :isChecked,
            ContactID : sContactId
        }); 
    },
    resetPassword_Helper : function(cmp){
        var sUserName = cmp.get("v.objContact")['sEmail']; //cmp.get('v.objContact.sUserName');
        console.log('sEmail>'+sUserName);
        debugger;
        this.callServer(cmp, "c.resetPassword", function(result) {
            console.log('sUserName>'+sUserName);
            //cmp.set("v.bConfirmMessage",true);
            //alert('An email will sent to you, to complete the reset process, please click on the link in the mail to reset the password.');
             
            //this.redirectToPageURL('/');
        },{
            "sUserName" : sUserName
        }); 
        
         var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                
                "message": $A.get("$Label.c.Password_Reset"),//"An email will be sent to you, to complete the reset process, please click on the link in the mail to reset the password.",
                "type" : "success",
                "mode":"sticky"
                
            });
            toastEvent.fire(); 
               
    }
})