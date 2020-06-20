OS := $(shell uname)

preview:
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(PREVIEW_VERSION)/" Chart.yaml
	sed -i "" -e "s/version:.*/version: $(PREVIEW_VERSION)/" ../php-laravel/Chart.yaml
	sed -i "" -e "s/tag: .*/tag: $(PREVIEW_VERSION)/" ./values.yaml
else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(PREVIEW_VERSION)/" Chart.yaml
	sed -i -e "s/version:.*/version: $(PREVIEW_VERSION)/" ../php-laravel/Chart.yaml
	sed -i -e "s|repository: .*|repository: $(DOCKER_REGISTRY)\/trunk-studio-interview\/php-laravel|" values.yaml
	sed -i -e "s/tag: .*/tag: $(PREVIEW_VERSION)/" values.yaml
else
	echo "platfrom $(OS) not supported to release from"
	exit -1
endif
	echo "  version: $(PREVIEW_VERSION)" >> requirements.yaml
	jx step helm build