# Dependency Management - L1

## Concept Task

### How Maven resolves transitive dependencies
When a dependency is added to `pom.xml`, Maven doesn't just download that library — it also downloads whatever dependencies *that* library itself needs (its "children"), and so on down the chain. This is called transitive dependency resolution. It means a developer only has to declare the direct dependency they need, and Maven automatically pulls in the full dependency tree, resolving version conflicts using rules like "nearest definition wins" when the same library appears at different depths with different versions.

## Hands-on Task

Added JUnit as a test-scoped dependency in `pom.xml`:

```xml
<dependencies>
  <dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>4.13.2</version>
    <scope>test</scope>
  </dependency>
</dependencies>
```

Forced download by running:

```bash
mvn clean install
```

This downloads JUnit (and its transitive dependencies) into the local repository at:
`~/.m2/repository/junit/junit/`

## Submission
<img width="1917" height="1017" alt="Screenshot 2026-08-11 190538" src="https://github.com/user-attachments/assets/8c15750b-669f-48fe-a496-74920ee2bf1d" />
