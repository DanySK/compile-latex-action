FROM danysk/docker-manjaro-texlive-base:29.20211114.1227
COPY entrypoint.rb entrypoint.rb
RUN ruby -c entrypoint.rb
RUN chmod +x entrypoint.rb
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
