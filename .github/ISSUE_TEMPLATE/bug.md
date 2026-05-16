name: Bug Report
description: Report a bug in CachyOS Server build
title: "[BUG] "
labels: ["bug"]
assignees: []

body:
  - type: markdown
    attributes:
      value: |
        Thank you for reporting a bug! Please fill in as much information as possible.

  - type: textarea
    id: description
    attributes:
      label: Description
      description: Brief description of the bug
      placeholder: "What went wrong?"
    validations:
      required: true

  - type: textarea
    id: steps
    attributes:
      label: Steps to Reproduce
      description: How to reproduce the bug
      placeholder: |
        1. Run command...
        2. Observe error...
        3. ...
    validations:
      required: true

  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
      description: What should have happened
    validations:
      required: true

  - type: textarea
    id: actual
    attributes:
      label: Actual Behavior
      description: What actually happened
    validations:
      required: true

  - type: textarea
    id: logs
    attributes:
      label: Logs/Error Messages
      description: Any relevant logs or error messages
      render: shell

  - type: textarea
    id: environment
    attributes:
      label: Environment
      description: System information
      placeholder: |
        - OS: (Linux distribution)
        - CPU: (Intel/AMD processor)
        - RAM: (GB)
        - Build Method: (Local/GitHub Actions)
        - Compiler: (GCC/Clang)
    validations:
      required: true

  - type: textarea
    id: additional
    attributes:
      label: Additional Context
      description: Any other context about the problem
