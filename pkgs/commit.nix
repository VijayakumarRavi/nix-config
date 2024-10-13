{pkgs, ...}:
pkgs.writeShellScriptBin "commit" ''
  # Define commit prefixes
  prefixes=(
    ":bug: fix: 🐛 bug fixes"
    ":sparkles: feat: ✨ introducing new features"
    ":hammer_and_wrench: chore: 🛠️ routine tasks or maintenance"
    ":books: docs: 📚 documentation changes or improvements"
    ":art: style: 🎨 formatting or stylistic changes (no code logic changes)"
    ":recycle: refactor: ♻️ code changes that improve structure without adding new features or fixing bugs"
  )

  # Function to display prefix options for user selection
  select_prefix() {
    echo "Select a prefix for your commit message:"
    for i in "''${!prefixes[@]}"; do
      prefix=''${prefixes[$i]}
      prefix_code=$(echo "$prefix" | awk '{print $1, $2}')
      description=$(echo "$prefix" | cut -d' ' -f3-)
      printf "%d. %-26s - %s\n" "$((i+1))" "$prefix_code" "$description"
    done
    read -r -p "Enter your choice (1-6): " choice
    if [[ ! $choice =~ ^[1-6]$ ]]; then
      echo "Invalid selection."
      exit 1
    fi
    selected_prefix=$(echo "''${prefixes[$((choice-1))]}" | awk '{print $1, $2}')
  }

  # Function to capture user input for commit message
  get_commit_message() {
    read -r -p "Enter your commit message: " message
    if [[ -z "$message" ]]; then
      echo "Error: commit message cannot be empty."
      exit 1
    fi
  }

  # Function to execute git commit command
  run_git_commit() {
    local full_message="$1"
    git commit --signoff -S -m "$full_message"
    exit $?
  }

  # Function to print help
  print_help() {
    echo "Usage: commit [fix|feat|chore|docs|style|refactor] [optional commit message]"
    exit 0
  }

  if [[ $1 == "-h" || $1 == "--help" ]]; then
    print_help
  fi

  # Main logic based on input argument
  case "$1" in
      "fix")
          selected_prefix=$(echo "''${prefixes[0]}" | awk '{print $1, $2}')
          ;;
      "feat")
          selected_prefix=$(echo "''${prefixes[1]}" | awk '{print $1, $2}')
          ;;
      "chore")
          selected_prefix=$(echo "''${prefixes[2]}" | awk '{print $1, $2}')
          ;;
      "docs")
          selected_prefix=$(echo "''${prefixes[3]}" | awk '{print $1, $2}')
          ;;
      "style")
          selected_prefix=$(echo "''${prefixes[4]}" | awk '{print $1, $2}')
          ;;
      "refactor")
          selected_prefix=$(echo "''${prefixes[5]}" | awk '{print $1, $2}')
          ;;
      *)
          select_prefix
          ;;
  esac

  # Get commit message if not provided
  if [[ -z "$2" ]]; then
    get_commit_message
  else
     message=$2
  fi

  # Create full commit message
  full_message="$selected_prefix $message"
  echo "Committing with message: $full_message"

  # Run git commit
  run_git_commit "$full_message"
''
