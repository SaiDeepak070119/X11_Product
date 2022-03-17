({
	fetchIntialData : function(component, event, helper) {
		var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        if(sPageURL){
            var sParameterName = sPageURL.split('=');
            if (sParameterName[0] === 'searchKey') { //lets say you are looking for param name - firstName
                component.set('v.searchKey', sParameterName[1] === undefined ? null : sParameterName[1].replaceAll('+',' '));
                component.set('v.searchInputValue', component.get('v.searchKey'));
            } 
        }
        
        this.callServer(component, "c.fetchIntialData", function (result) {
            var articlesLst = JSON.parse(result);
            component.set("v.articlesList", articlesLst);
            if(articlesLst.length===1){
                setTimeout(function(){
                    document.querySelector('.article-wrapper .accordion').click();
                },300);
                
            }
        },{
            searchKey : component.get('v.searchKey')
        });
	},
    getArticlesbySearch : function(component, event, helper) {
        this.callServer(component, "c.fetchIntialData", function (result) {
            var articlesLst = JSON.parse(result);
            component.set("v.articlesList", articlesLst);
        },{
            searchKey : component.get('v.searchKey')
        });
	},
    handleAccordion: function (component, event) {
        try {
            var getIndex = event.currentTarget.getAttribute("data-id");
            //var getList = component.get("v.lstCategoryGroup");
            // for (var i = 0; i < getList.length; i++) {
            //     if (i == getIndex) {
            event.target.classList.toggle("active");
            //var isExpandable = $A.util.hasClass(component.find("acrd"), "active");
            component.set("v.activeTab", !component.get("v.activeTab"));
            /* Toggle between adding and removing the "active" class, to highlight the button that controls the panel */

            /* Toggle between hiding and showing the active panel */
            var panel = event.target.nextElementSibling;
            if (panel.style.display === "block") {
                panel.style.display = "none";
            } else {
                panel.style.display = "block";
            }
            //     }
            // }

        } catch (e) {
            console.error(e.stack);
        }
    }
})