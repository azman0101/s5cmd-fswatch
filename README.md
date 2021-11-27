# Build s5cmd-fswatch

```bash
docker buildx build  -t azman0101/s5cmd:$(git branch --show-current) \
                     -f Dockerfile \
                     --platform linux/amd64 \
                     -f Dockerfile.curl .
```

# Deploy Cronjob

```bash
kustomize build manifest/overlays/${ENV}  | kubectl diff -n default -f -
```
