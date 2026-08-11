# Packaging - L1

## Concept Task

### `.jar` vs `.war`
- **`.jar` (Java ARchive)** – packages a standalone Java application or library. Can be run directly with `java -jar app.jar`. Used for regular applications, CLI tools, and reusable libraries.
- **`.war` (Web Application aRchive)** – packages a web application designed to run inside a servlet container/application server (e.g. Apache Tomcat). Contains a web-specific directory structure (`WEB-INF`, JSPs, servlets) and cannot run standalone — it needs a container to deploy into.

## Hands-on Task

Set explicit packaging type in `pom.xml`:

```xml
<packaging>jar</packaging>
```

Built the artifact:

```bash
mvn package
```

This produces the `.jar` file inside the `target/` directory (e.g. `my-app-1.0-SNAPSHOT.jar`).

## Submission

<img width="1917" height="417" alt="image" src="https://github.com/user-attachments/assets/6056a90d-8774-413c-94a3-68d480108f98" />
