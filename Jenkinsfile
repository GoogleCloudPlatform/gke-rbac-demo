/*
Copyright 2018 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/

// The declarative agent is defined in yaml.  It was previously possible to
// define containerTemplate but that has been deprecated in favor of the yaml
// format
// Reference: https://github.com/jenkinsci/kubernetes-plugin
pipeline {
  agent {
    kubernetes {
      label 'k8s-infra'
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: build-node
spec:
  containers:
  - name: k8s-node
    image: gcr.io/pso-helmsman-cicd/jenkins-k8s-node:1.1.0
    imagePullPolicy: Always
    command:
    - cat
    tty: true
    volumeMounts:
    # Mount the docker.sock file so we can communicate with the local docker
    # daemon
    - name: docker-sock-volume
      mountPath: /var/run/docker.sock
    # Mount the local docker binary
    - name: docker-bin-volume
      mountPath: /usr/bin/docker
    # Mount the dev service account key
    - name: dev-key
      mountPath: /home/jenkins/dev
  volumes:
  - name: docker-sock-volume
    hostPath:
      path: /var/run/docker.sock
  - name: docker-bin-volume
    hostPath:
      path: /usr/bin/docker
  # Create a volume that contains the dev json key that was saved as a secret
  - name: dev-key
    secret:
      secretName: jenkins-deploy-dev-infra
"""
    }
  }

  environment {
    GOOGLE_APPLICATION_CREDENTIALS    = '/home/jenkins/dev/jenkins-deploy-dev-infra.json'
  }


  stages {
    stage('Lint') {
      steps {
        container('k8s-node') {
          sh "make check_shell"
        }
      }
    }

    stage('Setup') {
      steps {
        container('k8s-node') {
          script {
            env.ZONE = "${ZONE}"
            env.PROJECT_ID = "${PROJECT_ID}"
            env.REGION = "${REGION}"
            env.KEYFILE = GOOGLE_APPLICATION_CREDENTIALS
          }
          // Setup gcloud service account access
          sh "gcloud auth activate-service-account --key-file=${env.KEYFILE}"
          sh "gcloud config set compute/zone ${env.ZONE}"
          sh "gcloud config set core/project ${env.PROJECT_ID}"
          sh "gcloud config set compute/region ${env.REGION}"

         }
        }
    }

    stage('Create') {
      steps {
        container('k8s-node') {
          sh "make create"
        }
      }
    }

    stage('Validate') {
      steps {
        container('k8s-node') {
          sh "make validate"
        }
      }
    }
  }

  post {
    always {
      container('k8s-node') {
        sh "make teardown"
        sh "gcloud auth revoke"
      }
    }
  }
}
