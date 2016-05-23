//NOTE: This should inherit from FormCreate but can't figure out how to handleUpdate
//      without exceeding call stack

class ConditionalFormCreate extends React.Component {
  constructor(props) {
    super(props);
    this.state = props.initial_state || {
      questions : [],
    };
    console.log(this.state);
  }

  _updateQuestion = (index, data) => {
    this.state.questions[index] = data;
    this.props.handleUpdate(this.state);
   }

  _deleteQuestion = (index) => {
    this.state.questions[index] = null;
    //this.state.questions.splice(question_id, 1);
    this.props.handleUpdate(this.state);
    this.forceUpdate();
  }

  _swapUpQuestion = (index) => {
    console.log("Not implemented");
  }

  _swapDownQuestion = (index) => {
    console.log("Not implemented");
  }

  _addQuestion = (e) => {
    // This is the default type of a new question
    this.state.questions.push({
      questionType  : "short_answer",
      questionIndex : this.state.questions.length,
      _key          : this.state.questions.length,
    });
    this.props.handleUpdate(this.state);
    this.forceUpdate();
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
      <div className="conditional-q columns">
        {
          this.state.questions.map(this._renderQuestion)
        }
        <div className="add centered columns add-conditional-question"
             onClick = {this._addQuestion}>
          <i className="fa fa-plus"></i>
          <span>Add Question</span>
        </div>
      </div>
    )
  }
}

ConditionalFormCreate.propTypes = {
    initial_state: React.PropTypes.object,
    handleUpdate: React.PropTypes.func.isRequired,
};
