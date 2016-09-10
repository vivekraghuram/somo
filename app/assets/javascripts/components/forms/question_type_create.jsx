class ShortAnswerCreate extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className="responses">
        <div className="short columns small-11 large-11">
          Short Answer
        </div>
      </div>
    );
  }
}



class MultipleChoiceCreate extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      options : this.props.initial_options,
    };

    if (this.state.options.length == 0) {
      this.state.options.push({value : null});
    }
  }

  _optionIcon = () => {return "fa fa-circle-o"};

  _updateValue = (index, e) => {
    this.state.options[index].value = e.target.value;
    this.props.handleUpdate(this.state);
    this.forceUpdate();
  }

  _addOption = () => {
    this.state.options.push({value : null});
    this.forceUpdate();
  }

  _renderOption = (option, index, arr) => {
    return (
      <div className="options columns" key={index}>
        <i className={this._optionIcon()}></i>
        <input type="text"
               name="option"
               placeholder="Option"
               value={this.state.options[index].value}
               onChange={this._updateValue.bind(this, index)} />
      </div>
    );
  }

  render() {
    return (
      <div className="responses">
        { this.state.options.map(this._renderOption) }
        <div className="options-button columns add-option"
             onClick={this._addOption}>
          <i className={this._optionIcon()}></i> Add Option
        </div>
        <div></div>
      </div>
    );
  }
}

MultipleChoiceCreate.propTypes = {
    initial_options  : React.PropTypes.array.isRequired,
    handleUpdate     : React.PropTypes.func.isRequired,
};



class CheckboxCreate extends MultipleChoiceCreate {
  _optionIcon = () => {return "fa fa-square-o fa-lg"};
}



class ConditionalCreate extends MultipleChoiceCreate {
  constructor(props) {
    super(props);
    this.state = {
      options     : this.props.initial_options || [],
    };

    if (this.state.options.length == 0) {
      this.state.options.push({
        value       : null,
        conditional : false,
        questions   : [],
      });
    }
  }

  _addOption = () => {
    this.state.options.push({
      value       : null,
      conditional : false,
      questions   : [],
    });
    this.forceUpdate();
  }

  _updateConditional = (index, e) => {
    this.state.options[index].conditional = e.target.checked;
    this.props.handleUpdate(this.state);
    this.forceUpdate();
  }

  _updateQuestions = (index, data) => {
    this.state.options[index].questions = data.questions;
    this.props.handleUpdate(this.state);
    // I don't believe i need to force an update here...
  }

  _renderCheckbox = (index) => {
    if (this.state.options[index].conditional) {
      return <input type="checkbox"
             name="conditional"
             onChange={this._updateConditional.bind(this, index)}
             checked
             className="condition-check" />
    } else {
      return <input type="checkbox"
             name="conditional"
             onChange={this._updateConditional.bind(this, index)}
             className="condition-check" />
    }
  }

  _renderConditionalForm = (index) => {
    if (this.state.options[index].conditional) {
      return <ConditionalFormCreate initial_state={{questions: this.state.options[index].questions}}
                                    handleUpdate={this._updateQuestions.bind(this, index)} />
    }
  }

  _renderOption = (option, index, arr) => {
    return (
      <div key={index}>
        <div className="options columns">
          <i className={this._optionIcon()}></i>
          <input type="text"
                 name="option"
                 placeholder="Option"
                 value={this.state.options[index].value}
                 onChange={this._updateValue.bind(this, index)} />
        </div>
        <div className="conditional-check columns">
          { this._renderCheckbox(index) }
          <span>Conditional</span>
        </div>
        <div></div>
        { this._renderConditionalForm(index) }
      </div>
    );
  }

}
