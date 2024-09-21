FROM registry.access.redhat.com/ubi9/ubi-init:9.4-14.1725850204

ENV RUNIT='MotionPro_Linux_RedHat_x64_build-8383-30.sh'

COPY entrypoint.sh /
COPY $RUNIT /

RUN dnf install -y iproute openssh-clients && \
    chmod +x $RUNIT && \
    ./$RUNIT && \
    rm $RUNIT

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "--help" ]
