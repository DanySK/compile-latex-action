FROM danysk/docker-manjaro-texlive-ruby:15.0.133
COPY entrypoint.rb entrypoint.rb
RUN ruby -c entrypoint.rb
RUN chmod +x entrypoint.rb
ENTRYPOINT [ "/entrypoint.rb" ]
