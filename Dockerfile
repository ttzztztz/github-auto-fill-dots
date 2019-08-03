FROM gcc:latest

ARG GIT_USERNAME
ENV GIT_USERNAME $GIT_USERNAME

ARG GIT_EMAIL
ENV GIT_EMAIL $GIT_EMAIL

ARG GIT_REPO
ENV GIT_REPO $GIT_REPO

# make it quiet
RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# init
RUN mkdir -p /home/app && mkdir -p /home/repo && mkdir -p /home/faketime
RUN git config --global user.name "$GIT_USERNAME" && git config --global user.email "$GIT_EMAIL"

# build app
WORKDIR /home/app
COPY . .

# copy key
RUN mkdir -p ~/.ssh && cp /home/app/id_rsa ~/.ssh/id_rsa && cp /home/app/id_rsa.pub ~/.ssh/id_rsa.pub
RUN chmod 0600 ~/.ssh/id_rsa.pub && chmod 0600 ~/.ssh/id_rsa
RUN rm /home/app/id_rsa.pub && rm /home/app/id_rsa

# build main program
RUN g++ /home/app/main.cpp -o /home/app/main.o && chmod +x /home/app/main.o
RUN git clone "$GIT_REPO" /home/repo

# build fake time so
RUN git clone https://github.com/wolfcw/libfaketime.git /home/faketime
RUN cd /home/faketime && make install

# echo info
RUN echo "Please add this public key to your github account !" && cat ~/.ssh/id_rsa.pub

# run
CMD ["/home/app/main.o"]