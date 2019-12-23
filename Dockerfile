FROM centos:centos7 AS builder
LABEL maintainer "Abdelrahman Hosny <abdelrahman_hosny@brown.edu>"

# Install Development Environment
RUN yum group install -y "Development Tools"
RUN yum install -y wget git
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-8 devtoolset-8-libatomic-devel
RUN wget https://cmake.org/files/v3.14/cmake-3.14.0-Linux-x86_64.sh && \
    chmod +x cmake-3.14.0-Linux-x86_64.sh  && \
    ./cmake-3.14.0-Linux-x86_64.sh --skip-license --prefix=/usr/local

# Install epel repo
RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y epel-release-latest-7.noarch.rpm

# Install dev and runtime dependencies
RUN yum install -y tcl-devel tk-devel swig qt3-devel itcl-devel tcl tk ksh libstdc++ qt3 \
    itcl iwidgets blt tcllib bwidget

# Install python dev
RUN yum install -y https://centos7.iuscommunity.org/ius-release.rpm && \
    yum update -y && \
    yum install -y python36u python36u-libs python36u-devel python36u-pip
 
RUN pip3 install --user numpy scipy matplotlib tensorflow pandas pytest

COPY . /OpeNPDN
RUN mkdir OpeNPDN/build

WORKDIR /OpeNPDN/build
RUN cmake ..
RUN make

FROM centos:centos6 AS runner

RUN yum update -y && yum install -y tcl-devel

RUN mkdir /build
COPY  --from=builder /OpeNPDN/build /build/

RUN useradd -ms /bin/bash openroad
USER openroad
WORKDIR /home/openroad




