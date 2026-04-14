FROM almalinux:9-minimal

RUN microdnf install -y \
      https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm && \
    microdnf install -y cvmfs fuse environment-modules && \
    microdnf clean all

COPY cvmfs-ship.conf /etc/cvmfs/default.d/ship.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN useradd -m -u 1000 shipuser
USER shipuser

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
