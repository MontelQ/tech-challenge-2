pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
    AWS_REGION = 'us-east-1'
    ECR_REGISTRY = '394228349360.dkr.ecr.us-east-1.amazonaws.com'
    ECR_REPOSITORY_URI = '394228349360.dkr.ecr.us-east-1.amazonaws.com/tech-challenge-2'
    EKS_CLUSTER = 'tech-challenge-2'
    K8S_NAMESPACE = 'tech-challenge-2'
    HELM_RELEASE = 'tc2-app'
    HELM_CHART = 'helm/flask-app'
  }

  stages {
    stage('Set image tag') {
      steps {
        script {
          env.IMAGE_TAG = sh(
            script: 'git rev-parse --short=12 HEAD',
            returnStdout: true
          ).trim()
          echo "Image tag: ${env.IMAGE_TAG}"
        }
      }
    }

    stage('Validate Helm chart') {
      steps {
        sh '''
          set -eu
          helm lint "$HELM_CHART"
          helm template "$HELM_RELEASE" "$HELM_CHART" \
            --namespace "$K8S_NAMESPACE" \
            --set "image.repository=$ECR_REPOSITORY_URI" \
            --set-string "image.tag=$IMAGE_TAG" \
            >/dev/null
        '''
      }
    }

    stage('Build and push image') {
      steps {
        sh '''
          set -eu
          aws ecr get-login-password --region "$AWS_REGION" |
            docker login --username AWS --password-stdin "$ECR_REGISTRY"
          docker build --pull -t "$ECR_REPOSITORY_URI:$IMAGE_TAG" .
          docker push "$ECR_REPOSITORY_URI:$IMAGE_TAG"
        '''
      }
    }

    stage('Deploy to EKS') {
      steps {
        sh '''
          set -eu
          aws eks update-kubeconfig --region "$AWS_REGION" --name "$EKS_CLUSTER"
          helm upgrade --install "$HELM_RELEASE" "$HELM_CHART" \
            --namespace "$K8S_NAMESPACE" \
            --set "image.repository=$ECR_REPOSITORY_URI" \
            --set-string "image.tag=$IMAGE_TAG" \
            --wait \
            --timeout 5m
          kubectl rollout status deployment/tc2-app \
            --namespace "$K8S_NAMESPACE" \
            --timeout=300s
        '''
      }
    }
  }
}
