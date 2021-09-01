FROM danysk/docker-manjaro-with-zsh:24.20210831.1635
RUN yay-install\
    texlive-core\
    rubber\
    minted\
    tectonic-bin\
    ruby
RUN ruby -pi -e "gsub('\$Master = \"\$Master/../..\"', '\$Master = \"\${Master}/../../..\"')" "/usr/share/texmf-dist/scripts/texlive/tlmgr.pl"
RUN echo -e '#!/bin/sh\n/usr/share/texmf-dist/scripts/texlive/tlmgr.pl --usermode "$@"' > /usr/bin/tlmgr
RUN chmod +x /usr/bin/tlmgr
RUN tlmgr init-usertree
RUN tlmgr option repository https://mirror.ctan.org/systems/texlive/tlnet
COPY entrypoint.rb entrypoint.rb
RUN chmod +x entrypoint.rb
ENTRYPOINT [ "/entrypoint.rb" ]
