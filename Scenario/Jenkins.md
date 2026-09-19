# Jenkins Interview Prep: 2 to 5 Years Experience

Questions with interview answers, plus the commands and Jenkinsfile code to say (and show) while answering.

**How to use this file:** For each question, read the **Say** part (your spoken answer in simple words). Then practice the **Commands** or **Jenkinsfile** part. In the interview, say the answer first, then write or explain the code.

**Practice setup (WSL with Docker):**

```bash
mkdir -p ~/linuxCMD/jenkins-lab && cd ~/linuxCMD/jenkins-lab
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-jdk17
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
# open http://localhost:8080 and paste the password
```

## Sections

1. Basics and architecture (Q1 to Q6)
2. Pipeline as code (Q7 to Q19)
3. Triggers and webhooks (Q20 to Q21)
4. Agents and scaling (Q22 to Q25)
5. Troubleshooting scenarios (Q26 to Q33)
6. Operations: backup, upgrade, config as code, monitoring (Q34 to Q37)
7. Security (Q38 to Q39)
8. CI/CD design (Q40 to Q45)

---

# 1. Basics and architecture

## Q1. What is Jenkins? What is the difference between CI, Continuous Delivery, and Continuous Deployment?

**Say:** Jenkins is an open-source automation server. Teams use it to build, test, and deploy code automatically. **CI (Continuous Integration)** means developers merge code often, and every change is built and tested automatically. **Continuous Delivery** means the code is always ready to release, but a person approves the production release. **Continuous Deployment** means every change that passes all tests goes to production automatically, with no manual step.

**Commands:**

```bash
# A very small CI flow that Jenkins runs on every commit:
git clone <repo-url> && cd <repo>
npm ci            # install
npm test          # test
npm run build     # build
```

---

## Q2. Explain Jenkins architecture: controller, agents, and executors.

**Say:** The **controller** (old name: master) is the main Jenkins server. It keeps the configuration, shows the UI, schedules jobs, and stores the history. **Agents** (nodes) are other machines that actually run the builds. An **executor** is one slot on a node that runs one build at a time. If a node has 2 executors, it can run 2 builds together. Good practice: set executors on the controller to **0**, so builds run only on agents. This keeps the controller safe and fast. I use **labels** (for example `linux`, `docker`) to choose which agent runs a job.

**Commands:**

```bash
# Where to look in the UI:
# Manage Jenkins -> Nodes            (see all nodes and executors)
# Manage Jenkins -> Nodes -> Built-In Node -> Configure -> Number of executors = 0
```

```groovy
pipeline {
    agent { label 'linux && docker' }     // run only on agents with both labels
    stages { stage('Test') { steps { sh 'echo hello' } } }
}
```

---

## Q3. What is the difference between Freestyle and Pipeline jobs? And Declarative vs Scripted pipeline?

**Say:** A **Freestyle** job is set up by clicking in the UI. It is simple, but it is hard to copy, review, or keep in Git. A **Pipeline** job is written as code in a `Jenkinsfile` that lives in the repo. It can be reviewed, versioned, and reused, and it supports parallel stages, approvals, retries, and it survives a Jenkins restart. There are two syntaxes. **Declarative** starts with `pipeline { }`. It has a clear structure, so it is easier to read and is what most teams use. **Scripted** starts with `node { }` and is full Groovy code. It is more flexible, but harder to maintain.

**Declarative:**

```groovy
pipeline {
    agent any
    stages {
        stage('Build') { steps { sh 'echo build' } }
    }
}
```

**Scripted:**

```groovy
node {
    stage('Build') {
        sh 'echo build'
    }
}
```

---

## Q4. How do you install Jenkins on Ubuntu? Where are the important files?

**Say:** Jenkins needs Java (17 or 21). I add the Jenkins apt repository, install the package, start the service, and open port 8080. The first login password is in a file. Then I install the suggested plugins and create the admin user. The important folder is **`JENKINS_HOME`** (`/var/lib/jenkins`). It has jobs, plugins, config, and secrets, so I back it up.

**Commands** (check jenkins.io for the latest repository key):

```bash
sudo apt update
sudo apt install -y fontconfig openjdk-17-jre
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable --now jenkins
sudo systemctl status jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword      # first login password
```

**Important places:**

| Path | What is there |
|---|---|
| `/var/lib/jenkins` | JENKINS_HOME: jobs, plugins, config, secrets |
| `/var/lib/jenkins/workspace` | job workspaces (checked-out code) |
| `/var/lib/jenkins/secrets` | encryption keys and initial password |
| `/var/log/jenkins/jenkins.log` | Jenkins log (also `journalctl -u jenkins`) |

To change the port or Java memory, use `sudo systemctl edit jenkins` and add `Environment="JENKINS_PORT=9090"` or `Environment="JAVA_OPTS=-Xmx2g"` under `[Service]`.

---

## Q5. How do you run Jenkins in Docker and keep the data safe?

**Say:** I run the official image and mount a **volume** to `/var/jenkins_home`. Without the volume, all jobs and settings are lost when the container is removed. Port 8080 is the web UI, and port 50000 is for inbound agents.

**Commands:**

```bash
docker run -d --name jenkins --restart unless-stopped \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts-jdk17

docker logs -f jenkins                                        # see startup logs
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
docker volume inspect jenkins_home                            # where the data is on the host
```

If Jenkins in a container must run Docker builds, it needs access to the Docker socket or a separate Docker agent. A common safer way is to run builds on separate agents.

---

## Q6. What is a Jenkinsfile? What is a Multibranch Pipeline?

