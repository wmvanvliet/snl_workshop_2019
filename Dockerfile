FROM jupyter/minimal-notebook:65761486d5d3 

MAINTAINER Marijn van Vliet <w.m.vanvliet@gmail.com>


# *********************Unix tools ***************************
USER root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade \
    && apt-get install -yq --no-install-recommends \
    openssh-client \
    vim \ 
    curl \
    gcc \
    && apt-get clean

# Xvfb
RUN apt-get install -yq --no-install-recommends \
    xvfb \
    x11-utils \
    libx11-dev \
    qt5-default \
    && apt-get clean

ENV DISPLAY=:99

# *********************As User ***************************
USER $NB_UID
RUN pip install --upgrade pip
RUN npm i npm@latest -g

# **************** Python packages ***********************
USER ${NB_UID}

RUN pip install vtk && \
    pip install numpy && \
    pip install scipy && \
    pip install pyqt5 && \
    pip install xvfbwrapper && \
    pip install mayavi

    
RUN pip install ipywidgets && \
    pip install pillow && \
    pip install scikit-learn && \
    pip install nibabel && \
    pip install pysurfer && \
    pip install mne

RUN git init . && \
    git remote add origin https://github.com/wmvanvliet/snl_workshop_2019.git && \
    git pull origin master

# ********** Notebook extensions *****************
RUN pip install RISE && \
    jupyter nbextension install rise --py --sys-prefix &&\
    jupyter nbextension enable rise --py --sys-prefix &&\
    jupyter nbextension install mayavi --py --sys-prefix &&\
    jupyter nbextension enable mayavi --py --sys-prefix &&\
    npm cache clean --force

# ********* Download sample data ****************
RUN ipython -c "import mne; print(mne.datasets.sample.data_path(verbose=False))"

# Add an x-server to the entrypoint. This is needed by Mayavi
ENTRYPOINT ["tini", "-g", "--", "xvfb-run"] 
