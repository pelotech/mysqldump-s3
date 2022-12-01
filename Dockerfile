FROM amazon/aws-cli:2.9.3

LABEL maintainer = "Joachim Hill-Grannec <joachim@pelo.tech>"
RUN yum install -y mysql

COPY entrypoint.sh /
COPY action.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/action.sh"]