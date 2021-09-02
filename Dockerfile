FROM danysk/docker-manjaro-texlive-base:6.20210902.0823
COPY entrypoint.rb entrypoint.rb
RUN ruby -c entrypoint.rb
RUN chmod +x entrypoint.rb
ENTRYPOINT [ "/entrypoint.rb" ]
