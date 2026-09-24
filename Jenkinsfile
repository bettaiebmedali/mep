pipeline {

    agent any

    environment {
        APP_NAME = 'demo-app'
    }

    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {

        stage('Informations') {
            steps {
                script {

                    echo """
============================================================
🚀 PIPELINE JENKINS
============================================================
Job        : ${env.JOB_NAME}
Build      : #${env.BUILD_NUMBER}
Branche    : ${env.BRANCH_NAME ?: 'N/A'}
Tag        : ${env.TAG_NAME ?: 'N/A'}
============================================================
"""
                }
            }
        }


        stage('Build') {
            when {
                expression {
                    env.BRANCH_NAME?.startsWith('feature/') ||
                    env.BRANCH_NAME == 'develop'
                }
            }

            steps {
                echo "🔨 BUILD"

                sh '''
                    echo "Compilation..."
                    sleep 3
                    echo "✅ Build OK"
                '''
            }
        }


        stage('Tests') {
            when {
                expression {
                    env.BRANCH_NAME?.startsWith('feature/') ||
                    env.BRANCH_NAME == 'develop'
                }
            }

            parallel {

                stage('Tests unitaires') {
                    steps {
                        sh '''
                            echo "🧪 Tests unitaires..."
                            sleep 2
                            echo "✅ Tests unitaires OK"
                        '''
                    }
                }

                stage('Tests intégration') {
                    when {
                        branch 'develop'
                    }

                    steps {
                        sh '''
                            echo "🔗 Tests intégration..."
                            sleep 3
                            echo "✅ Tests intégration OK"
                        '''
                    }
                }
            }
        }


        stage('Qualité') {
            when {
                branch 'develop'
            }

            steps {
                sh '''
                    echo "📊 Analyse qualité..."
                    sleep 2
                    echo "✅ Quality Gate OK"
                '''
            }
        }


        stage('Sécurité') {
            when {
                branch 'develop'
            }

            steps {
                sh '''
                    echo "🔐 Analyse sécurité..."
                    sleep 2
                    echo "✅ Security Check OK"
                '''
            }
        }


        stage('Docker Build') {
            when {
                branch 'develop'
            }

            steps {
                script {

                    env.VERSION = "1.0.${env.BUILD_NUMBER}"
                    env.IMAGE = "${env.APP_NAME}:${env.VERSION}"

                    echo """
🐳 BUILD DOCKER

Image :
${env.IMAGE}
"""

                    sh '''
                        echo "docker build -t ${IMAGE} ."

                        sleep 3

                        echo "✅ Image Docker construite"
                    '''
                }
            }
        }


        stage('Deploy STAGING') {
            when {
                branch 'develop'
            }

            steps {

                echo "🚀 Déploiement STAGING"

                sh '''
                    echo "Image déployée : ${IMAGE}"

                    sleep 3

                    echo "✅ STAGING disponible"
                '''
            }
        }


        stage('Smoke Test STAGING') {
            when {
                branch 'develop'
            }

            steps {

                sh '''
                    echo "💨 Smoke test..."

                    sleep 2

                    echo "HTTP 200 OK"
                    echo "✅ STAGING validée"
                '''
            }
        }


        stage('Validation Release') {
            when {
                branch 'develop'
            }

            steps {

                input(
                    message: 'STAGING validée : créer la release ?',
                    ok: 'CRÉER LA RELEASE'
                )
            }
        }


        stage('Créer TAG') {
            when {
                branch 'develop'
            }

            steps {

                script {

                    env.RELEASE_TAG = "v${env.VERSION}"

                    echo """
🏷️ TAG DE RELEASE

${env.RELEASE_TAG}
"""
                }

                sh '''
                    echo "Création du tag ${RELEASE_TAG}"

                    # Dans le vrai projet :
                    # git tag ${RELEASE_TAG}
                    # git push origin ${RELEASE_TAG}

                    echo "✅ TAG créé"
                '''
            }
        }


        stage('MEP PRODUCTION') {
            when {
                buildingTag()
            }

            steps {

                script {

                    def version =
                        env.TAG_NAME.replaceFirst(/^v/, '')

                    env.RELEASE_IMAGE =
                        "${env.APP_NAME}:${version}"

                    echo """
============================================================
🚀 MISE EN PRODUCTION
============================================================

TAG   : ${env.TAG_NAME}
IMAGE : ${env.RELEASE_IMAGE}

⚠️ AUCUN REBUILD
⚠️ AUCUNE COMPILATION

On utilise exactement l'artefact
validé en STAGING.

============================================================
"""
                }

                input(
                    message: "Déployer ${env.RELEASE_IMAGE} en PRODUCTION ?",
                    ok: 'MEP'
                )

                sh '''
                    echo "🚀 Déploiement PRODUCTION"
                    echo "Image : ${RELEASE_IMAGE}"

                    sleep 4

                    echo "✅ MEP terminée"
                '''
            }
        }


        stage('Smoke Test PRODUCTION') {
            when {
                buildingTag()
            }

            steps {

                sh '''
                    echo "💨 Smoke test PRODUCTION..."

                    sleep 2

                    echo "HTTP 200 OK"
                    echo "✅ PRODUCTION OK"
                '''
            }
        }
    }


    post {

        success {
            echo """
============================================================
🎉 PIPELINE TERMINÉ AVEC SUCCÈS
============================================================
"""
        }

        failure {
            echo """
============================================================
❌ PIPELINE EN ÉCHEC
============================================================
"""
        }

        always {
            echo "📋 Fin du pipeline."
        }
    }
}