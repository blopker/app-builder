FROM centos:7

RUN yum update -y \
	&& yum groupinstall -y 'Development Tools' \
	&& yum install -y \
		python-pip \
	&& yum clean
RUN pip install --upgrade virtualenv
