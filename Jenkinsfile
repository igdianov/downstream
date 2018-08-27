pipeline {
    agent {
      label "jenkins-maven"
    }
    environment {
      ORG               = 'igdianov'
      APP_NAME          = 'downstream'
      CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    }
    stages {
      stage('CI Build and push snapshot') {
        when {
          branch 'PR-*'
        }
        environment {
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          container('maven') {
            sh "mvn versions:set -DnewVersion=$PREVIEW_VERSION"
            sh "mvn install"
            sh 'export VERSION=$PREVIEW_VERSION' //&& skaffold build -f skaffold.yaml'


           // sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          }

          // dir ('./charts/preview') {
          //  container('maven') {
          //    sh "make preview"
          //    sh "jx preview --app $APP_NAME --dir ../.."
          //  }
          // }
        }
      }
      stage('Build Release') {
        when {
          branch 'develop'
        }
        steps {
          container('maven') {
            // ensure we're not on a detached head
            sh "git checkout develop" 
            sh "git config --global credential.helper store"

            sh "jx step git credentials"
            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
            sh "mvn versions:set -DnewVersion=\$(cat VERSION)"
             
            // Let's test before making tag in Git  
            sh 'mvn clean install'
              
            sh "make tag"
          }
          // dir ('./charts/downstream') {
          //   container('maven') {
          //     sh "make tag"
          //   }
          // }
          container('maven') {
            sh 'mvn clean deploy -DskipTests'

            sh 'export VERSION=`cat VERSION`'// && skaffold build -f skaffold.yaml'

        //    sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
          }
        }
      }
      stage('Promote to Environments') {
        when {
          branch 'develop'
        }
        steps {
          container('maven') {
            // Let's publish release notes in Github
            sh "make changelog"
          }
    //      dir ('./charts/downstream') {
    //        container('maven') {
    //          sh 'jx step changelog --version v\$(cat ../../VERSION)'

              // release the helm chart
             // sh 'jx step helm release'

              // promote through all 'Auto' promotion Environments
            //  sh 'jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)'
    //        }
    //      }
        }
      }
    }
    post {
        success {
            cleanWs()
        }
        failure {
            input """Pipeline failed. 
We will keep the build pod around to help you diagnose any failures. 

Select Proceed or Abort to terminate the build pod"""
        }
    }
  }
