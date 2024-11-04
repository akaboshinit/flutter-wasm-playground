file-counts:
	@echo "canvaskit" && find public/canvaskit -type f | wc -l
	@echo "default" && find public/default -type f | wc -l
	@echo "html" && find public/html -type f | wc -l
	@echo "wasm" && find public/wasm -type f | wc -l

file-size:
	@echo "canvaskit" && du -sh public/canvaskit
	@echo "default" && du -sh public/default
	@echo "html" && du -sh public/html
	@echo "wasm" && du -sh public/wasm

push-builds:
	make builds
	git add public
	git commit -m "Update builds"
	git push

builds:
	make build-default
	make build-canvaskit
	make build-html
	make build-wasm

build-default:
	rm -rf build
	rm -rf public/default
	mkdir -p public/default
	flutter build web --release
	cp -r build/web/* public/default/

build-canvaskit:
	rm -rf build
	rm -rf public/canvaskit
	mkdir -p public/canvaskit
	flutter build web --release --web-renderer canvaskit
	cp -r build/web/* public/canvaskit/

build-html:
	rm -rf build
	rm -rf public/html
	mkdir -p public/html
	flutter build web --release --web-renderer html
	cp -r build/web/* public/html/

build-wasm:
	rm -rf build
	rm -rf public/wasm
	mkdir -p public/wasm
	flutter build web --release --wasm
	cp -r build/web/* public/wasm/
