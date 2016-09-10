//NOTE: This should inherit from FormCreate but can't figure out how to handleUpdate
//      without exceeding call stack

class ConditionalFormCreate extends React.Component {
  constructor(props) {
    super(props);
    this.state = props.initial_state || {};
    this.state.questions = this.state.questions || [];
  }

  _updateQuestion = (index, data) => {
    this.state.questions[index] = data;
    this.props.handleUpdate(this.state);
   }

  _deleteQuestion = (index) => {
    this.state.questions[index] = null;
    this.props.handleUpdate(this.state);
    this.forceUpdate();
  }

  _swapQuestion = (q1, q2) => {
    this.state.questions[q1.questionIndex] = q2;
    this.state.questions[q2.questionIndex] = q1;

    var q1Index = q1.questionIndex;
    q1.questionIndex = q2.questionIndex;
    q2.questionIndex = q1Index;
    this.props.handleUpdate(this.state);
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
    this.props.handleUpdate(this.state);
    this.forceUpdate();
  }

  _renderQuestion = (question, index, array) => {
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
