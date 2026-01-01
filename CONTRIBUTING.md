# Contributing

Thanks for considering a contribution. Please keep changes focused and well-tested.

## Quick checks
- Backend tests: `cd app/backend && mvn test`
- Frontend tests: `cd app/frontend && npm test -- --watchAll=false`
- Terraform formatting: `cd terraform/aws && terraform fmt -check` and `cd terraform/azure && terraform fmt -check`
- Helm lint: `helm lint helm/myapp`

## Pull requests
- Keep PRs small and scoped.
- Update documentation if behavior changes.
- Include a short summary of what changed and why.