**Say:** A **Jenkinsfile** is a text file in the root of the repo that defines the pipeline. This is called **Pipeline as Code**. Because it is in Git, changes are reviewed in PRs and have history. A **Multibranch Pipeline** scans a repo and creates a job automatically for **every branch** (and pull request) that has a Jenkinsfile. When a branch is deleted, the job is removed too. It is very useful for feature branches and PR builds.

**Setup path:** New Item → Multibranch Pipeline → Branch Sources → GitHub (or Git) → add credentials → set the repo URL → Save.

**Commands:**

```bash
# put the file in the repo root and push
git add Jenkinsfile
git commit -m "Add Jenkinsfile"
git push origin main
```

```groovy
stage('Deploy') {
    when { branch 'main' }          // works in Multibranch: deploy only from main
    steps { sh './deploy.sh' }
}
```

---

# 2. Pipeline as code

## Q7. Write a basic declarative pipeline. Explain its parts.

**Say:** `agent` says where to run. `environment` sets variables. `options` sets things like timeout and how many old builds to keep. `stages` has the stages, and each stage has `steps`. `post` runs after the build, on success, failure, or always. I always add a timeout and a build discarder, so builds do not hang and disk does not fill.

```groovy
pipeline {
    agent any

    environment {
        APP_NAME = 'myapp'
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Build') {
            steps { sh 'npm ci && npm run build' }
        }
        stage('Test') {
            steps { sh 'npm test' }
        }
    }

    post {
        success { echo 'Build passed' }
        failure { echo 'Build failed' }
        always  { cleanWs() }          // needs the Workspace Cleanup plugin
    }
}
```

---

## Q8. What environment variables does Jenkins give you? How do you set your own?

**Say:** Jenkins gives built-in variables like `BUILD_NUMBER`, `JOB_NAME`, `WORKSPACE`, `BUILD_URL`, `GIT_COMMIT`, and `BRANCH_NAME` (in multibranch). I set my own in the `environment` block, at pipeline level or stage level. To see all of them, I print the environment.

```groovy
pipeline {
    agent any
    environment {
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        APP_ENV   = 'staging'
    }
    stages {
        stage('Show') {
            steps {
                sh 'echo "Build $BUILD_NUMBER of $JOB_NAME on branch $BRANCH_NAME"'
                sh 'env | sort'            // print all variables
            }
        }
    }
}
```

The list of all variables for your Jenkins is at `http://<jenkins>/env-vars.html`.

---

## Q9. How do you add parameters and run a stage only under some conditions?

**Say:** With the `parameters` block, the user can choose values when starting the build (a text box, a dropdown, or a checkbox). I read them with `params.NAME`. To run a stage only sometimes, I use `when`, with `branch`, `expression`, `changeset`, or `environment`.

```groovy
pipeline {
    agent any
    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build')
        choice(name: 'ENV', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run tests?')
    }
    stages {
        stage('Test') {
            when { expression { params.RUN_TESTS } }
            steps { sh 'npm test' }
        }
        stage('Deploy') {
            when { expression { params.ENV == 'prod' } }
            steps { echo "Deploying to ${params.ENV}" }
        }
    }
}
```

Note: parameters show up in the UI only after the first run of the pipeline.

---

## Q10. How do you run stages in parallel?

**Say:** I put stages inside a `parallel` block. They run at the same time, so the pipeline is faster. I add `failFast true`, so if one branch fails, the others stop early and do not waste time.

```groovy
stage('Checks') {
    failFast true
    parallel {
        stage('Unit tests') { steps { sh 'npm run test:unit' } }
        stage('Lint')       { steps { sh 'npm run lint' } }
        stage('Security')   { steps { sh 'npm audit --audit-level=high' } }
    }
}
```

Each parallel stage needs an executor. With few executors, they wait in the queue, so there is no speed gain.

---

## Q11. How do you add a manual approval before production?

**Say:** I use the `input` step. The pipeline pauses and waits for a person to click Proceed or Abort. I set a **timeout** so it does not wait forever, and `submitter` to say who is allowed to approve. I use `agent none` for this stage, so the pipeline does not block an executor while waiting.

```groovy
stage('Approval') {
    agent none
    steps {
        timeout(time: 1, unit: 'HOURS') {
            input message: 'Deploy to production?', ok: 'Deploy', submitter: 'admin,devops-team'
        }
    }
}
stage('Deploy to Prod') {
    steps { sh './deploy.sh prod' }
}
```

---

## Q12. How do you send notifications (email, Slack) after a build?

**Say:** I use the `post` block. On failure I send a message with the job name, build number, and the build link. For email I use the Email Extension plugin (`emailext`), and for Slack the Slack Notification plugin (`slackSend`). I keep the credentials for Slack in Jenkins credentials.

```groovy
post {
    success {
        slackSend channel: '#devops', color: 'good',
                  message: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER} (${env.BUILD_URL})"
    }
    failure {
        slackSend channel: '#devops', color: 'danger',
                  message: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER} (${env.BUILD_URL})"
        emailext to: 'team@example.com',
                 subject: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "Check the logs: ${env.BUILD_URL}"
    }
}
```

For email to work, configure SMTP in Manage Jenkins → System.

---

## Q13. How do you manage secrets and credentials in Jenkins?

**Say:** I never put passwords in the Jenkinsfile or in the repo. I store them in **Jenkins Credentials** and use them by ID. The types are: username with password, secret text, SSH private key, secret file, and certificate. In a pipeline I use `withCredentials`, and Jenkins hides the value in the logs. I use **single quotes** for `sh` commands with secrets, so Groovy does not put the secret into the command text. The shell reads it as an environment variable.

