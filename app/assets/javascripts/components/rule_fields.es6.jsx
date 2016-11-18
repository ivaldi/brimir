class RuleFields extends React.Component {
  constructor(props) {
    super(props);
    this.state = { operation: 'assign_label' };
    /* XXX Why can't we use ES6 fat-arrow for this? Gem too old? */
    this.operationSelected = this.operationSelected.bind(this);
  }

  operationSelected(e) {
    this.setState({
      operation: e.target.value
    });
  }

  options(operation) {
    return this.props.actions[operation].values.map(function(user) {
      return <option key={user.key} value={user.key}>{user.value}</option>;
    });
  }

  render () {
    let action_value = <select name="rule[action_value]">
      {this.options(this.state.operation)}
    </select>;

    let actions = [];
    for(key in this.props.actions) {
      actions.push(<option key={key} value={key}>{this.props.actions[key].label}</option>);
    }

    return (
      <div>
        <label htmlFor="rule[action_operation]">
          {this.props.label_action_operation}
        </label>
        <select onChange={this.operationSelected} name="rule[action_operation]">
          {actions}
        </select>
        <label htmlFor="rule[action_value]">
          {this.props.actions[this.state.operation].label}
        </label>
        {action_value}
      </div>
    );
  }
}
