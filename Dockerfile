FROM julia:latest

LABEL maintainer "ramenjuniti <ramenjuniti@gmail.com>"

RUN apt-get update \
    && apt-get install -y mecab \
    && apt-get install -y libmecab-dev \
    && apt-get install -y mecab-ipadic-utf8\
    && apt-get install -y git\
    && apt-get install -y make\
    && apt-get install -y curl\
    && apt-get install -y xz-utils\
    && apt-get install -y file\
    && apt-get install -y sudo\
    && apt-get install -y wget\
    && apt-get install -y g++\
    && apt-get install -y bzip2

RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git\
    && cd mecab-ipadic-neologd\
    && bin/install-mecab-ipadic-neologd -n -y\
    && cd ..\
    && rm -r mecab-ipadic-neologd\
    && echo "export DIC=$(echo `mecab-config --dicdir`'/mecab-ipadic-neologd')" >> $HOME/.bashrc

ENV DIC="$DIC"

RUN curl -o CRF++-0.58.tar.gz -L 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ'\
    && tar zxfv CRF++-0.58.tar.gz\
    && cd CRF++-0.58\
    && ./configure\
    && make\
    && make install\
    && ldconfig\
    && cd ..\
    && rm -rf CRF++-0.58 CRF++-0.58.tar.gz

RUN FILE_ID=0B4y35FiV1wh7SDd1Q1dUQkZQaUU\
    && FILE_NAME=cabocha-0.69.tar.bz2\
    && curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=${FILE_ID}" > /dev/null\
    && CODE="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"\
    && curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${CODE}&id=${FILE_ID}" -o ${FILE_NAME}\
    && tar jxvf cabocha-0.69.tar.bz2\
    && cd cabocha-0.69\
    && ./configure --with-charset=utf8\
    && make\
    && make install\
    && ldconfig\
    && cd ..\
    && rm -rf cabocha-0.69 cabocha-0.69.tar.bz2

RUN julia -e 'using Pkg; Pkg.add("PyCall")'
RUN julia -e 'ENV["PYTHON"]="/root/.julia/conda/3/bin/python"'
ENV PATH="/root/.julia/conda/3/bin:$PATH:${PATH}"

RUN git clone https://github.com/taku910/cabocha\
    && cd cabocha\
    && pip install python/\
    && cd ..\
    && rm -rf cabocha

RUN pip install git+https://github.com/kenkov/cabocha@0.1.4
RUN pip install mecab-python3
