{{/*
# Copyright 2017 AT&T Intellectual Property.  All other rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
*/}}

{{- $envAll := . }}
---
apiVersion: v1
kind: Pod
metadata:
  name: {{ .Values.service.name }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{ .Values.service.name }}-service: enabled
{{ tuple $envAll "kubernetes" "scheduler" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 4 }}
spec:
  hostNetwork: true
  containers:
    - name: scheduler
      image: {{ .Values.images.tags.scheduler }}
      env:
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
      command:
        {{- range .Values.command_prefix }}
        - {{ . }}
        {{- end }}
        - --leader-elect=true
        - --kubeconfig=/etc/kubernetes/scheduler/kubeconfig.yaml

      volumeMounts:
        - name: etc
          mountPath: /etc/kubernetes/scheduler
          defaultMode: 0444
  volumes:
    - name: etc
      hostPath:
        path: {{ .Values.scheduler.host_etc_path }}
