# Use a imagem base do Jenkins
FROM jenkins/jenkins:lts

# Instale o Ansible
USER root
RUN apt-get update && \
    apt-get install -y ansible vim

RUN chown -R jenkins:jenkins /var/jenkins_home/

# Recrie a imagem base do Jenkins
USER jenkins

# Copie o playbook e outros arquivos necessários para o Jenkins
COPY ansible/. /var/ansible/.

# Defina o usuário do Jenkins
USER jenkins


# Defina a entrada padrão como Jenkins
ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
