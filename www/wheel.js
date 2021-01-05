
$(document).ready(function() {
  
  var sagittal = document.getElementsByClassName("sagittalScroll");
  
  for(var j = 0; j < sagittal.length; j++) {
    sagittal[j].addEventListener("wheel", sagittalScroll);
  }
  
  var sagittaln = 0;
  
  function sagittalScroll(event) {
    sagittaln++;
    Shiny.onInputChange("sagittaln", Math.random());
    Shiny.onInputChange("sagittaldy", event.deltaY);
  }
});

$(document).ready(function() {
  
  var coronal = document.getElementsByClassName("coronalScroll");
  
  for(var k = 0; k < coronal.length; k++) {
    coronal[k].addEventListener("wheel", coronalScroll);
  }
  
  var coronaln = 0;
  
  function coronalScroll(event) {
    coronaln++;
    Shiny.onInputChange("coronaln", Math.random());
    Shiny.onInputChange("coronaldy", event.deltaY);
  }
});

$(document).ready(function() {
  
  var axial = document.getElementsByClassName("axialScroll");
  
  for(var i = 0; i < axial.length; i++) {
    axial[i].addEventListener("wheel", axialScroll);
  }
  
  var axialn = 0;
  
  function axialScroll(event) {
    axialn++;
    Shiny.onInputChange("axialn", Math.random());
    Shiny.onInputChange("axialdy", event.deltaY);
  }
  
});






