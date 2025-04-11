FROM ubuntu:20.04

RUN ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime && \
  echo "Europe/Moscow" > /etc/timezone 

ENV PATH="/usr/local/mbdyn/bin:${PATH}"
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  git \
  libltdl-dev \
  liblapack-dev \ 
  libsuitesparse-dev \
  libnetcdf-dev \
  libnetcdf-c++4-dev\
  autoconf \
  automake \
  libtool \
  libtool-bin \
  autotools-dev \
  mercurial \
  libsuitesparse-dev \
  libarpack2-dev \
  libmumps-seq-dev \
  libmetis-dev \
  libnlopt-dev \
  trilinos-all-dev \
  libopenmpi-dev \
  libptscotch-dev \
  libsuitesparse-dev \
  libqrupdate-dev \
  gcc \
  g++ \
  libopenmpi-dev \
  libnlopt-dev \
  libhdf5-dev \
  libginac-dev \
  libatomic-ops-dev \
  libnetcdf-c++4-dev \
  cmake &&\  
  rm -rf /var/lib/apt/lists/*

RUN update-ca-certificates


# install MBDyn 
RUN echo "=================> DOWNLOAD MBDYN <================="
RUN git clone https://public.gitlab.polimi.it/DAER/mbdyn.git /home/mbdyn 

WORKDIR /home/mbdyn
RUN echo "====================> BOOTSTRAP <==================="
RUN sh bootstrap.sh
RUN echo "====================> CONFIGURE <==================="
RUN ./configure --with-static-modules \
--disable-Werror CXXFLAGS="-Ofast -Wall -march=native -mtune=native" \
CPPFLAGS="-I/usr/include/mkl -I/usr/lib/x86_64-linux-gnu/openmpi/include -I/usr/lib/x86_64-linux-gnu/openmpi/include/openmpi/ompi/mpi/cxx -I/usr/include/trilinos -I/usr/include/suitesparse" \
LDFLAGS="-L/usr/lib/x86_64-linux-gnu/hdf5/openmpi" \
--with-arpack --with-umfpack --with-klu --with-arpack --with-lapack --without-metis --with-mpi --with-trilinos --with-pardiso --with-suitesparseqr --with-qrupdate --enable-multithread --with-threads --with-rt \
--enable-runtime-loading 

RUN echo "====================> MAKE -j20 <==================="
RUN make -j20

RUN echo "=====================> INSTALL <===================="
RUN make install



CMD ["bash"]