```groovy
withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                  usernameVariable: 'DOCKER_USER',
                                  passwordVariable: 'DOCKER_PASS')]) {
    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
}
```

```groovy
withCredentials([string(credentialsId: 'api-token', variable: 'API_TOKEN')]) {
    sh 'curl -H "Authorization: Bearer $API_TOKEN" https://api.example.com/deploy'
}
```

Short form in `environment` (creates `DOCKER_USR` and `DOCKER_PSW`):

```groovy
environment { DOCKER = credentials('dockerhub-creds') }
```

**Setup path:** Manage Jenkins → Credentials → System → Global credentials → Add Credentials.

---

## Q14. Write a pipeline that builds a Docker image and pushes it to Docker Hub.

**Say:** I tag the image with the **build number** (so each build is unique and I can roll back), and also with `latest`. I log in with credentials, push, and log out in `post`.

```groovy
pipeline {
    agent any
    environment {
        IMAGE = 'your-dockerhub-user/myapp'
        TAG   = "${env.BUILD_NUMBER}"
    }
    stages {
        stage('Build Image') {
            steps { sh 'docker build -t $IMAGE:$TAG -t $IMAGE:latest .' }
        }
        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                  usernameVariable: 'U', passwordVariable: 'P')]) {
                    sh '''
                        echo "$P" | docker login -u "$U" --password-stdin
                        docker push $IMAGE:$TAG
                        docker push $IMAGE:latest
                    '''
                }
            }
        }
    }
    post {
        always { sh 'docker logout || true' }
    }
}
```

The `jenkins` user must be allowed to use Docker (see Q26).

---

## Q15. How do you use Docker as a build agent, and how do you set up build tools?

**Say:** With the Docker Pipeline plugin, a stage can run inside a container, for example `node:20`. Every build then uses the same clean environment, and I do not need to install Node on the agent. For tools like Maven or JDK, I can also configure them in **Global Tool Configuration** and use the `tools` block.

```groovy
pipeline {
    agent {
        docker { image 'node:20' }
    }
    stages {
        stage('Build') {
            steps {
                sh 'node -v'
                sh 'npm ci && npm run build'
            }
        }
    }
}
```

```groovy
pipeline {
    agent any
    tools {
        maven 'Maven3'          // name set in Manage Jenkins -> Tools
        jdk   'JDK17'
    }
    stages { stage('Build') { steps { sh 'mvn -B clean package' } } }
}
```

---

## Q16. How do you save build files and show test results?

**Say:** `archiveArtifacts` saves build outputs (jar, zip, reports) so I can download them later. `junit` reads test result XML files and shows the trend in the UI. `stash` and `unstash` pass files between stages when they run on different agents.

```groovy
stage('Test') {
    steps {
        sh 'npm test -- --reporter junit'
    }
    post {
        always { junit 'reports/*.xml' }
    }
}
stage('Package') {
    steps {
        sh 'npm run build'
        archiveArtifacts artifacts: 'dist/**', fingerprint: true
        stash name: 'build-output', includes: 'dist/**'
    }
}
stage('Deploy') {
    agent { label 'deploy-agent' }
    steps {
        unstash 'build-output'
        sh './deploy.sh'
    }
}
```

---

## Q17. How do you handle flaky steps? (`retry`, `timeout`, `catchError`)

**Say:** For steps that fail sometimes because of network (like downloading packages), I use `retry`. I add `timeout` so a stuck step does not run forever. For a stage that is not critical (like a code report), I use `catchError`, so the build continues and is only marked unstable. I use retry **only** for network-type steps. I do not hide real test failures with it. For flaky tests, I find the root cause.

```groovy
stage('Install') {
    steps {
        retry(3) {
            sh 'npm ci'
        }
    }
}
stage('Slow API test') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
            sh './run-api-tests.sh'
        }
    }
}
stage('Optional report') {
    steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
            sh './generate-report.sh'
        }
    }
}
```

---

## Q18. What are Shared Libraries?

**Say:** A Shared Library is common Groovy code kept in its own Git repo, and many Jenkinsfiles can use it. It stops copy-paste of the same steps across many projects. The library has a `vars/` folder, and each file there becomes a custom step. I configure the library once in Manage Jenkins → System → Global Trusted Pipeline Libraries.

**Library repo:** `vars/buildAndTest.groovy`

```groovy
def call(String nodeVersion = '20') {
    sh "node -v"
    sh 'npm ci'
    sh 'npm test'
}
```

**Jenkinsfile:**

```groovy
@Library('my-shared-lib@main') _

pipeline {
    agent any
    stages {
        stage('CI') {
            steps { buildAndTest('20') }
        }
    }
}
```

---

## Q19. How do you start another job from a pipeline, or start a build from outside Jenkins?

**Say:** Inside a pipeline I use the `build` step to trigger a downstream job. I can pass parameters and choose whether to wait. From outside Jenkins (scripts, other tools) I use the REST API with a user and an **API token**.

```groovy
stage('Trigger deploy') {
    steps {
        build job: 'deploy-app',
              parameters: [string(name: 'VERSION', value: "${env.BUILD_NUMBER}")],
              wait: true
    }
}
```

**Commands:**

```bash
# start a build without parameters
curl -X POST -u USER:API_TOKEN http://jenkins:8080/job/my-job/build

# start a build with parameters
curl -X POST -u USER:API_TOKEN "http://jenkins:8080/job/my-job/buildWithParameters?ENV=dev&VERSION=12"
```

Create the API token in: User → Configure → API Token.

---
# 3. Triggers and webhooks

## Q20. How can a Jenkins build be triggered? Webhook vs Poll SCM vs cron.

