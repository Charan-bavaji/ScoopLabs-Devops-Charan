# Build Lifecycle - L1

## Concept Task

### Default Maven build phases (in order)
1. **validate** – checks the project structure and configuration are correct
2. **compile** – compiles the source code (`.java` → `.class`)
3. **test** – runs unit tests using a testing framework (e.g. JUnit)
4. **package** – packages compiled code into a distributable format (`.jar` or `.war`)
5. **verify** – runs additional checks on the packaged artifact (e.g. integration tests)
6. **install** – installs the artifact into the local `.m2` repository for use by other local projects
7. **deploy** – copies the final artifact to a remote repository for sharing with other teams/CI systems

## Hands-on Task

Generated a basic Java project using a Maven archetype and built it.

```bash
mvn archetype:generate -DgroupId=com.example -DartifactId=my-app -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
cd my-app
mvn clean install
```

**Note:** The default archetype targets an old Java version (source/target 5), which modern JDKs reject. Fixed by adding this to `pom.xml`:

```xml
<properties>
  <maven.compiler.source>8</maven.compiler.source>
  <maven.compiler.target>8</maven.compiler.target>
</properties>
```

## Submission
<img width="1920" height="1080" alt="Screenshot (53)" src="https://github.com/user-attachments/assets/e570847a-e77f-4e3c-8d45-0bf42829bbc3" />


