/**
 * @prop user_id       - the id of the user
 * @prop form_id       - the id of the form to display
 * @prop initial_state - any initial state info for the form
 */
class FormCreate extends React.Component {

  constructor(props) {
    super(props);
    this.state = props.initial_state || {
      name      : null,
      intro     : null,
      questions : [],
    };
  }

  _updateTitle = (e) => {
    this.setState({name: e.target.value});
  }

  _updateIntro = (e) => {
    this.setState({intro: e.target.value});
  }

  _updateQuestion = (data) => {
    this.state.questions[data.questionIndex] = data;
   }

  _deleteQuestion = (index) => {
    this.state.questions[index] = null;
    this.forceUpdate();
  }

  _swapQuestion = (q1, q2) => {
    this.state.questions[q1.questionIndex] = q2;
    this.state.questions[q2.questionIndex] = q1;

    var q1Index = q1.questionIndex;
    q1.questionIndex = q2.questionIndex;
    q2.questionIndex = q1Index;
    this.forceUpdate();
  }

  _swapUpQuestion = (index) => {
    var q1 = this.state.questions[index];
    while (--index >= 0) {
      if (this.state.questions[index] != null) {
        return this._swapQuestion(q1, this.state.questions[index]);
      }
    }
    console.log("failure swap up");
  }

  _swapDownQuestion = (index) => {
    var q1 = this.state.questions[index];
    while (++index < this.state.questions.length) {
      if (this.state.questions[index] != null) {
        return this._swapQuestion(q1, this.state.questions[index]);
      }
    }
    console.log("failure swap down");
  }

  _addQuestion = (e) => {
    // This is the default type of a new question
    this.state.questions.push({
      questionType  : "short_answer",
      questionIndex : this.state.questions.length,
      _key          : this.state.questions.length,
    });
    this.forceUpdate();
  }

  _submitForm = (e) => {
    // This won't work. need to number questions manually like i did originally (handles delete)
    this.forceUpdate();
    submission = {
      name      : this.state.name,
      intro     : this.state.intro,
      questions : this._prepareQuestions(this.state.questions),
    }
    console.log(JSON.stringify(submission));
    $.ajax({
      type : "POST",
      url :  'forms/create',
      dataType: 'json',
      contentType: 'application/json',
      data : JSON.stringify(submission)
    }).done(function() {
      // Show success messages and redirect
      console.log("success!");
    }).fail(function(msg) {
      // Show error messages
      console.log("failure...");
    });
  }

  _prepareQuestions = (questions, prefix) => {
    // form is this.state
    prefix = prefix || "";
    var nullIndices = [];
    for (var i = 0; i < questions.length; i++) {
      if (!!questions[i]) { // if the question is not null
        questions[i].qname = "Question " + prefix + (i + 1);

        if (questions[i].questionType == "short_answer") {
          questions[i].options = null;
        } else if (questions[i].questionType == "conditional") {
          for (var j = 0; j < questions[i].options.length; j++) {
            if (questions[i].options[j].questions.length > 0) {
              questions[i].options[j].questions = this._prepareQuestions(questions[i].options[j].questions,
                                                            prefix + (i + 1) + "-" + (j + 1) + ":");
            }
          }
        }
      } else {
        nullIndices.push(i);
      }
    }

    nullIndices.sort().reverse();
    for (var i = 0; i < nullIndices.length; i++) {
      questions.splice(nullIndices[i]);
    }

    return questions;
  }

  _renderQuestion = (question, index, array) => {
    // TODO: Add initial state info here if available
    if (question == null) {
      return;
    }
    return <QuestionCreate key = {question._key}
                           initial_state = {question}
                           handleUpdate = {this._updateQuestion}
                           handleDelete = {this._deleteQuestion}
                           handleSwapUp = {this._swapUpQuestion}
                           handleSwapDown = {this._swapDownQuestion} />;
  }

  render() {
    return (
      <div className = "container">
        <h4 className = "survey-heading">CREATE SURVEY</h4>
        <form>
        <div className = "survey">
          <div className = "row header">
            <input type = "text"
                   name = "title"
                   placeholder = "Survey Title"
                   value = {this.state.name}
                   onChange = {this._updateTitle} />
            <textarea rows = "3"
                      cols = "1"
                      placeholder = "Survey Description"
                      value = {this.state.intro}
                      onChange = {this._updateIntro}></textarea>
            <hr></hr>
          </div>
          {
            this.state.questions.map(this._renderQuestion)
          }
          <div className = "add columns small-centered large-centered text-center"
               onClick = {this._addQuestion}>
            <i className = "fa fa-plus"></i>
            <span>Add Question</span>
          </div>
          <div className = "row finish-cancel">
            <div className = "finish columns right small-5 medium-3 large-2"
                 onClick = {this._submitForm}>
              <span>Finish</span>
            </div>
            <a href = "/">
              <div className = "cancel columns right small-5 medium-3 large-2">
                <span>Cancel</span>
              </div>
            </a>
          </div>
        </div>
        </form>
      </div>
    );
  }
}

FormCreate.propTypes = {
    user_id      : React.PropTypes.number.isRequired,
    form_id      : React.PropTypes.number.isRequired,
    initial_state: React.PropTypes.object,
};