**Say:** There are three common ways. A **webhook** is the best: GitHub calls Jenkins when code is pushed, so the build starts at once and Jenkins does no extra work. **Poll SCM** means Jenkins asks Git every few minutes if there is a change. It is slower and adds load, so I use it only when a webhook is not possible (for example, Jenkins is behind a firewall). **Cron (build periodically)** runs at a fixed time, for example a nightly build. In cron, `H` means a hashed value, so many jobs do not all start at the same minute.

```groovy
pipeline {
    agent any
    triggers {
        githubPush()                    // webhook from GitHub
        // pollSCM('H/5 * * * *')       // check Git every 5 minutes
        // cron('H 2 * * *')            // run nightly, around 2 AM
    }
    stages { stage('Build') { steps { sh 'echo build' } } }
}
```

**GitHub webhook setup:**

1. GitHub repo → Settings → Webhooks → Add webhook.
2. Payload URL: `http://<jenkins-url>/github-webhook/` (keep the last `/`).
3. Content type: `application/json`. Event: **Just the push event**.
4. In the Jenkins job, enable **GitHub hook trigger for GITScm polling** (or use `githubPush()`).

---

## Q21. The GitHub webhook is not triggering the build. How do you troubleshoot?

**Say:** I start on the GitHub side and check **Recent Deliveries** in the webhook page. It shows the response code. Then I check that Jenkins is reachable from the internet and that the job trigger is set.

**Checklist:**

1. **GitHub → Webhooks → Recent Deliveries:** what is the status?
   - `200`: GitHub reached Jenkins, so the problem is the job settings or branch filter.
   - Timeout or connection error: Jenkins is not reachable (firewall, security group, private IP).
   - `403`: security or CSRF issue (reverse proxy blocking, wrong auth).
   - `404`: wrong URL. It must end with `/github-webhook/`.
2. **Jenkins URL** is set correctly: Manage Jenkins → System → Jenkins Location.
3. **Job trigger** is enabled, and the branch or repo URL matches.
4. **GitHub plugin** is installed and updated.
5. **Network:** port 8080 (or 443 behind Nginx) is open from the internet.

**Commands:**

```bash
curl -I http://<jenkins-url>/github-webhook/           # should answer (not timeout)
sudo tail -f /var/log/jenkins/jenkins.log              # look for the webhook request
sudo ss -tulnp | grep 8080                             # is Jenkins listening?
```

For a local lab, a tunnel tool (like ngrok) can give GitHub a public URL to your Jenkins.

---

# 4. Agents and scaling

## Q22. How do you add a new agent (node) to Jenkins?

**Say:** There are two main ways. With an **SSH agent**, the controller connects to the agent machine over SSH. The agent needs Java, a user, and a work folder. With an **inbound agent**, the agent connects to the controller. This is good when the agent is behind a firewall. I give each agent **labels**, so jobs can select it.

**SSH agent steps:**

```bash
# on the agent machine
sudo apt install -y openjdk-17-jre git
sudo useradd -m -s /bin/bash jenkins
sudo mkdir -p /home/jenkins/agent && sudo chown jenkins:jenkins /home/jenkins/agent
# add the controller's public key to /home/jenkins/.ssh/authorized_keys
```

In Jenkins: Manage Jenkins → Nodes → New Node → Permanent Agent → set Remote root directory (`/home/jenkins/agent`), Labels (`linux docker`), Launch method **Launch agents via SSH** → add the SSH credential → Save.

**Inbound agent (runs on the agent machine):**

```bash
java -jar agent.jar -url http://jenkins:8080/ -secret <secret> -name agent1 \
     -webSocket -workDir /home/jenkins/agent
```

---

## Q23. What are dynamic agents with Docker or Kubernetes?

