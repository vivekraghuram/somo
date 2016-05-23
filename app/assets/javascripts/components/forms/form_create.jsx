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

  _updateQuestion = (index, data) => {
    this.state.questions[index] = data;
   }

  _deleteQuestion = (index) => {
    this.state.questions[index] = null;
    //this.state.questions.splice(question_id, 1);
    this.forceUpdate();
  }

  _swapUpQuestion = (index) => {
    return;
  }

  _swapDownQuestion = (index) => {
    return;
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
      questions : this.state.questions,
    }
    console.log(JSON.stringify(submission));
    return;
    $.ajax({
      type : "POST",
      url :  'forms/create',
      dataType: 'json',
      contentType: 'application/json',
      data : JSON.stringify(submission)
    }).done(function() {
      // Show success messages and redirect
    }).fail(function(msg) {
      // Show error messages
    });
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
