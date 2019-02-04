#!/usr/bin/env groovy
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

// set up pod label and GOOGLE_APPLICATION_CREDENTIALS (for Terraform)
def label = "k8s-infra"
def containerName = "k8s-node"
def GOOGLE_APPLICATION_CREDENTIALS    = '/home/jenkins/dev/jenkins-deploy-dev-infra.json'

podTemplate(label: label, yaml: """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: build-node
spec:
  containers:
  - name: ${containerName}
    image: gcr.io/pso-helmsman-cicd/jenkins-k8s-node:${env.CONTAINER_VERSION}
    command: ['cat']
    tty: true
    volumeMounts:
    # Mount the dev service account key
    - name: dev-key
      mountPath: /home/jenkins/dev
    resources:
      limits:
        cpu: 2
        memory: 2Gi
      requests:
        cpu: 1
        memory: 1Gi
  volumes:
  # Create a volume that contains the dev json key that was saved as a secret
  - name: dev-key
    secret:
      secretName: jenkins-deploy-dev-infra
"""
 ) {
 node(label) {
  try {
    // Options covers all other job properties or wrapper functions that apply to entire Pipeline.
    properties([disableConcurrentBuilds()])
    // set env variable GOOGLE_APPLICATION_CREDENTIALS for Terraform
    env.GOOGLE_APPLICATION_CREDENTIALS=GOOGLE_APPLICATION_CREDENTIALS

    stage('Setup') {
        container(containerName) {
          // checkout code from scm i.e. commits related to the PR
          checkout scm

          // Setup gcloud service account access
          sh "gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}"
          sh "gcloud config set compute/zone ${env.ZONE}"
          sh "gcloud config set core/project ${env.PROJECT_ID}"
          sh "gcloud config set compute/region ${env.REGION}"
         }
    }
    stage('Lint') {
        container(containerName) {
          sh "make lint"
      }
    }

    stage('Create') {
        container(containerName) {
          sh "make create"
        }
    }

    stage('Validate') {
        container(containerName) {
          sh "make validate"
        }
    }

  }
   catch (err) {
      // if any exception occurs, mark the build as failed
      // and display a detailed message on the Jenkins console output
      currentBuild.result = 'FAILURE'
      echo "FAILURE caught echo ${err}"
      throw err
   }
   finally {
     stage('Teardown') {
      container(containerName) {
        sh "make teardown"
        sh "gcloud auth revoke"
      }
     }
   }
  }
}