**Say:** Instead of keeping many agents running all the time, Jenkins can create a **fresh agent for each build** and delete it after. With the **Kubernetes plugin**, Jenkins starts a pod for the build. With the **Docker plugin**, it starts a container. Benefits: clean environment every time, no leftover files, and less cost because agents exist only when needed.

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: node
                image: node:20
                command: ["sleep"]
                args: ["99d"]
            '''
        }
    }
    stages {
        stage('Build') {
            steps {
                container('node') {
                    sh 'npm ci && npm test'
                }
            }
        }
    }
}
```

---

## Q24. A build is stuck in the queue: "Waiting for next available executor". What do you do?

**Say:** It means no free executor can run the job. I check three things: all executors are busy, no agent has the label the job asks for, or the agent is offline.

**Steps:**

1. Manage Jenkins → **Nodes**: are agents online? How many executors are busy?
2. Look at the job's label. Does an **online** agent have this exact label? (A typo in the label is common.)
3. Look at the queue: what does it say? It shows the reason.
4. Find long or stuck builds and stop them.

**Fixes:** add more agents or executors, fix the label, bring the agent online, use `disableConcurrentBuilds()` and timeouts, and use dynamic agents for peak times.

**Kill a stuck build (Script Console, admin only):**

```groovy
Jenkins.instance.getItemByFullName("my-job").getBuildByNumber(12).doKill()
```

---

## Q25. An agent goes offline again and again. How do you troubleshoot?

**Say:** I open the node page and read the **log**. Common reasons: the agent machine has **low disk space** (Jenkins marks a node offline when free space is below the limit), the network or SSH connection is broken, the Java version is wrong, or the machine has no memory and the agent process was killed.

**Commands (on the agent machine):**

```bash
df -h ; df -i                              # disk space and inodes
free -h                                    # memory
java -version                              # Java version compatible with the controller
sudo journalctl -u ssh -n 50               # SSH problems
dmesg -T | grep -i -E "oom|killed"         # was the agent killed for memory?
ping <controller> ; nc -zv <controller> 8080
```

**Fix:** free the disk (clean old workspaces and `docker system prune`), fix the network, and relaunch the agent from the node page. To prevent it, add a cleanup job and disk monitoring.

---

# 5. Troubleshooting scenarios

## Q26. Build fails with "permission denied while trying to connect to the Docker daemon socket". How do you fix it?

**Say:** The `jenkins` user is not allowed to use Docker. The Docker socket `/var/run/docker.sock` belongs to the `docker` group. I add `jenkins` to that group and **restart Jenkins**. The restart is needed because a running process does not read new group changes. I do **not** use `chmod 666` on the socket, because that is not safe. Also note that the docker group gives root-level power on that machine, so I use it only on trusted agents.

**Commands:**

```bash
ls -l /var/run/docker.sock                 # group is "docker"
id jenkins                                 # is "docker" in the list?
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
sudo -u jenkins docker ps                  # test as the jenkins user
```

If Jenkins runs in a container, mount `/var/run/docker.sock` and give the container user the same group ID as the host `docker` group.

---

## Q27. Jenkins is very slow or uses a lot of memory. What do you check?

**Say:** Jenkins is a Java app, so I look at the Java heap and what is running on the controller. Common causes: builds are running on the controller, too many old builds and big logs, too many plugins, a low heap size, or a slow disk.

**Commands:**

```bash
top                                        # is java using the CPU?
free -h                                    # memory
iostat -xz 1                               # slow disk?
sudo journalctl -u jenkins -n 100          # errors and GC warnings
ps -o pid,rss,cmd -C java                  # Jenkins memory use
```

**Fixes:**

- Set the heap: `sudo systemctl edit jenkins` and add `Environment="JAVA_OPTS=-Xms512m -Xmx2g"`, then restart.
- Set controller executors to 0 and run builds on agents.
- Use `buildDiscarder` to keep fewer builds and logs.
- Remove unused plugins, and use faster disks.
- Add monitoring (Q37).

---

## Q28. The Jenkins server disk is full. What do you do?

**Say:** First I find what uses the space in `/var/lib/jenkins`. Usually it is old **build history**, **workspaces**, and **artifacts**. I clean them safely and then set rules to keep them small.

**Commands:**

```bash
df -h ; df -i
sudo du -sh /var/lib/jenkins/* | sort -h | tail
sudo du -sh /var/lib/jenkins/workspace/* | sort -h | tail
sudo du -sh /var/lib/jenkins/jobs/*/builds | sort -h | tail
sudo docker system prune -f                # on agents that build Docker images (read the warning first)
```

**Fix and prevent:**

```groovy
options {
    buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '5'))
}
post { always { cleanWs() } }             // clean the workspace after each build
```

Also move artifacts to an external store (S3, Nexus, Artifactory), and if needed, extend the disk (see the LVM answer in the Linux file).

---

## Q29. Jenkins does not start after a plugin upgrade. How do you recover?

**Say:** I read the logs to find which plugin or error is the cause. Then I disable or roll back that plugin, and start Jenkins again. Jenkins keeps a `.bak` copy of the previous plugin version, so a rollback is possible.

**Commands:**

```bash
sudo systemctl status jenkins
sudo journalctl -u jenkins -n 100 --no-pager
sudo tail -100 /var/log/jenkins/jenkins.log

sudo systemctl stop jenkins
cd /var/lib/jenkins/plugins
ls -l | grep -i <plugin-name>
sudo touch <plugin-name>.jpi.disabled       # disable the plugin
# or restore the old version if <plugin-name>.jpi.bak exists:
sudo mv <plugin-name>.jpi <plugin-name>.jpi.broken
sudo mv <plugin-name>.jpi.bak <plugin-name>.jpi
sudo chown -R jenkins:jenkins /var/lib/jenkins/plugins
sudo systemctl start jenkins
```

Also check for a wrong **Java version**, because new Jenkins or plugin versions may need a newer Java.

**Prevent:** take a backup of `JENKINS_HOME` before upgrades, test in a staging Jenkins, and upgrade plugins in small groups, not all at once.

---

## Q30. You forgot the Jenkins admin password or are locked out. How do you recover?

**Say:** With server access, I turn off security for a short time by editing `config.xml`, restart Jenkins, log in without a password, set a new admin password and re-enable security. Jenkins is open to anyone while security is off, so I do this fast and only on a private network. If it is the very first login, the password is in `initialAdminPassword`.

**Commands:**

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword     # first-time password

sudo systemctl stop jenkins
sudo cp /var/lib/jenkins/config.xml /var/lib/jenkins/config.xml.bak
sudo sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/' /var/lib/jenkins/config.xml
sudo systemctl start jenkins
# open Jenkins, then: Manage Jenkins -> Security -> enable security again, and reset the user password
```

---

## Q31. The build works on my machine but fails on Jenkins. How do you debug?

**Say:** Jenkins runs the build as a different user, in a different folder, with a different `PATH` and environment. I first print the environment inside the pipeline, then I try the same commands as the `jenkins` user. The usual causes: a missing tool or dependency, a different tool version, a missing environment variable or secret, a wrong file permission, or a different OS on the agent.

```groovy
stage('Debug') {
    steps {
        sh '''
            whoami
            pwd
            echo $PATH
            which node && node -v
            env | sort
        '''
    }
}
```

**Commands:**

```bash
sudo -u jenkins -i                                          # become the jenkins user
cd /var/lib/jenkins/workspace/<job-name> && ls -la
sudo -u jenkins bash -c 'cd /var/lib/jenkins/workspace/<job-name> && npm ci'
```

**Best fix:** run the build inside a Docker container (Q15), so local and Jenkins use the same environment.

---

## Q32. Git checkout fails in Jenkins with an authentication error. What do you check?

**Say:** I check which credentials the job uses, and if they are still valid. For HTTPS, the token may be expired or without the right scope. For SSH, the private key may be wrong, or the host key is not known ("Host key verification failed").

**Commands:**

```bash
sudo -u jenkins ssh -T git@github.com                        # test SSH as the jenkins user
sudo -u jenkins git ls-remote git@github.com:USER/REPO.git   # can it read the repo?
ssh-keyscan github.com | sudo tee -a /var/lib/jenkins/.ssh/known_hosts
sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh
```

**Checklist:**

- Is the URL type (SSH or HTTPS) the same as the credential type?
- Is the `credentialsId` correct and available in this folder or job?
- Is the token expired, or the key removed from GitHub?
- Is the host key trusted? (Manage Jenkins → Security → Git Host Key Verification Configuration.)
- Is there a proxy or firewall blocking port 22 or 443?

---

## Q33. Pipeline fails with "No such DSL method" or a syntax error. What do you do?

**Say:** "No such DSL method" usually means the **plugin** for that step is not installed, or the step name is wrong. A syntax error is often a Groovy or declarative structure mistake. I use the **Pipeline Syntax snippet generator** to get the correct code, and I check the Jenkinsfile with the **linter** before I push.

**Commands:**

```bash
# Pipeline Syntax generator: http://<jenkins>/pipeline-syntax/
# Declarative directive generator: http://<jenkins>/directive-generator/

# Validate a Jenkinsfile from the terminal:
curl -X POST -u USER:API_TOKEN \
  -F "jenkinsfile=<Jenkinsfile" \
  http://<jenkins>/pipeline-model-converter/validate
```

Other causes: a step used in the wrong place (for example `steps` inside `steps`), a missing `script { }` block for Groovy code in declarative, or the plugin was installed but Jenkins was not restarted. Also, "Scripts not permitted to use method..." means the Groovy sandbox blocked a method. An admin can review it in Manage Jenkins → In-process Script Approval.

---

# 6. Operations: backup, upgrade, config as code, monitoring

## Q34. How do you back up and restore Jenkins?

**Say:** All Jenkins data is in `JENKINS_HOME`. I back up the config, jobs, users, plugins list, and the secrets folder (the keys are needed to read stored credentials). I skip workspaces and caches because they are big and can be rebuilt. Best practice is to also keep Jenkinsfiles in Git and use Configuration as Code (Q36), so the setup can be rebuilt fast. On AWS, I can also take EBS snapshots.

**Commands:**

```bash
# backup
sudo tar -czf /backup/jenkins-$(date +%F).tar.gz \
  --exclude='/var/lib/jenkins/workspace' \
  --exclude='/var/lib/jenkins/caches' \
  /var/lib/jenkins

# restore
sudo systemctl stop jenkins
sudo tar -xzf /backup/jenkins-2026-09-19.tar.gz -C /
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo systemctl start jenkins
```

The `ThinBackup` plugin can also make scheduled backups. Always **test a restore** at least once.

---

## Q35. How do you upgrade Jenkins safely?

**Say:** I use the **LTS** (long-term support) version in production. Before I upgrade I read the release notes and check Java and plugin compatibility. I take a backup, test the upgrade in a staging Jenkins, and then do it in a maintenance window. I update the core first, then plugins in small groups. Before restart, I use **Prepare for Shutdown**, so running builds can finish.

**Commands:**

```bash
sudo tar -czf /backup/jenkins-before-upgrade.tar.gz --exclude='/var/lib/jenkins/workspace' /var/lib/jenkins
sudo apt update
sudo apt install --only-upgrade jenkins
sudo systemctl restart jenkins
sudo journalctl -u jenkins -n 50 --no-pager      # check for errors
```

**After upgrade:** check that the jobs, agents, and credentials work, and run a test pipeline. Keep the old package version so that you can roll back if needed.

---

## Q36. What is Jenkins Configuration as Code (JCasC)?

**Say:** JCasC lets me define Jenkins settings (security, agents, credentials, tools) in a **YAML file** instead of clicking in the UI. It goes in Git, so the setup is repeatable, reviewed, and easy to rebuild after a failure. I use it with the Job DSL plugin and a `plugins.txt` file to build a full Jenkins from code, often in a Docker image.

`jenkins.yaml`

```yaml
jenkins:
  systemMessage: "Managed by Configuration as Code"
  numExecutors: 0
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "admin"
          password: "${ADMIN_PASSWORD}"
```

**Commands:**

```bash
# tell Jenkins where the file is (set as an environment variable)
export CASC_JENKINS_CONFIG=/var/jenkins_home/jenkins.yaml

# install plugins from a list in a custom image
jenkins-plugin-cli --plugin-file plugins.txt
```

The password comes from an environment variable, so it is not written in the file.

---

## Q37. How do you monitor Jenkins?

**Say:** I watch the **health of the server** (CPU, memory, disk), the **health of Jenkins itself** (queue length, executor use, build failures and time), and I set alerts. I use the **Prometheus metrics plugin** to expose metrics, Grafana for dashboards, and Alertmanager (or Slack and email) for alerts. I also watch the Jenkins log for errors.

**Commands:**

```bash
curl http://<jenkins>:8080/prometheus/           # metrics (needs the Prometheus Metrics plugin)
curl -u USER:API_TOKEN http://<jenkins>:8080/queue/api/json?pretty=true    # build queue
sudo journalctl -u jenkins -f                    # live logs
df -h /var/lib/jenkins                           # disk
```

**Good alerts:** the disk is over 80%, the queue waits too long, no agent is online, the job failure rate is high, and Jenkins is down (health check).

---

# 7. Security

## Q38. How do you secure a Jenkins server?

**Say:** I follow least privilege and keep everything updated. My checklist:

1. **Turn on security.** No anonymous access. Use SSO, LDAP, or GitHub OAuth for login.
2. **Role-based access.** Use *Role-based Authorization Strategy* or *Matrix Authorization*. Developers get build and read access. Only admins can configure.
3. **Do not run builds on the controller.** Set controller executors to 0.
4. **Store secrets in Jenkins Credentials.** Never in the Jenkinsfile or the code.
5. **Keep Jenkins and plugins updated.** Old plugins are the most common way that Jenkins gets attacked. Remove plugins that are not used.
6. **Use HTTPS.** Put Jenkins behind Nginx or a load balancer with a certificate. Close port 8080 to the internet.
7. **Keep CSRF protection on** and use the **Groovy sandbox** with script approval.
8. **Protect the Jenkinsfile.** Use PR review, so nobody can add a bad step alone.
9. **Audit and backup.** Use the Audit Trail plugin, and take regular backups.
10. **Use separate credentials** for dev, staging, and prod, with limited scope.

**Commands:**

```bash
sudo ss -tulnp | grep -E "8080|443"              # what is exposed?
sudo ufw status                                  # allow only needed ports
# Example: Nginx reverse proxy with a certificate (Let's Encrypt)
sudo apt install -y nginx certbot python3-certbot-nginx
sudo certbot --nginx -d jenkins.example.com
```

---

## Q39. A secret appears in the build log. How do you prevent it?

**Say:** Jenkins masks secrets that come from `withCredentials`, but masking can fail. It fails if the secret is changed (for example, base64 encoded) or printed in another form, and it fails if I use **double quotes** in `sh`, because Groovy puts the secret value into the command text and it can show up in logs. So I use single quotes, I never `echo` secrets, and I avoid `set -x` around secret commands. If a secret was leaked in a log, I **rotate it at once** and delete that build log.

**Bad:**

```groovy
sh "curl -H 'Authorization: Bearer ${API_TOKEN}' https://api.example.com"   // Groovy puts the secret in the text
```

**Good:**

```groovy
withCredentials([string(credentialsId: 'api-token', variable: 'API_TOKEN')]) {
    sh 'curl -s -H "Authorization: Bearer $API_TOKEN" https://api.example.com'
}
```

Other good habits: use short-lived tokens, use least-privilege credentials, and use the Mask Passwords or credentials binding features.

---

# 8. CI/CD design

## Q40. Design a full CI/CD pipeline for a Node.js app that deploys to an EC2 server with Docker.

**Say:** My pipeline has these stages: checkout, install, lint and test (in parallel), code quality (SonarQube), Docker build, image scan (Trivy), push to the registry, deploy to EC2 over SSH, a smoke test, and a notification. I tag images with the build number, so I can roll back. Production deploy has a manual approval.

```groovy
pipeline {
    agent any
    environment {
        IMAGE   = 'your-dockerhub-user/myapp'
        TAG     = "${env.BUILD_NUMBER}"
        EC2_HOST = 'ubuntu@10.0.1.25'
    }
    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
    }
    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Install') { steps { sh 'npm ci' } }

        stage('Lint and Test') {
            failFast true
            parallel {
                stage('Lint') { steps { sh 'npm run lint' } }
                stage('Test') { steps { sh 'npm test' } }
            }
        }

        stage('Docker Build') {
            steps { sh 'docker build -t $IMAGE:$TAG .' }
        }

        stage('Scan Image') {
            steps { sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL $IMAGE:$TAG' }
        }

        stage('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                  usernameVariable: 'U', passwordVariable: 'P')]) {
                    sh '''
                        echo "$P" | docker login -u "$U" --password-stdin
                        docker push $IMAGE:$TAG
                    '''
                }
            }
        }

        stage('Approval') {
            when { branch 'main' }
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    input message: 'Deploy to production?', ok: 'Deploy'
                }
            }
        }

        stage('Deploy') {
            when { branch 'main' }
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=accept-new $EC2_HOST "
                          docker pull $IMAGE:$TAG &&
                          docker rm -f myapp || true &&
                          docker run -d --name myapp --restart unless-stopped -p 80:3000 $IMAGE:$TAG
                        "
                    '''
                }
            }
        }

        stage('Smoke Test') {
            when { branch 'main' }
            steps { sh 'curl -f http://10.0.1.25/health' }
        }
    }
    post {
        failure { echo "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}" }
        always  { sh 'docker logout || true' }
    }
}
```

The `sshagent` step needs the SSH Agent plugin and an SSH credential (`ec2-ssh-key`).

---

## Q41. How do you deploy to Kubernetes from Jenkins?

**Say:** After the image is pushed, Jenkins updates the Deployment to the new image tag with `kubectl set image` and waits with `rollout status`. If the rollout does not finish in time, the step fails and I roll back with `rollout undo`. The kubeconfig is stored in Jenkins as a **secret file** credential. For bigger teams, I prefer GitOps (Jenkins updates the image tag in a Git repo and ArgoCD deploys it).

```groovy
stage('Deploy to Kubernetes') {
    steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
            sh '''
                kubectl set image deployment/myapp myapp=$IMAGE:$TAG -n production
                kubectl rollout status deployment/myapp -n production --timeout=120s
            '''
        }
    }
}
```

```groovy
post {
    failure {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
            sh 'kubectl rollout undo deployment/myapp -n production'
        }
    }
}
```

**Commands:**

```bash
kubectl rollout history deployment/myapp -n production
kubectl rollout undo deployment/myapp -n production --to-revision=3
```

---

## Q42. What is your rollback strategy in Jenkins?

**Say:** The key is to deploy **versioned images** (build number or Git SHA), never only `latest`. Then a rollback means deploying the older version again. I keep a separate **rollback job** with a `VERSION` parameter, so anyone with permission can go back fast. For Kubernetes, I use `kubectl rollout undo`. I also run a **smoke test** after each deploy, and if it fails I can start the rollback automatically.

```groovy
pipeline {
    agent any
    parameters {
        string(name: 'VERSION', description: 'Image tag to deploy, for example 42')
    }
    stages {
        stage('Rollback') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh '''
                        ssh ubuntu@10.0.1.25 "
                          docker pull your-dockerhub-user/myapp:$VERSION &&
                          docker rm -f myapp || true &&
                          docker run -d --name myapp --restart unless-stopped -p 80:3000 your-dockerhub-user/myapp:$VERSION
                        "
                    '''
                }
            }
        }
    }
}
```

Other strategies to mention: **blue/green** (two environments, switch traffic) and **canary** (send a small part of traffic first).

---

## Q43. How do you add code quality checks (SonarQube) and image scanning (Trivy) to the pipeline?

**Say:** For code quality I run the SonarQube scanner, and then I use `waitForQualityGate`, which stops the pipeline if the quality gate fails. For security of the image, I run **Trivy** and fail the build on HIGH or CRITICAL findings. This is called shift-left security: problems are found early, before they reach production.

```groovy
stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('sonarqube') {
            sh 'sonar-scanner -Dsonar.projectKey=myapp -Dsonar.sources=.'
        }
    }
}
stage('Quality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}
stage('Image Scan') {
    steps {
        sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL $IMAGE:$TAG'
    }
}
```

The `sonarqube` name is set in Manage Jenkins → System → SonarQube servers. A webhook from SonarQube to Jenkins is needed for `waitForQualityGate`.

---

## Q44. How do you make Jenkins builds faster?

**Say:** I look for what is slow, and then I fix it. My ideas: run independent stages in **parallel**, **cache** dependencies (npm, Maven, Docker layers), use a **shallow clone**, run only the needed stages with `when` and `changeset`, use more or better **agents**, use small Docker base images, stop old builds with `disableConcurrentBuilds`, and clean workspaces so they do not grow. I also write the Dockerfile so that dependency install is before copying source code, so Docker cache works.

```groovy
options {
    skipDefaultCheckout(true)              // do my own lighter checkout
    disableConcurrentBuilds()
    timeout(time: 20, unit: 'MINUTES')
}
stages {
    stage('Checkout') {
        steps {
            checkout([$class: 'GitSCM',
                branches: [[name: '*/main']],
                extensions: [[$class: 'CloneOption', depth: 1, shallow: true, noTags: true]],
                userRemoteConfigs: [[url: 'https://github.com/USER/REPO.git', credentialsId: 'github-creds']]])
        }
    }
    stage('Frontend tests') {
        when { changeset "frontend/**" }   // run only if frontend files changed
        steps { sh 'npm run test:frontend' }
    }
}
```

**Dockerfile order for cache:**

```dockerfile
COPY package*.json ./
RUN npm ci
COPY . .
```

---

## Q45. Jenkins or GitHub Actions: how do you choose?

**Say:** **Jenkins** is self-hosted, has a very large plugin list, and gives full control. It is good for complex pipelines, private networks, and company rules. The cost is that I must maintain the server, plugins, updates, and security. **GitHub Actions** has no server to manage, it is tightly connected to GitHub, and the YAML is simple. It is faster to start, but it is tied to GitHub, and heavy or private-network jobs need self-hosted runners. My choice: for a new project on GitHub with simple needs I choose Actions. For companies with existing Jenkins, on-prem servers, or complex workflows, I use Jenkins. I can also use both: Actions for CI and Jenkins for deployment inside a private network.

| | Jenkins | GitHub Actions |
|---|---|---|
| Hosting | Self-hosted (you maintain it) | Hosted by GitHub (runners can be self-hosted) |
| Config | Jenkinsfile (Groovy) | YAML workflow files |
| Plugins | Very large, but needs updates and care | Marketplace of actions |
| Best for | Complex flows, private networks, on-prem | Fast setup, GitHub projects |
| Cost | Server and admin time | Free minutes, then pay |

---

# Quick practice ideas for `~/linuxCMD/jenkins-lab`

1. Start Jenkins in Docker (top of this file), install the suggested plugins, and create the admin user.
2. Create a **Pipeline** job with a simple Jenkinsfile (Q7) with stages: checkout, build, test. Run it and read the console log.
3. Add parameters (Q9), parallel stages (Q10), and a manual approval (Q11). Watch how each looks in the UI.
4. Create a Docker Hub credential (Q13) and run the build-and-push pipeline (Q14).
5. Break things on purpose: remove the `jenkins` user from the `docker` group (Q26), use a wrong label (Q24), or fill the workspace (Q28). Then fix each one.
6. Set up a GitHub webhook with a tunnel (Q20) and push a commit to see the build start by itself.

**Final tip for the interview:** for every scenario say the same order: **look at the logs first, find the cause, fix it, and then say how you prevent it** (monitoring, cleanup, backup, or automation).
