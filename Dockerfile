FROM danysk/docker-manjaro-texlive-ruby:11.20211227.1000
COPY entrypoint.rb entrypoint.rb
RUN ruby -c entrypoint.rb
RUN chmod +x entrypoint.rb
ENTRYPOINT [ "/entrypoint.rb" ]
