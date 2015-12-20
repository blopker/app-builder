#!/usr/bin/env bash
set -eo pipefail

install_docker_repo () {
	rm -f /etc/yum.repos.d/docker.repo
	cat >/etc/yum.repos.d/docker.repo <<-EOF
	[dockerrepo]
	name=Docker Repository
	baseurl=https://yum.dockerproject.org/repo/main/centos/7
	enabled=1
	gpgcheck=1
	gpgkey=https://yum.dockerproject.org/gpg
	EOF
}

install_packages () {
	yum install -y epel-release deltarpm
	yum update -y

	# For Jenkins
	yum install -y java git

	# Docker
	# yum install -y docker-engine

	# Compile Pythons
	yum groupinstall -y "Development Tools"
	yum install -y zlib-dev openssl-devel sqlite-devel bzip2-devel

	yum clean all -y
}

start_services () {
	systemctl enable docker
	systemctl start docker
}

install_python () {
	echo "Building Python..."

	VERSION=$1
	OUT_PREFIX="/pythons/$VERSION/"

	if [ -f "$OUT_PREFIX/bin/python" ]; then
	    echo "Python $VERSION already installed"
	    return
	fi

	mkdir -p $OUT_PREFIX
	cd "$OUT_PREFIX"
	SOURCE_TARBALL="https://python.org/ftp/python/$VERSION/Python-$VERSION.tgz"
	curl -L $SOURCE_TARBALL | tar xz
	mv "Python-$VERSION" src
	cd src

	./configure --prefix=$OUT_PREFIX --with-ensurepip=no
	make
	make install

	ln "$OUT_PREFIX/bin/python3" "$OUT_PREFIX/bin/python"
	ln "$OUT_PREFIX/bin/python3" "/usr/bin/python$VERSION"

	echo "Python $VERSION installed"
}

# install_docker_repo
install_packages
install_python 3.5.1
# start_services
