/**
 * @prop initial_state - any initial state info for the form
 */
class FormCreate extends React.Component {

  constructor(props) {
    super(props);
    this.state = $.parseJSON(props.initial_state || null) || {
      name      : null,
      intro     : null,
      questions : [],
    };

    this.state.saveState = "unsaved";
    this.state.savePath = null;
  }

  componentDidUpdate(prevProps, prevState) {
    this.state.saveState = "unsaved";
  }

  _updateTitle = (e) => {
    this.state.name = e.target.value;
    this.forceUpdate();
  }

  _updateIntro = (e) => {
    this.state.intro = e.target.value;
    this.forceUpdate();
  }

  _updateQuestion = (data) => {
    this.state.questions[data.questionIndex] = data;
    this.forceUpdate();
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
  }

  _swapDownQuestion = (index) => {
    var q1 = this.state.questions[index];
    while (++index < this.state.questions.length) {
      if (this.state.questions[index] != null) {
        return this._swapQuestion(q1, this.state.questions[index]);
      }
    }
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
    this.forceUpdate();
    submission = {
      name      : this.state.name,
      intro     : this.state.intro,
      questions : this._prepareQuestions(this.state.questions),
    }
    console.log(JSON.stringify(submission));
    let form = this;
    $.ajax({
      type : "POST",
      url :  this.state.savePath || form.props.save_path,
      dataType: 'json',
      contentType: 'application/json',
      data : JSON.stringify(submission)
    }).done(function(msg) {
      form.state.saveState = "saved";
      if (msg.data) {
        form.state.save_path = msg.data.save_path;
        window.history.pushState(null, "Edit Page", msg.data.edit_path);
      }
      form.forceUpdate();
    }).fail(function(msg) {
      alert("Something went wrong. \
             We could not save your form. \
             Please check your internet connection");
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
            if (questions[i].options[j].questions && questions[i].options[j].questions.length > 0) {
              questions[i].options[j].questions = this._prepareQuestions(questions[i].options[j].questions,
                                                            prefix + (i + 1) + "-" + (j + 1) + ":");
            } else {
              questions[i].options[j].questions = null;
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

  _renderSaveButton = () => {
    if (this.state.name && this.state.intro) {
      switch (this.state.saveState) {
        // case "saving": Put a loading spinner for this case
        case "saved":
          return (
            <div className = "finish columns right small-5 medium-3 large-2"
                 onClick = {this._submitForm}>
              <span>Saved <i className="fa fa-check"></i></span>
            </div>
          )
        default:
          return (
            <div className = "finish columns right small-5 medium-3 large-2"
                 onClick = {this._submitForm}>
              <span>Save</span>
            </div>
          )
      }
    }
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
            { this._renderSaveButton() }
            <a href = { this.props.root_path }>
              <div className = "cancel columns right small-6 medium-4 large-3">
                <span>Return to Dashboard</span>
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
    root_path    : React.PropTypes.string.isRequired,
    save_path    : React.PropTypes.string.isRequired,
    initial_state: React.PropTypes.string,
};
