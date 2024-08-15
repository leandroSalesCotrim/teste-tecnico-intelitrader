# Teste Técnico para Intelitrader

## Tecnologias Utilizadas

<div align="center">
	<img width="60" src="https://user-images.githubusercontent.com/25181517/179090274-733373ef-3b59-4f28-9ecb-244bea700932.png" alt="Jenkins" title="Jenkins"/>
	<img width="60" src="https://user-images.githubusercontent.com/25181517/117207330-263ba280-adf4-11eb-9b97-0ac5b40bc3be.png" alt="Docker" title="Docker"/>
	<img width="60" src="https://user-images.githubusercontent.com/25181517/184146221-671413cb-b1ae-47db-a232-b37c99281516.png" alt="SonarQube" title="SonarQube"/>
	<img width="60" src="https://skillicons.dev/icons?i=ansible" alt="Ansible" title="Ansible"/>
</div>

## Objetivo

Este teste avalia a capacidade do candidato em projetar, implementar e apresentar um pipeline de integração e entrega contínua (CI/CD) completo para uma aplicação .NET Core, utilizando Jenkins, Ansible e Docker. O pipeline automatiza o processo de build, teste e deploy da aplicação em um ambiente de desenvolvimento virtualizado.

**Desafio adicional:** Adicionei o SonarQube para validação do deploy antes de executá-lo na máquina de destino.

## Como Rodar Localmente 👨‍💻

⚠️ **Pré-requisitos:** Docker e uma máquina virtual (pode ser seu WSL ou Ubuntu).

⚠️ **Nota:** Este guia não se aprofunda em como configurar Jenkins, Docker e outras ferramentas. Presume-se que você já saiba configurar itens básicos, como uma chave SSH.

### Passos:

1. **Clone o repositório:**

    ```bash
    git clone https://github.com/leandroSalesCotrim/teste-tecnico-intelitrader.git
    ```

2. **Entre na pasta raíz do projeto:**

    ```bash
    cd teste-tecnico-intelitrader
    ```

3. **Construa as imagens necessárias:**

    ```bash
    docker-compose build
    ```

4. **Inicie os containers:**

    ```bash
    docker-compose up -d
    ```

    Isso iniciará 2 containers: um para Jenkins com Ansible e outro para SonarQube.

5. **Configure o Jenkins:**

    - Instale os plugins recomendados e o plugin "SonarQube Scanner".

    - Caso não seja suficiente, instale manualmente os plugins necessários.

    <div align="center">
        <img src="https://github.com/user-attachments/assets/f6f39e6b-4ad6-47f5-a4da-5eefa5afce4b" width="30%" />
        <img src="https://github.com/user-attachments/assets/8174eba4-ca3f-4e17-8fc5-68409f8f819b" width="60%" />
    </div>

6. **Crie um job para obter scripts atualizados:**

    1. **Crie uma tarefa do tipo "Pipeline" chamada `get-updated-scripts`:**
    ![image](https://github.com/user-attachments/assets/2fa78a1e-de16-4952-b61e-07ec57380f86)

    2. **Configure a verificação periódica do SCM:**
    ![image](https://github.com/user-attachments/assets/4fff1431-bf07-4bac-bcc4-3be001d65893)

    3. **Adicione o seguinte pipeline script:**

        ```bash
        pipeline {
            agent any

            stages {
                stage('Checkout') {
                    steps {
                        git branch:'main', url:'https://github.com/leandroSalesCotrim/teste-tecnico-intelitrader.git'
                    }
                }
               
                stage('Atualizar scripts') {
                    steps {
                        script {
                            sh 'sudo mv /var/jenkins_home/workspace/get-updated-scripts/ansible/* /var/ansible/'
                        }
                    }
                }
            }

            post {
              always {
                  echo 'Pipeline finished'
              }
            }
        }
        ```

7. **Crie o job principal para build e deploy:**

    1. **Crie um novo job do tipo "Pipeline" chamado `build-dotnet-image`:**
    ![image](https://github.com/user-attachments/assets/239ee1e1-82f0-42e3-8465-e5777837e2e9)

    2. **Configure a verificação do SCM e o hook do GitHub.**

    3. **Na seção "Pipeline", selecione "Pipeline script from SCM" e configure:**

        - **URL do repositório:** `https://github.com/leandroSalesCotrim/docker-dotnet-core`
        - **Branch Specifier:** `"**/*"`
        - **Script path:** `JenkinsFile`

8. **Configure o inventário do Ansible para conexão com a máquina virtual:**

    1. Acesse o container Jenkins/Ansible e edite o inventário:

        ```bash
        docker exec -it ee9 bash
        sudo vim /var/ansible/inventory
        ```

        Exemplo de configuração:

        ```bash
        [all]
        123.45.678.910 ansible_user=ansible ansible_ssh_private_key_file=/var/jenkins_home/.ssh/id_rsa ansible_ssh_common_args='-o StrictHostKeyChecking=no'
        ```

    ⚠️ **Atenção:**
    - O inventário será atualizado toda vez que o job `get-updated-scripts` for executado, assim, retornando ao ip template do repositório.
    - O usuário precisa ter permissões adequadas para criar pastas, copiar arquivos e executar comandos Docker.

9. **Configure o token do SonarQube no Jenkins:**

    1. Acesse o SonarQube e gere um token de acesso.
    2. No Jenkins, adicione o token na aba "Credentials".

    ![image](https://github.com/user-attachments/assets/3df9bd12-8bf8-4548-a268-a7eddb9366c8)
    ![image](https://github.com/user-attachments/assets/ca052a63-c49b-4027-9980-3cc46c033687)
