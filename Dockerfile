# Use a imagem base do Jenkins
FROM jenkins/jenkins:lts

# Instale o Ansible e outras dependências
USER root
RUN apt-get update && \
    apt-get install -y ansible vim sudo wget apt-transport-https

# Adicione a chave pública da Microsoft
RUN wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add -

# Adicione o repositório da Microsoft para o .NET SDK
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/prod.list && \
    mv prod.list /etc/apt/sources.list.d/mssql-prod.list

# Atualize a lista de pacotes e instale o .NET SDK
RUN apt-get update && \
    apt-get install -y dotnet-sdk-6.0 

# Configure permissões para o Jenkins
RUN echo 'jenkins ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/jenkins
RUN chown -R jenkins:jenkins /var/jenkins_home/

# Voltar para o usuário Jenkins
USER jenkins

# Copie o playbook e outros arquivos necessários para o Jenkins
COPY ansible/. /var/ansible/.

# Defina a entrada padrão como Jenkins
ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
