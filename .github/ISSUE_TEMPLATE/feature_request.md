name: Feature Request
description: Suggest a new feature or improvement for CachyOS Server build
title: "[FEATURE] "
labels: ["enhancement"]
assignees: []

body:
  - type: markdown
    attributes:
      value: |
        Thank you for proposing a feature! Please provide details below.

  - type: textarea
    id: summary
    attributes:
      label: Summary
      description: A brief summary of the requested feature
      placeholder: "Describe the feature..."
    validations:
      required: true

  - type: textarea
    id: motivation
    attributes:
      label: Motivation
      description: Why is this feature useful?
      placeholder: "Why do you need this feature?"
    validations:
      required: true

  - type: textarea
    id: details
    attributes:
      label: Detailed Description
      description: More details about how this feature should work
      placeholder: "Explain the functionality..."
    validations:
      required: true

  - type: textarea
    id: use_case
    attributes:
      label: Use Case
      description: Describe a scenario in which this feature will be used
      placeholder: "How will this feature be used?"

  - type: textarea
    id: additional
    attributes:
      label: Additional Context
      description: Any other context or examples
