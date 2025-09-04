.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "List of available make commands";
	@echo "";
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}';
	@echo "";

# ci
.PHONY: ci
ci: build analyze format

# analyze
.PHONY: analyze
analyze: ## Analyze all apps with Flutter
	fvm dart analyze .

# format
.PHONY: format
format: ## Format all code
	fvm dart format .
	npx prettier --write "**/*.md"

# run build
.PHONY: build
build: ## Same functionality as `fvm dart run build_runner build` (made available at root level) Usage: `make build`
	fvm dart run build_runner build --delete-conflicting-outputs

# add_freezed: https://pub.dev/packages/freezed#install
.PHONY: add_freezed
add_freezed: ## Add freezed to package: `make add_freezed`
	fvm dart pub add freezed_annotation && \
	fvm dart pub add dev:build_runner && \
	fvm dart pub add dev:freezed && \
	fvm dart pub add json_annotation && \
	fvm dart pub add dev:json_serializable; \

# git branch clean
.PHONY: git_branch_clean
git_branch_clean: ## Delete local branches that don't exist on remote
	git fetch -p && \
	current_branch=$$(git branch --show-current) && \
	for branch in $$(git branch | sed 's/..//'); do \
		if [ "$$branch" != "$$current_branch" ]; then \
			if ! git show-ref --quiet refs/remotes/origin/$$branch; then \
				git branch -D "$$branch"; \
			fi; \
		fi; \
	done

# git_create_tag
.PHONY: git_create_tag
git_create_tag: ## Create a tag: `make git_create_tag <tag_name>`
	if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "\033[0;31mPlease provide a tag name."; \
	else \
		git tag $(filter-out $@,$(MAKECMDGOALS)) && \
		git push origin $(filter-out $@,$(MAKECMDGOALS)); \
	fi

# git_my_tasks
.PHONY: git_my_tasks
git_my_tasks: ## Display my tasks: `make git_my_tasks`
	gh issue ls --assignee @me

.PHONY: pub_publish_dry_run
pub_publish_dry_run: ## Dry run for pub publish: `make pub_publish_dry_run`
	fvm dart pub publish --dry-run

.PHONY: pub_publish
pub_publish: ## Publish to pub.dev: `make pub_publish`
	fvm dart pub publish

.PHONY: add_dependency
add_dependency: ## Add a dependency to the package: `make add_dependency <dependency_name>`
	if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "\033[0;31mPlease provide a dependency name."; \
	else \
		fvm dart pub add $(filter-out $@,$(MAKECMDGOALS)); \
	fi

.PHONY: rename
rename: ## Rename in all files from dart_pkg_temp to <new_name>: `make rename <new_name>`
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "\033[0;31mPlease provide a new name."; \
		echo "\033[0;33mUsage: make rename <new_name>"; \
		exit 1; \
	else \
		NEW_NAME=$(filter-out $@,$(MAKECMDGOALS)); \
		echo "\033[0;32mRenaming dart_pkg_temp to $$NEW_NAME in all files..."; \
		find . -type f \( -name "*.dart" -o -name "*.yaml" -o -name "*.yml" -o -name "*.md" -o -name "*.json" \) -not -path "./.dart_tool/*" -not -path "./build/*" -not -path "./.git/*" | xargs sed -i '' "s/dart_pkg_temp/$$NEW_NAME/g"; \
		echo "\033[0;32mRenaming lib/dart_pkg_temp.dart to lib/$$NEW_NAME.dart..."; \
		if [ -f "lib/dart_pkg_temp.dart" ]; then \
			mv "lib/dart_pkg_temp.dart" "lib/$$NEW_NAME.dart"; \
		fi; \
		echo "\033[0;32mRename completed successfully!"; \
		echo "\033[0;33mModified files:"; \
		git status --porcelain | grep -E "^\s*M" || echo "No files were modified."; \
	fi

%:
	@:
