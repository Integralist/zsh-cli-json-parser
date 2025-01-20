# Parses a JSON structure of a CLI tool and return its commands and flags.
#
function get_cli_options() {
	local args=("$@") # array of all input args
  local json_file="$1"
  local input="${args[@]:1}" # all input args minus the first json file arg
  local base_command option_prefix input_words sub_command query

  # Parse input arguments
  base_command="${input%% *}"   # Extract base command
  option_prefix="${input##* }"  # Extract the last part of the input (to check for '--')
	input_words=(${=input})       # Split the input into words

  # Determine query based on input
	# echo "Base command: $base_command" >> /tmp/autocomplete-debug.log
	# echo "Input words: ${input_words[@]}" >> /tmp/autocomplete-debug.log
	# echo "Input: $input" >> /tmp/autocomplete-debug.log

  if [[ "$input" == *"--" ]]; then
		# Handle showing only flag options
		case ${#input_words[@]} in
				1)
						# Return top-level flags.
						# e.g. <binary> --<TAB>
						# e.g. get_cli_options "zsh-example.json" "--"
						query=".options[]?.name | \"--\" + ."
						;;
				2)
						# Return flags for the specified top-level command
						# e.g. <binary> acl --<TAB>
						# e.g. get_cli_options "zsh-example.json" "acl --"
						query=".commands[] | select(.name==\"$base_command\") |
							.options[]?.name | \"--\" + ."
						;;
				3)
						# Return flags for the specified subcommand
						# e.g. fastly acl list --<TAB>
						# e.g. get_cli_options "zsh-example.json" "acl list --"

						# Looks like invoking get_cli_options works differently between calling it manually vs via bash autocomplete
						# Specifically, the autocomplete treats `subcommand` as `--`.
						# Where as calling get_cli_options directly causes `subcommand` to be the subcommand.
						local subcommand="${input_words[2]}"
						if [[ "$subcommand" == "--" ]]; then
							subcommand="${input_words[1]}"
						fi

						query=".commands[] | select(.name==\"$base_command\") |
							.subcommands[]? | select(.name==\"$subcommand\") |
							.options[]?.name | \"--\" + ."
						;;
				4)
						# Return flags for the specified subcommand
						# e.g. fastly acl list third-level --<TAB>
						# e.g. get_cli_options "zsh-example.json" "acl list third-level --"

						# Looks like invoking get_cli_options works differently between calling it manually vs via bash autocomplete
						# Specifically, the autocomplete treats `thirdcommand` as `--`.
						# Where as calling get_cli_options directly causes `thirdcommand` to be the third-level command.
						local subcommand="${input_words[2]}"
						local thirdcommand="${input_words[3]}"
						if [[ "$thirdcommand" == "--" ]]; then
							subcommand="${input_words[1]}"
							thirdcommand="${input_words[2]}"
						fi

						query=".commands[] | select(.name==\"$base_command\") |
							.subcommands[]? | select(.name==\"$subcommand\") |
							.subcommands[]? | select(.name==\"$thirdcommand\") |
							.options[]?.name | \"--\" + ."
						;;
				*)
						echo "bad input: too many args"
						return
						;;
		esac
  elif [[ "$input" == *" "* ]]; then
		if (( ${#input_words[@]} == 3 )); then
	    # Return all subcommands for the specified third-level subcommand
	    # + any flags associated with the third-level subcommand
			# e.g. fastly acl list third-level<TAB>
			# e.g. get_cli_options "zsh-example.json" "acl list third-level"
      local level1 level2 level3
      read level1 level2 level3 <<< "$input"
      query=".commands[] | select(.name==\"$level1\") |
             .subcommands[] | select(.name==\"$level2\") |
             .subcommands[] | select(.name==\"$level3\") |
             (.options[]?.name | \"--\" + .), .subcommands[]?.name"
      jq -r "unique | $query" "$json_file" 2>/dev/null
	  else
	    # Return all third-level subcommands for the specified subcommand
	    # + any flags associated with the subcommand
			# e.g. fastly acl list <TAB>
			# e.g. get_cli_options "zsh-example.json" "acl list"
	    sub_command="${input#* }"
	    query=".commands[] | select(.name==\"$base_command\") |
	   	 .subcommands[]? | select(.name==\"$sub_command\") |
	   	 (.options[]?.name | \"--\" + .), .subcommands[]?.name"
	  fi
  else
		if [[ "$base_command" == "" ]]; then
			# Return all top-level commands
			query=".commands[]?.name"
		else
			# Return all subcommands for the specified top-level command
			# + any flags associated with the top-level command
			# e.g. fastly service <TAB>
			# e.g. get_cli_options "zsh-example.json" "service"
	    sub_command="${input#* }"
			query=".commands[] | select(.name==\"$base_command\") |
						 (.options[]?.name | \"--\" + .), .subcommands[]?.name"
		fi
  fi
	# echo "Query: $query" >> /tmp/autocomplete-debug.log
  jq -r "$query" "$json_file" 2>/dev/null
}
