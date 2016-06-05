/**
 * @prop initial_state  - any initial state info for the question
 * @prop handleUpdate   - a function to be called each time the question is updated
 * @prop handleDelete   - a function to be called when the question is deleted
 * @prop handleSwapUp   - a function to be called when swapping the question up
 * @prop handleSwapDown - a function to be called when swapping the question down
 */
class QuestionCreate extends React.Component {

  constructor(props) {
    super(props);
    this.state = this.props.initial_state;
    this.state.questionType = this.state.questionType || null;
    this.state.text = this.state.text || null;
    this.state.options = this.state.options || [];
  }

  _updateText = (e) => {
    this.state.text = e.target.value;
    this.props.handleUpdate(this.state);
    this.forceUpdate();
  }

  _updateType = (e) => {
    // NOTE: we may want to only update the stuff that has changed
    this.state.questionType = e.target.value;
    this.props.handleUpdate(this.state);
    this.forceUpdate();
  }

  _updateOptions = (data) => {
    this.state.options = data.options;
    this.forceUpdate();
  }

  _deleteQuestion = (e) => {
    // TODO: Does the component need to be unmounted??????
    this.props.handleDelete(this.state.questionIndex);
  }

  _swapUp = (e) => {
    console.log(this.state);
    this.props.handleSwapUp(this.state.questionIndex);
    this.forceUpdate();
  }

  _swapDown = (e) => {
    this.props.handleSwapDown(this.state.questionIndex);
  }

  _renderQuestionType = () => {
    switch (this.state.questionType) {
      case "short_answer":
        return <ShortAnswerCreate />;
      case "multiple_choice":
        return <MultipleChoiceCreate
                  initial_options = {this.state.options}
                  handleUpdate = {this._updateOptions} />;
      case "checkbox":
        return <CheckboxCreate
                  initial_options = {this.state.options}
                  handleUpdate = {this._updateOptions} />;
      case "conditional":
        return <ConditionalCreate
                  initial_options = {this.state.options}
                  handleUpdate = {this._updateOptions} />;
      default:
        console.log("Something went horribly wrong. The end is nigh.");
    }
  }

  render() {
    return (
      <div className = "row question">
        <div className = "q-header columns small-8 large-8">
          <input type = "text"
                 name = "question"
                 placeholder = "Untitled Question"
                 value = {this.state.text}
                 onChange = {this._updateText}
                 className = "question-title" />
          <hr />
        </div>
        <div className = "drop-down columns small-4 large-4 type-select">
          <select className = "custom-drop question-type-select"
                  onChange = {this._updateType}
                  value = {this.state.questionType} >
            <option value = "short_answer">Short Answer</option>
            <option value = "multiple_choice">Multiple Choice</option>
            <option value = "checkbox">Checkboxes</option>
            <option value = "conditional">Conditional</option>
          </select>
        </div>
        { this._renderQuestionType() }
        <div className = "columns short-icons">
          <div className = "delete right"
               onClick = {this._deleteQuestion} >
            <i className = "fa fa-trash fa-lg"></i>
          </div>
          <div className = "chevron right"
               onClick = {this._swapDown} >
            <i className = "fa fa-chevron-down fa-lg"></i>
          </div>
          <div className = "chevron right"
               onClick = {this._swapUp} >
            <i className = "fa fa-chevron-up fa-lg"></i>
          </div>
        </div>
      </div>
    )
  }
}

QuestionCreate.propTypes = {
    initial_state    : React.PropTypes.object.isRequired, // Required to determine question type
    handleUpdate     : React.PropTypes.func.isRequired,
    handleDelete     : React.PropTypes.func.isRequired,
    handleSwapUp     : React.PropTypes.func.isRequired,
    handleSwapDown   : React.PropTypes.func.isRequired,
};
