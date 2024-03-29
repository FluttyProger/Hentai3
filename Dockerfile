FROM nvidia/cuda:11.7.1-runtime-ubuntu22.04
  
RUN apt update && apt-get -y install git wget \
    python3.10 python3.10-venv python3-pip \
    build-essential libgl-dev libglib2.0-0 vim
RUN ln -s /usr/bin/python3.10 /usr/bin/python

RUN useradd -ms /bin/bash banana
WORKDIR /app

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
    cd stable-diffusion-webui
WORKDIR /app/stable-diffusion-webui


RUN wget -O models/Stable-diffusion/model.ckpt 'https://huggingface.co/FluttyProger/HentaiModelMix/resolve/main/UltraModelHentai.ckpt'
RUN echo 2
RUN wget -O models/Stable-diffusion/model.vae.pt 'https://huggingface.co/iZELX1/Grapefruit/resolve/main/Grapefruit.vae.pt'
RUN echo 2
ADD prepare.py .
RUN python prepare.py --skip-torch-cuda-test --xformers --reinstall-torch --reinstall-xformers

ADD download.py download.py
RUN python download.py --use-cpu=all

RUN pip install dill
RUN pip install sanic==22.6.2
RUN pip install websockets==10.0

RUN mkdir -p extensions/banana/scripts
ADD script.py extensions/banana/scripts/banana.py
ADD app.py app.py
ADD server.py server.py

CMD ["python", "server.py", "--xformers", "--disable-safe-unpickle", "--lowram", "--no-hashing", "--listen", "--port", "8000"]
