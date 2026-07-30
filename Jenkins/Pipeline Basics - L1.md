# Infrastructure as Code for CI/CD

## Detailed Description
Infrastructure as Code for CI/CD — wrote a basic Declarative Jenkinsfile defining a multi-stage pipeline as code.

## Concept Task

**Differentiate between Declarative and Scripted pipelines.**

Both are ways to define a Jenkins Pipeline as code (a Jenkinsfile), but they differ in syntax, structure, and flexibility:

**Declarative Pipeline:**
- Newer, more structured syntax with a predefined format: `pipeline { agent {} stages { stage('X') { steps {} } } }`.
- Enforces a specific structure, which makes it easier to read, validate, and lint — Jenkins can catch syntax errors before running.
- Built-in support for features like `post` blocks (success/failure/always), `options`, `parameters`, and `input` — without extra scripting.
- Easier for beginners and for standardizing pipelines across teams, since everyone follows the same structure.
- Less flexible for complex, highly dynamic logic — though this can be worked around using the `script {}` block inside a stage to drop into Groovy when needed.

**Scripted Pipeline:**
- Older syntax, written in full Groovy code: `node { stage('X') { ... } }`.
- Much more flexible — supports loops, conditionals, try/catch, and arbitrary Groovy logic natively, since it's essentially a Groovy script.
- Harder to read and maintain, especially for people without a programming background — there's no enforced structure.
- Errors are often only caught at runtime rather than upfront, since it's interpreted as a general-purpose script rather than validated against a defined schema.
- Better suited for complex, non-standard automation logic that doesn't fit neatly into Declarative's structure.

**In short:** Declarative = structured, opinionated, easy to read/standardize, good for most CI/CD use cases. Scripted = full Groovy power and flexibility, but more complex and harder to maintain. Most teams default to Declarative and only drop into Scripted (via `script {}`) when they hit a real limitation.

## Hands-on Task
Wrote the following Declarative Jenkinsfile with three stages:

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building the application...'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying the application...'
            }
        }
    }
}
```

- Created a new Pipeline job (or added this Jenkinsfile to a repo and pointed a Pipeline job at it via "Pipeline script from SCM").
- Ran the build and confirmed all three stages (Build, Test, Deploy) completed successfully.

## Submission
Jenkinsfile code: included above.

Screenshot of the Pipeline Stage View showing successful completion of all three stages:


