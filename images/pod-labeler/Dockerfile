# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM python:2.7-stretch

RUN apt-get update && apt-get upgrade -y && apt-get install vim -y

RUN pip install requests

RUN git clone --recursive https://github.com/kubernetes-client/python.git && \
    cd python && \
    python setup.py install

RUN pip install kubernetes

ENV PYTHON_EGG_CACHE=/tmp

WORKDIR /app

USER nobody

ADD label_pods.py label_pods.py

ENTRYPOINT python -u label_pods.py
