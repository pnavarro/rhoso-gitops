{{/*
Namespace for Argo CD Application CRs (metadata.namespace).
Pass root context ($) from inside range.
*/}}
{{- define "rhoso-gitops.applicationNamespace" -}}
{{- default "openshift-gitops" .Values.applicationNamespace | quote -}}
{{- end }}

{{/*
Default Kubernetes API server URL for spec.destination.server.
Pass root context ($) from inside range.
*/}}
{{- define "rhoso-gitops.destinationServer" -}}
{{- default "https://kubernetes.default.svc" .Values.destinationServer | quote -}}
{{- end }}

{{/*
Argo CD AppProject name; empty string in values maps to "default".
Pass dict with key "app" (per-application values map).
*/}}
{{- define "rhoso-gitops.argocdProject" -}}
{{- $app := .app -}}
{{- default "default" $app.project | quote -}}
{{- end }}

{{/*
Repository path under spec.source.path.
*/}}
{{- define "rhoso-gitops.sourcePath" -}}
{{- $app := .app -}}
{{- default "." $app.path | quote -}}
{{- end }}

{{/*
Git revision, branch, or tag for spec.source.targetRevision.
*/}}
{{- define "rhoso-gitops.targetRevision" -}}
{{- $app := .app -}}
{{- default "HEAD" $app.targetRevision | quote -}}
{{- end }}

{{/*
argocd.argoproj.io/sync-wave annotation; omitted in values defaults to "0".
Pass dict with key "app" (per-application values map).
*/}}
{{- define "rhoso-gitops.syncWave" -}}
{{- $app := .app -}}
{{- default "0" $app.syncWave | quote -}}
{{- end }}

{{/*
Optional spec.source.kustomize (Argo CD Kustomize overrides).
Pass dict with key "app" (per-application values map). Omitted if unset, non-map, or empty map.
*/}}
{{- define "rhoso-gitops.sourceKustomize" -}}
{{- $app := .app -}}
{{- $k := $app.kustomize | default dict }}
{{- if not (kindIs "map" $k) }}
{{- $k = dict }}
{{- end }}
{{- if not (empty $k) }}
    kustomize:
{{ toYaml $k | nindent 6 }}
{{- end }}
{{- end }}

{{/*
Build spec.syncPolicy; emit block or nothing.
Pass dict with key "app" (per-application values map).
*/}}
{{- define "rhoso-gitops.syncPolicySpec" -}}
{{- $app := .app -}}
{{- $sp := $app.syncPolicy | default dict }}
{{- if not (kindIs "map" $sp) }}
{{- $sp = dict }}
{{- end }}
{{- if not (empty $sp) }}
  syncPolicy:
{{ toYaml $sp | indent 4 }}
{{- end }}
{{- end }}

{{/*
Optional spec.ignoreDifferences for the Argo CD Application.
Pass dict with key "app" (per-application values map). Omitted if unset or empty.
*/}}
{{- define "rhoso-gitops.ignoreDifferences" -}}
{{- $app := .app -}}
{{- if and $app.ignoreDifferences (not (empty $app.ignoreDifferences)) }}
  ignoreDifferences:
{{ toYaml $app.ignoreDifferences | indent 4 }}
{{- end }}
{{- end }}

{{/*
Argo CD Application metadata.finalizers (resources finalizer: background vs foreground).
Omitted finalizers default to background deletion.
Pass dict with key "app" (per-application values map).
*/}}
{{- define "rhoso-gitops.applicationFinalizers" -}}
{{- $app := .app -}}
{{- $f := default (list "resources-finalizer.argocd.argoproj.io/background") $app.finalizers }}
{{- toYaml $f -}}
{{- end }}
