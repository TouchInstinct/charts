{{/*
Expand the name of the chart.
*/}}
{{- define "<CHARTNAME>.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "<CHARTNAME>.fullname" -}}
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
{{- define "<CHARTNAME>.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "<CHARTNAME>.labels" -}}
helm.sh/chart: {{ include "<CHARTNAME>.chart" . }}
{{ include "<CHARTNAME>.selectorLabels" . }}
{{ include "<CHARTNAME>.touchinLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "<CHARTNAME>.selectorLabels" -}}
app.kubernetes.io/name: {{ include "<CHARTNAME>.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Values.domain }}
app.kubernetes.io/domain: {{ .Values.domain }}
{{- end }}
{{- if .Values.releaseName }}
app.kubernetes.io/releaseName: {{ .Values.releaseName }}
{{- end }}
{{- if .Values.component }}
app.kubernetes.io/component: {{ .Values.component }}
{{- end }}
{{- if and .Values.db .Values.db.platform }}
app.kubernetes.io/database: {{ .Values.db.platform.name }}
app.kubernetes.io/databaseVersion: {{ .Values.db.platform.version | quote }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "<CHARTNAME>.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "<CHARTNAME>.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create db environments
*/}}
{{- define "<CHARTNAME>.db.environments" -}}
{{- if eq .Values.db.platform.name "postgres" }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: "postgres{{ .Values.db.platform.version }}-{{ .Release.Namespace }}"
      key: postgresql-password
- name: PGHOST
  value: "postgres{{ .Values.db.platform.version }}-{{ .Release.Namespace }}"
- name: PGUSER
  value: "postgres"
{{- end }}
{{- end }}

{{/*
Get db name
*/}}
{{- define "<CHARTNAME>.db.name" -}}
{{ .Values.db.name }}{{- if .Values.releaseName }}--{{ .Values.releaseName }}{{- end }}
{{- end }}

{{/*
Touchin labels
*/}}
{{- define "<CHARTNAME>.touchinLabels" -}}
{{- if .Values.origin.pullRequestNumber }}
touchin.ru/origin: pr__{{ .Values.origin.pullRequestNumber }}
{{- else if .Values.origin.releaseBranch }}
touchin.ru/origin: release__{{ .Values.origin.releaseBranch }}
{{- end }}
{{- if .Values.log }}
log.type: {{ .Values.log.type }}
log.provider: {{ .Values.log.provider }}
log.consumed-by: {{ .Values.log.consumedBy }}
{{- end }}
{{- end }}
