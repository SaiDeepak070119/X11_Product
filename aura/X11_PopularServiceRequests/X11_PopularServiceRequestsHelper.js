({
	updateSlideToDisplay : function(component) {
		var index = component.get('v.currentSlideIndex');
        
        var elements = document.querySelectorAll('.tile');
        
        elements.forEach(element => {
        	element.style.display = 'none'; 
        });
        
        elements[index].style.display = 'block';
	}
})