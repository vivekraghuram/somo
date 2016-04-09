$(document).on('ready', function() {

  /** MAGIC NUMBERS **/
  var introMaxLength = 100;
  var questionMaxLength = 100;
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
        '<div class="delete right" data-qindex="' + qindex + '">' +
          '<i class="fa fa-trash fa-lg"></i>' +
        '</div>' +
        '<div class="chevron right">' +
          '<i class="fa fa-chevron-down fa-lg"></i>' +
        '</div>' +
        '<div class="chevron right">' +
          '<i class="fa fa-chevron-up fa-lg"></i>' +
        '</div>' +
      '</div>');
    formObject.questions.push({"questionType": "multiple_choice", "text": null, "options": []});
    $("#" + question_id).find(".question-type-select").on("change", changeTypeQuestion);
    $("#" + question_id).find(".question-title").on("keyup", editQuestion);
    $("#" + question_id).find(".delete").on("click", removeQuestion);

    $("#" + question_id).find(".question-type-select").trigger("change");
  }

  function addConditionalQuestion(event) {
    if (formObject.questions.length > questionMaxNum) {
      // warn that form is too long
    }
    var sup_qindex = parseInt($(this).data("qindex"));
    var sup_oindex = parseInt($(this).data("oindex"));
    var qindex = formObject.questions
    var question_id = 'sub_question_' + qindex;
    $(this).after(
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
          '</select>' +
        '</div>' +
        '<div class="delete right" data-qindex="' + qindex + '">' +
          '<i class="fa fa-trash fa-lg"></i>' +
        '</div>' +
        '<div class="chevron right">' +
          '<i class="fa fa-chevron-down fa-lg"></i>' +
        '</div>' +
        '<div class="chevron right">' +
          '<i class="fa fa-chevron-up fa-lg"></i>' +
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

  function setConditionalQuestion() {
    if ($(this).is(':checked')) {
      $(this).after(
        '<div class="conditional-q columns">' +
          '<div class="add centered columns add-conditional-question">' +
            '<i class="fa fa-plus"></i>' +
            '<span>Add Question</span>' +
          '</div>' +
        '</div>'
      );
      $(this).parent().select(".add-conditional-question").on("click", function() {console.log("works!");});
    } else {

    }
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
        formObject.questions[qindex].options.push(null);
        break;
      case "checkbox":
        $(this).before(
          '<div class="options columns">' +
            '<i class="fa fa-square-o fa-lg"></i>' +
            '<input type="text" name="option" placeholder="Option" data-oindex="' + oindex + '" id="option' + qindex +'-' + oindex + '" data-qindex="' + qindex + '">' +
          '</div>'
        );
        formObject.questions[qindex].options.push(null);
        break;
      case "conditional":
        $(this).before(
          '<div class="columns options small-8 large-8">' +
            '<i class="fa fa-circle-o"></i>' +
            '<input type="text" name="option-conditional" placeholder="Option" data-oindex="' + oindex + '" id="option' + qindex +'-' + oindex + '" data-qindex="' + qindex + '">' +
          '</div>' +
          '<div class="conditional-check columns" id="condition' + qindex +'-' + oindex + '">' +
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
    if($(this).attr("name") == "option") {
      formObject.questions[qindex].options[oindex] = $(this).val();
    } else {
      formObject.questions[qindex].options[oindex].value = $(this).val();
    }
  }


  function moveOptionUp() {

  }
  function moveOptionDown() {

  }

  /** SUBMISSION **/
  // remember to remove options if the question is a short answer
  // remember to remove the null questions from array
  function submit() {
    var finalQuestions = [];
    for (var i = 0; i < formObject.questions.length; i++) {
      if (!!formObject.questions[i]) {
        if (formObject.questions[i].type == "short_answer") {
          formObject.questions[i].options = null;
        }
        finalQuestions.push(formObject.questions[i]);
      }
    }

    formObject.questions = finalQuestions;

    $.ajax({
      type : "POST",
      url :  'forms/create',
      dataType: 'json',
      contentType: 'application/json',
      data : JSON.stringify(formObject)
    }).done(function() {
      alert("Success!");
    }).fail(function() {
      alert("failure...");
    });
  }


  /** STARTUP CODE **/
  var formObject = {"name": null, "intro": null, "questions": []};

  $("#form-title-field").on("keyup", setName);
  $("#form-intro-field").on("keyup", setIntro);
  $("#add-question").on("click", addQuestion);

  $("#log-form").on('click', function(e) {console.log(formObject);});
  $("#submit-form").on('click', submit);
});
