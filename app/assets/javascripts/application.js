//= require jquery
//= require jquery_ujs
//= require react
//= require react_ujs
//= require components
//= require_tree .

var ready = (function(){ $(document).foundation(); });

$(document).ready(function() {
  $("#send-twilio-num").on("click", function() {
     var twilioData = {"form": $("#form-name").data("fid"), "phone": $("#phonenumbers").val().replace(/\D/g,'') };
     console.log(twilioData);
     $.ajax({
       type : "POST",
       url :  '/forms/' + twilioData["form"] + '/start',
       dataType: 'json',
       contentType: 'application/json',
       data : JSON.stringify(twilioData)
     }).done(function() {
       alert("Success!");
       window.location.href = "/";
     }).fail(function() {
       alert("Looks like something went wrong. Please check your internet connection.");
     });
   });
});
