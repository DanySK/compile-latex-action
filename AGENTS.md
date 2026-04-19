# Agent Instructions

Use the existing Docker-based workflow. This repository is not built with Gradle, Maven, or a Ruby test framework.

Keep `action.yml`, `Dockerfile`, and `entrypoint.rb` consistent.
- If you change action inputs, outputs, or runtime arguments in `action.yml`, update `entrypoint.rb` to match.
- If you change the container entrypoint or copied files, update `Dockerfile` accordingly.
- Treat the image reference in `action.yml` as a release artifact. Do not change it casually when editing behavior.

Validate Ruby files with syntax checks before finishing.
- Run `ruby -c entrypoint.rb` after editing the action logic.
- Run `ruby -c test.rb` after editing the test harness or Docker test flow.

Use Docker-based validation for behavior changes.
- Run `docker build -t compile-latex-action:test .` when changing `Dockerfile`, `entrypoint.rb`, or container execution in `action.yml`.
- Run `./test.rb` only when the action behavior changes and Docker, Git, network access, and elevated filesystem access are available. The script clones external repositories and is expensive.
- If full behavioral validation is not possible, state exactly what blocked it.

Preserve the action contract.
- Keep the documented outputs and environment variable behavior aligned across `README.md`, `action.yml`, and `entrypoint.rb`.
- Preserve path handling for scanned `.tex` roots and GitHub Actions environment/output files unless the change explicitly targets that behavior.

Avoid unnecessary churn in release files.
- Do not hand-edit `CHANGELOG.md` for routine code changes.
- Keep `package.json` and `release.config.js` changes limited to release automation work.

Treat warning suppressions and risky shell actions as exceptions.
- Prefer fixing the underlying issue instead of suppressing warnings.
- Add a short justification near any unavoidable suppression.
- Do not add destructive commands such as recursive deletion outside the existing test script unless the task explicitly requires them.
