{{/*
Return the proper sogo image name
*/}}
{{- define "sogo.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.sogo.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper memcached image name
*/}}
{{- define "sogo.memcached.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.memcached.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "sogo.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "sogo.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.sogo.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "sogo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return true if cert-manager required annotations for TLS signed certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
*/}}
{{- define "sogo.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "sogo.validateValues" -}}
{{- $messages := list -}}
{{/*
{{- $messages := append $messages (include "sogo.validateValues.foo" .) -}}
{{- $messages := append $messages (include "sogo.validateValues.bar" .) -}}
*/}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/*
Sogo credential secret name
*/}}
{{- define "sogo.secretName" -}}
{{- coalesce .Values.sogo.existingSecret.name (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Sogo ldap username secret key
*/}}
{{- define "sogo.ldapUsernameKey" -}}
{{- if .Values.sogo.existingSecret.name -}}
    {{- print .Values.sogo.existingSecret.ldapUserKey -}}
{{- else -}}
    {{- print "ldap-dn" -}}
{{- end -}}
{{- end -}}

{{/*
Sogo ldap password secret key
*/}}
{{- define "sogo.ldapPasswordKey" -}}
{{- if .Values.sogo.existingSecret.name -}}
    {{- print .Values.sogo.existingSecret.ldapPasswordKey -}}
{{- else -}}
    {{- print "ldap-password" -}}
{{- end -}}
{{- end -}}

{{/*
Sogo OpenID client id key
*/}}
{{- define "sogo.openidClientIdKey" -}}
{{- if .Values.sogo.existingSecret.name -}}
    {{- print .Values.sogo.existingSecret.oidcClientId -}}
{{- else -}}
    {{- print "oidc-client-id" -}}
{{- end -}}
{{- end -}}

{{/*
Sogo OpenID client secret key
*/}}
{{- define "sogo.openidSecretKey" -}}
{{- if .Values.sogo.existingSecret.name -}}
    {{- print .Values.sogo.existingSecret.oidcSecretKey -}}
{{- else -}}
    {{- print "oidc-secret" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Type
*/}}
{{- define "sogo.databaseType" -}}
{{- if $.Values.mariadb.enabled }}
    {{- printf "%s" "mysql" -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.type -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Hostname
*/}}
{{- define "sogo.databaseHost" -}}
{{- if .Values.mariadb.enabled }}
    {{- if eq .Values.mariadb.architecture "replication" }}
        {{- printf "%s-primary" (include "sogo.mariadb.fullname" .) | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
        {{- printf "%s" (include "sogo.mariadb.fullname" .) -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Port
*/}}
{{- define "sogo.databasePort" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "3306" -}}
{{- else -}}
    {{- printf "%d" (.Values.externalDatabase.port | int ) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Name
*/}}
{{- define "sogo.databaseName" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "%s" .Values.mariadb.auth.database -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database User
*/}}
{{- define "sogo.databaseUser" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "%s" .Values.mariadb.auth.username -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/*
Return the password of the Database User
*/}}
{{- define "sogo.databasePassword" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "%s" .Values.mariadb.auth.password -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.password -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Secret Name
*/}}
{{- define "sogo.databaseSecretName" -}}
{{- if .Values.mariadb.enabled }}
    {{- if .Values.mariadb.auth.existingSecret -}}
        {{- printf "%s" .Values.mariadb.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "sogo.mariadb.fullname" .) -}}
    {{- end -}}
{{- else if .Values.externalDatabase.existingSecret -}}
    {{- include "common.tplvalues.render" (dict "value" .Values.externalDatabase.existingSecret "context" $) -}}
{{- else -}}
    {{- printf "%s-externaldb" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database URL
*/}}
{{- define "sogo.databaseURL" -}}
{{- if .Values.mariadb.enabled }}
    {{- with .Values.mariadb.auth -}}
    {{- printf "mysql://%s:%s@%s:3306/%s" .username .password (include "sogo.mariadb.fullname" $) .database -}}
    {{- end -}}
{{- else -}}
    {{- with .Values.externalDatabase -}}
    {{- printf "%s://%s:%s@%s:%d/%s" .type .user .password .host ( .port | int ) .database -}}
    {{- end -}}
{{- end -}}
{{- end -}}
