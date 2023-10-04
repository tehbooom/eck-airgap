#!/bin/sh

curl --create-dirs -o /opt/registry/images/elser/models/elser_model_1.metadata.json https://ml-models.elastic.co/elser_model_1.metadata.json
curl -o /opt/registry/images/elser/models/elser_model_1.pt https://ml-models.elastic.co/elser_model_1.pt
curl -o /opt/registry/images/elser/models/elser_model_1.vocab.json https://ml-models.elastic.co/elser_model_1.vocab.json


