$(document).on('ready', function() {

  //return; // Added in to disable this file

  /** MAGIC NUMBERS **/
  var introMaxLength = 100;
  var questionMaxLength = 60;
  var questionMaxNum = 10;
  var optionMaxLength = 100;
  var optionMaxNum = 10;


  /** FORMS **/
  function setName(event) {
    formObject.name = $(this).val();
  }

  function setIntro(event) {
    if ($(this).val().length > introMaxLength) {
      // warn that this is too long
    }
    formObject.intro = $(this).val();
  }


  /** QUESTIONS **/
  function addQuestion(event) {
    if (formObject.questions.length > questionMaxNum) {
      // warn that form is too long
    }
    var qindex = formObject.questions.length;
    var question_id = 'question_' + qindex;
    $(this).before(
      '<div class="row question" id="' + question_id + '">' +
        '<div class="q-header columns small-8 large-8">' +
          '<input type="text" name="question" placeholder="Untitled Question" class="question-title" data-qindex="' + qindex + '">' +
          '<hr>' +
        '</div>' +
        '<div class="drop-down columns small-4 large-4 type-select">' +
          '<select class="custom-drop question-type-select" data-qindex="' + qindex + '">' +
            '<option value="multiple_choice">Multiple Choice</option>' +
            '<option value="checkbox">Checkboxes</option>' +
            '<option value="short_answer">Short Answer</option>' +
            '<option value="conditional">Conditional</option>' +
          '</select>' +
        '</div>' +
        '<div class="columns short-icons">' +
        '<div class="delete right" data-qindex="' + qindex + '">' +
          '<i class="fa fa-trash fa-lg"></i>' +
        '</div>' +
        '<div class="chevron right">' +
          '<i class="fa fa-chevron-down fa-lg"></i>' +
        '</div>' +
        '<div class="chevron right">' +
          '<i class="fa fa-chevron-up fa-lg"></i>' +
        '</div>' +
        '</div>' +
      '</div>');
    formObject.questions.push({"questionType": "multiple_choice", "text": null, "options": []});
    $("#" + question_id).find(".question-type-select").on("change", changeTypeQuestion);
    $("#" + question_id).find(".question-title").on("keyup", editQuestion);
    $("#" + question_id).find(".delete").on("click", removeQuestion);

    $("#" + question_id).find(".question-type-select").trigger("change");
  }

  function removeQuestion() {
    // just null out entry in the question array
    var qindex = parseInt($(this).data("qindex"));
    formObject.questions[qindex] = null;
    $("#question_" + qindex).remove();
  }

  function editQuestion() {
    if ($(this).val().length > questionMaxLength) {
      // warn that this is too long
    }
    formObject.questions[parseInt($(this).data("qindex"))].text = $(this).val();
  }

  function changeTypeQuestion() {
    var qindex = parseInt($(this).data("qindex"));
    var question = $("#question_" + qindex);
    formObject.questions[qindex].questionType = $(this).val();
    formObject.questions[qindex].options = [];
    question.find(".responses").remove();
    switch ($(this).val()) {
      case "short_answer":
        question.find(".type-select").first().after(
          '<div class="responses">' +
            '<div class="short columns small-11 large-11">' +
              'Short Answer' +
            '</div>' +
          '</div>'
        );
        break;
      case "conditional":
        question.find(".type-select").first().after(
          '<div class="responses">' +
            '<div class="options-button columns add-option" data-type="conditional" data-qindex="' + qindex + '">' +
              '<i class="fa fa-circle-o"></i>' +
              'Add Option' +
            '</div>' +
            '<div></div>' +
          '</div>'
        );
        question.find(".add-option").on("click", addOption);
        question.find(".add-option").trigger("click");
        break;
      case "checkbox":
        question.find(".type-select").first().after(
          '<div class="responses">' +
            '<div class="options-button columns add-option" data-type="checkbox" data-qindex="' + qindex + '">' +
              '<i class="fa fa-square-o fa-lg"></i>' +
              'Add Option' +
            '</div>' +
            '<div></div>' +
          '</div>'
        );
        question.find(".add-option").on("click", addOption);
        question.find(".add-option").trigger("click");
        break;
      case "multiple_choice":
        question.find(".type-select").first().after(
          '<div class="responses">' +
            '<div class="options-button columns add-option" data-type="multiple_choice" data-qindex="' + qindex + '">' +
              '<i class="fa fa-circle-o"></i>' +
              'Add Option' +
            '</div>' +
            '<div></div>' +
          '</div>'
        );
        question.find(".add-option").on("click", addOption);
        question.find(".add-option").trigger("click");
        break;
      default:
        console.log("something went wrong.");
    }
  }

  function setConditionalQuestion() {
    var conditional_id = "conditional-" + $(this).parent().attr("id");
    var qindex = $(this).parent().data("qindex");
    var oindex = $(this).parent().data("oindex");
    if ($(this).is(':checked')) {
      $(this).parent().after(
        '<div class="conditional-q columns" id=' + conditional_id + '>' +
          '<div class="add centered columns add-conditional-question" data-oindex="' + oindex + '" data-qindex="' + qindex + '">' +
            '<i class="fa fa-plus"></i>' +
            '<span>Add Question</span>' +
          '</div>' +
        '</div>'
      );
      $(this).parent().parent().find("#" + conditional_id).find(".add-conditional-question").on("click", addSubQuestion);
    } else {
      $(this).parent().parent().find("#" + conditional_id).remove();
    }
  }

  function addSubQuestion(event) {
    if (formObject.questions.length > questionMaxNum) {
      // warn that form is too long
    }
    var sup_qindex = parseInt($(this).data("qindex"));
    var sup_oindex = parseInt($(this).data("oindex"));
    var qindex = formObject.questions[sup_qindex].options[sup_oindex].questions.length;
    var question_id = sup_qindex + '-' + sup_oindex + 'sub_question_' + qindex;
    $(this).before(
      '<div class="row question" id="' + question_id + '" data-sup_oindex="' + sup_oindex + '" data-sup_qindex="' + sup_qindex + '" data-qindex="' + qindex + '">' +
        '<div class="q-header columns small-8 large-8">' +
          '<input type="text" name="question" placeholder="Untitled Question" class="question-title" data-qid="#' + question_id + '">' +
          '<hr>' +
        '</div>' +
        '<div class="drop-down columns small-4 large-4 type-select">' +
          '<select class="custom-drop question-type-select" data-qid="#' + question_id + '">' +
            '<option value="multiple_choice">Multiple Choice</option>' +
            '<option value="checkbox">Checkboxes</option>' +
            '<option value="short_answer">Short Answer</option>' +
          '</select>' +
        '</div>' +
        '<div class="delete right" data-qid="#' + question_id + '">' +
          '<i class="fa fa-trash fa-lg"></i>' +
        '</div>' +
      '</div>');
    formObject.questions[sup_qindex].options[sup_oindex].questions.push({"questionType": "multiple_choice", "text": null, "options": []});
    $("#" + question_id).find(".question-type-select").on("change", changeTypeSubQuestion);
    $("#" + question_id).find(".question-title").on("keyup", editSubQuestion);
    $("#" + question_id).find(".delete").on("click", removeSubQuestion);

    $("#" + question_id).find(".question-type-select").trigger("change");
  }

  function removeSubQuestion() {
    // just null out entry in the question array
    var question = $($(this).data("qid"));
    var qindex = parseInt(question.data("qindex"));
    var sup_qindex = parseInt(question.data("sup_qindex"));
    var sup_oindex = parseInt(question.data("sup_oindex"));
    formObject.questions[sup_qindex].options[sup_oindex].questions[qindex] = null;
    question.remove();
  }

  function editSubQuestion() {
    var question = $($(this).data("qid"));
    var qindex = parseInt(question.data("qindex"));
    var sup_qindex = parseInt(question.data("sup_qindex"));
    var sup_oindex = parseInt(question.data("sup_oindex"));
    formObject.questions[sup_qindex].options[sup_oindex].questions[qindex].text = $(this).val();
  }

  function changeTypeSubQuestion() {
    var question = $($(this).data("qid"));
    var qindex = parseInt(question.data("qindex"));
    var sup_qindex = parseInt(question.data("sup_qindex"));
    var sup_oindex = parseInt(question.data("sup_oindex"));
    formObject.questions[sup_qindex].options[sup_oindex].questions[qindex].questionType = $(this).val();
    formObject.questions[sup_qindex].options[sup_oindex].questions[qindex].options = [];
    question.find(".responses").remove();
    switch ($(this).val()) {
      case "short_answer":
        question.find(".type-select").first().after(
          '<div class="responses">' +
            '<div class="short columns small-11 large-11">' +
              'Short Answer' +
            '</div>' +
          '</div>'
        );
        break;
      case "checkbox":
        question.find(".type-select").first().after(
          '<div class="responses">' +
            '<div class="options-button columns add-option" data-type="checkbox" data-sup_oindex="' + sup_oindex + '" data-sup_qindex="' + sup_qindex + '" data-qindex="' + qindex + '">' +
              '<i class="fa fa-square-o fa-lg"></i>' +
              'Add Option' +
            '</div>' +
            '<div></div>' +
          '</div>'
        );
        question.find(".add-option").on("click", addSubOption);
        question.find(".add-option").trigger("click");
        break;
      case "multiple_choice":
        question.find(".type-select").first().after(
          '<div class="responses">' +
            '<div class="options-button columns add-option" data-type="multiple_choice" data-sup_oindex="' + sup_oindex + '" data-sup_qindex="' + sup_qindex + '" data-qindex="' + qindex + '">' +
              '<i class="fa fa-circle-o"></i>' +
              'Add Option' +
            '</div>' +
            '<div></div>' +
          '</div>'
        );
        question.find(".add-option").on("click", addSubOption);
        question.find(".add-option").trigger("click");
        break;
      default:
        console.log("something went wrong.");
    }
  }

  function moveQuestionUp() {

  }
  function moveQuestionDown() {

  }

  /** OPTIONS **/
  function addOption() {
    var questionType = $(this).data("type");
    var qindex = parseInt($(this).data("qindex"));
    var oindex = formObject.questions[qindex].options.length;
    switch (questionType) {
      case "multiple_choice":
        $(this).before(
          '<div class="options columns">' +
            '<i class="fa fa-circle-o"></i>' +
            '<input type="text" name="option" placeholder="Option" data-oindex="' + oindex + '" id="option' + qindex +'-' + oindex + '" data-qindex="' + qindex + '">' +
          '</div>'
        );
        formObject.questions[qindex].options.push({"value": null});
        break;
      case "checkbox":
        $(this).before(
          '<div class="options columns">' +
            '<i class="fa fa-square-o fa-lg"></i>' +
            '<input type="text" name="option" placeholder="Option" data-oindex="' + oindex + '" id="option' + qindex +'-' + oindex + '" data-qindex="' + qindex + '">' +
          '</div>'
        );
        formObject.questions[qindex].options.push({"value": null});
        break;
      case "conditional":
        $(this).before(
          '<div class="columns options small-8 large-8">' +
            '<i class="fa fa-circle-o"></i>' +
            '<input type="text" name="option-conditional" placeholder="Option" data-oindex="' + oindex + '" id="option' + qindex +'-' + oindex + '" data-qindex="' + qindex + '">' +
          '</div>' +
          '<div class="conditional-check columns" id="condition' + qindex + '-' + oindex + '" data-oindex="' + oindex + '" data-qindex="' + qindex + '">' +
            '<input type="checkbox" name="conditional" value="conditional" class="condition-check"><span>Conditional</span>' +
          '</div>'
        );
        $("#condition" + qindex + "-" + oindex).find(".condition-check").on("click", setConditionalQuestion);
        formObject.questions[qindex].options.push({"value": null, "questions": []});
        break;
      default:
        console.log("something went wrong.");
    }
    $("#option" + qindex + "-" + oindex).on("keyup", editOption);
  }
  function removeOption(question, option) {

  }
  function editOption() {
    var qindex = parseInt($(this).data("qindex"));
    var oindex = parseInt($(this).data("oindex"));
    formObject.questions[qindex].options[oindex].value = $(this).val();
  }

  function addSubOption() {
    var questionType = $(this).data("type");
    var qindex = parseInt($(this).data("qindex"));
    var sup_qindex = parseInt($(this).data("sup_qindex"));
    var sup_oindex = parseInt($(this).data("sup_oindex"));
    var oindex = formObject.questions[sup_qindex].options[sup_oindex].questions[qindex].options.length;
    switch (questionType) {
      case "multiple_choice":
        $(this).before(
          '<div class="options columns">' +
            '<i class="fa fa-circle-o"></i>' +
            '<input type="text" name="option" placeholder="Option" data-oindex="' + oindex + '" id="option' + qindex +'-' + oindex + '-' + sup_qindex + '-' + sup_oindex + '" data-qindex="' + qindex + '"  data-sup_oindex="' + sup_oindex + '" data-sup_qindex="' + sup_qindex + '">' +
          '</div>'
        );
        formObject.questions[sup_qindex].options[sup_oindex].questions[qindex].options.push({"value": null});
        break;
      case "checkbox":
        $(this).before(
          '<div class="options columns">' +
            '<i class="fa fa-square-o fa-lg"></i>' +
            '<input type="text" name="option" placeholder="Option" data-oindex="' + oindex + '" id="option' + qindex +'-' + oindex + '-' + sup_qindex + '-' + sup_oindex + '" data-qindex="' + qindex + '"  data-sup_oindex="' + sup_oindex + '" data-sup_qindex="' + sup_qindex + '">' +
          '</div>'
        );
        formObject.questions[sup_qindex].options[sup_oindex].questions[qindex].options.push({"value": null});
        break;
      default:
        console.log("something went wrong.");
    }
    $("#option" + qindex +'-' + oindex + '-' + sup_qindex + '-' + sup_oindex).on("keyup", editSubOption);
  }

  function editSubOption() {
    var qindex = parseInt($(this).data("qindex"));
    var oindex = parseInt($(this).data("oindex"));
    var sup_qindex = parseInt($(this).data("sup_qindex"));
    var sup_oindex = parseInt($(this).data("sup_oindex"));
    formObject.questions[sup_qindex].options[sup_oindex].questions[qindex].options[oindex].value = $(this).val();
  }

  function moveOptionUp() {

  }
  function moveOptionDown() {

  }

  /** SUBMISSION **/
  // remember to remove options if the question is a short answer
  // remember to remove the null questions from array
  function nextLetter(s){
    return s.replace(/([a-zA-Z])[^a-zA-Z]*$/, function(a){
      var c= a.charCodeAt(0);
      switch(c){
        case 90: return 'A';
        case 122: return 'a';
        default: return String.fromCharCode(++c);
      }
    });
  }

  function submitForm() {
    console.log("Stuff is happening");
    var finalQuestions = [];
    var questionNum = 1;
    for (var i = 0; i < formObject.questions.length; i++) {
      if (!!formObject.questions[i]) { // if the question is not null
        formObject.questions[i].qname = "Question " + questionNum;

        if (formObject.questions[i].questionType == "short_answer") {
          formObject.questions[i].options = null;
        } else if (formObject.questions[i].questionType == "conditional") {

          var questionLetter = 'a';
          for (var j = 0; j < formObject.questions[i].options.length; j++) {
            if (formObject.questions[i].options[j].questions.length > 0) {

              var finalSubQuestions = [];
              for (var k = 0; k < formObject.questions[i].options[j].questions.length; k++) {
                if(!!formObject.questions[i].options[j].questions[k]) { // if question is not null
                  formObject.questions[i].options[j].questions[k].qname = "Question " + questionNum + questionLetter;

                  if (formObject.questions[i].options[j].questions[k].questionType == "short_answer") {
                    formObject.questions[i].options[j].questions[k].options = null;
                  }
                  finalSubQuestions.push(formObject.questions[i].options[j].questions[k]);
                  questionLetter = nextLetter(questionLetter);
                }
              }
              formObject.questions[i].options[j].questions = finalSubQuestions;

            }
          }
        }

        finalQuestions.push(formObject.questions[i]);
        questionNum++;
      }
    }

    formObject.questions = finalQuestions;


    console.log(JSON.stringify(formObject));
    return;
    $.ajax({
      type : "POST",
      url :  'forms/create',
      dataType: 'json',
      contentType: 'application/json',
      data : JSON.stringify(formObject)
    }).done(function() {
      $("#error-msg").remove();
      $("form").after('<div class="error-msg" id="error-msg" style="background-color:#72D3A7">' +
         'Success!' +
      '</div>');
      window.location.href = "/";
    }).fail(function(msg) {
      $("#error-msg").remove();
      $("form").after('<div class="error-msg" id="error-msg">' +
         JSON.parse(msg.responseText).errors +
      '</div>');
    });
  }


  /** STARTUP CODE **/
  var formObject = {"name": null, "intro": null, "questions": []};

  $("#form-title-field").on("keyup", setName);
  $("#form-intro-field").on("keyup", setIntro);
  $("#add-question").on("click", addQuestion);

  $("#log-form").on('click', function(e) {console.log(formObject);});
  $("#submit-form").on('click', submitForm);

  $(document).on("keyup", function(e) {
    var allGood = true;
    $(".question-title").each(function() {
      if ($(this).val().length > questionMaxLength) {
        allGood = false;
        if(!$(this).hasClass("error")) {
          $(this).addClass("error");
          if ($("#error-msg").length === 0) {
            $("form").after('<div class="error-msg" id="error-msg">' +
              'For best results in SMS, limit questions to 60 characters.' +
            '</div>');
          }
        }
      } else {
        $(this).removeClass("error");
      }
    });
    if (allGood) {
      $("#error-msg").remove();
    }
  });

  $("#send-twilio-num").on("click", function() {
    var twilioData = {"form": $("#form-name").data("fid"), "phone": $("#phonenumbers").val().replace(/\D/g,'') };
    console.log(twilioData);
    $.ajax({
      type : "POST",
      url :  '/twilio/start',
      dataType: 'json',
      contentType: 'application/json',
      data : JSON.stringify(twilioData)
    }).done(function() {
      $("#error-msg").remove();
      $("form").after('<div class="error-msg" id="error-msg" style="background-color:#72D3A7">' +
         'Success!' +
      '</div>');
      window.location.href = "/";
    }).fail(function() {
      alert("Looks like something went wrong. Please check your internet connection.");
    });
  });
});
