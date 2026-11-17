#!/bin/sh
# Files that usually hold credentials. Matched against the path; examples and templates are fine.
default='(^|/)(auth\.json|\.env(\.[a-z]+)*|env\.php|\.npmrc|id_(rsa|dsa|ecdsa|ed25519)|[^/]+\.(pem|key|p12|pfx))$'
allowed='\.(example|dist|sample|template)$'
status=0
for file; do
    printf '%s\n' "$file" | grep -Eq "${CREDENTIAL_FILES:-$default}" || continue
    printf '%s\n' "$file" | grep -Eq "$allowed" && continue
    echo "$file usually holds credentials. To commit it on purpose, add it to this job's exclude in lefthook.yml."
    status=1
done
exit $status
