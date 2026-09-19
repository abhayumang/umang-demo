// Job: umang-build  -> code change par WAR build karke MinIO me publish, phir rollout job trigger.
pipeline {
    agent any

    options { timestamps() }

    // Demo me GitHub webhook ki jagah har minute repo poll (localhost par webhook nahi aa sakta)
    triggers { pollSCM('* * * * *') }

    environment {
        VERSION = "1.0.${BUILD_NUMBER}"
    }

    stages {
        stage('Build WAR') {
            steps {
                sh "mvn -B -f app/pom.xml clean package -Dapp.version=${VERSION}"
            }
        }

        stage('Publish to MinIO') {
            steps {
                sh "bash scripts/publish_war.sh ${VERSION} app/target/umang.war"
            }
        }

        stage('Start rollout') {
            steps {
                build job: 'umang-rollout',
                      parameters: [string(name: 'VERSION', value: env.VERSION)],
                      wait: false
            }
        }
    }
}
