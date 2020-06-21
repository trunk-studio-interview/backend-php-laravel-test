pipeline {
  agent {
    label "jenkins-nodejs"
  }
  environment {
    ORG = 'trunk-studio-interview'
    APP_NAME = 'php-laravel'
    CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    DB_HOST="jx-mysql"
  }
  stages {
    stage('CI Build and push snapshot') {
      when {
        anyOf {
          branch 'PR-*'
          branch 'develop'
        }
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container('nodejs') {

          sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          dir('./charts/preview') {
            sh "make preview"
            sh "jx preview --app $APP_NAME --dir ../.."
          }
        }
      }
    }
    stage('test') {
      agent {
        label "jenkins-php"
      }      
      when {
        anyOf {
          branch 'staging'
          branch 'staging-*'
        }
      }
      steps {
        container('php') {
          sh "COMPOSER_MEMORY_LIMIT=-1 composer install"
          sh "make run-test"
          junit 'results/phpunit/junit.xml'
        }        
      }
    } 

    stage('Build Release') {
      when {
        anyOf {
          branch 'interview-*'
        }
      }
      steps {
        container('nodejs') {

          // ensure we're not on a detached head
          sh "git checkout $BRANCH_NAME"
          sh "git config --global credential.helper store"
          sh "jx step git credentials"

          // so we can retrieve the version in later steps
          sh "echo \$(jx-release-version) > VERSION"
          sh "jx step tag --version \$(cat VERSION)"
          sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml"
          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
        }
      }
    }
    stage('Promote to Environments') {
      when {
        anyOf {
          branch 'interview-*'
        }
      }
      steps {
        container('nodejs') {
          dir('./charts/php-laravel') {
            sh "jx step changelog --version v\$(cat ../../VERSION)"

            // release the helm chart
            sh "jx step helm release"

            // promote through all 'Auto' promotion Environments
            sh "jx promote -b --env interview --timeout 1h --version \$(cat ../../VERSION) --no-wait=true --no-poll=true"
          }
        }
      }
    }
  }
  post {
        always {
          cleanWs()
        }
  }
}
