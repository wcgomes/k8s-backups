{{/*
Expand the name of the chart.
*/}}
{{- define "k8s-backups-postgresql.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "k8s-backups-postgresql.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "k8s-backups-postgresql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "k8s-backups-postgresql.labels" -}}
helm.sh/chart: {{ include "k8s-backups-postgresql.chart" . }}
{{ include "k8s-backups-postgresql.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k8s-backups-postgresql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-backups-postgresql.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the secret
*/}}
{{- define "k8s-backups-postgresql.secret" -}}
{{- if not .Values.existingSecret }}
{{- default (include "k8s-backups-postgresql.fullname" .) }}
{{- else }}
{{- default "default" .Values.existingSecret }}
{{- end }}
{{- end }}