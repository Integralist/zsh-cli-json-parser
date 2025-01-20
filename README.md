# zsh-cli-json-parser

## `get_cli_options`

The file [get_cli_options.zsh](get_cli_options.zsh) parses a JSON structure and
returns the relevant subcommands and flag options:

> \[!NOTE\]
> This isn't a recursive implementation.\
> We stop at 4 levels deep.

## Example JSON structure

The [example.json](example.json) file demonstrates what structure is required to
be passed to the `get_cli_options` shell function.

## Example Output

Using `example.json` as our example structure, we should see the following
output:

```zsh
# show the top-level commands
$ get_cli_options "example.json" ""
service
acl

# show the top-level/global flag options
$ get_cli_options "example.json" "--"
--help
--quiet
--verbose

# show subcommands and flags
$ get_cli_options "example.json" "acl"
--help-acl
create
list

# show command flags only
$ get_cli_options "example.json" "acl --"
--help-acl

# show subcommands and flags under a subcommand
$ get_cli_options "example.json" "acl list"
--json
third-level

# show subcommand flags only
$ get_cli_options "example.json" "acl list --"
--json

# show subcommands and flags under a third-level subcommand
$ get_cli_options "example.json" "acl list third-level"
--foo
--bar
fourth-level

# show third-level subcommand flags only
$ get_cli_options "example.json" "acl list third-level --"
--foo
--bar
```

## Zsh Autocomplete

You can plug this script into your zsh shell completion setup like so:

> \[!NOTE\]
> The following example is for setting up autocomplete for a binary called
> `example` (which uses the `example.json` from this repo as its structure).

```zsh
#compdef fastly
autoload -U compinit && compinit
autoload -U bashcompinit && bashcompinit

_example_bash_autocomplete() {
    local cur opts input_str
    COMPREPLY=()

    # Current word being completed
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Reconstruct the input arguments excluding the binary name
    local input=("${COMP_WORDS[@]:1}")

	# Join the array into a single string, trimming excess whitespace
    input_str=$(echo "${input[*]}" | sed 's/ *$//')

    # Debugging: Log the exact call to get_cli_options
    # echo "Calling get_cli_options with input_str: '$input_str'" >> /tmp/autocomplete-debug.log

    # Pass the reconstructed input string to get_cli_options
    opts=$(get_cli_options "$HOME/.config/zsh/example.json" "$input_str")

    # Log the result of get_cli_options
    # echo "opts: $opts" >> /tmp/autocomplete-debug.log

    # Generate completions based on opts
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )

    # Fall back to file completion if no matches are found
    [[ $COMPREPLY ]] && return
    compgen -f
    return 0
}
complete -F _example_bash_autocomplete example
```
