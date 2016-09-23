/**
 * @prop initial_state - any initial state info for the form
 */
class FormDesktop extends React.Component {

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
        <div class="row header">
          <h1>{ this.state.name }</h1>
          { this.state.intro }
          <hr/>
        </div>
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
    initial_state: React.PropTypes.object,
};
