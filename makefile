file-counts:
	@echo "canvaskit" && find public/canvaskit -type f | wc -l
	@echo "auto" && find public/auto -type f | wc -l
	@echo "html" && find public/html -type f | wc -l
	@echo "wasm-canvaskit-dual" && find public/wasm-canvaskit-dual -type f | wc -l
	@echo "wasm" && find public/wasm -type f | wc -l

file-size:
	@echo "canvaskit" && du -sh public/canvaskit
	@echo "auto" && du -sh public/auto
	@echo "html" && du -sh public/html
	@echo "wasm-canvaskit-dual" && du -sh public/wasm-canvaskit-dual
	@echo "wasm" && du -sh public/wasm

push-builds:
	make builds
	git add public
	git commit -m "Update builds"
	git push

builds:
	# make build-auto
	make build-canvaskit
	# make build-html
	make build-wasm-canvaskit-dual
	# make build-wasm

# canvaskit renderer is default
build-auto:
	rm -rf build
	rm -rf public/auto
	mkdir -p public/auto
	flutter build web --release
	cp -r build/web/* public/auto/

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

build-wasm-canvaskit-dual:
	rm -rf build
	rm -rf public/wasm-canvaskit-dual
	mkdir -p public/wasm-canvaskit-dual
	flutter build web --release --wasm
	cp -r build/web/* public/wasm-canvaskit-dual/

build-wasm:
	rm -rf build
	rm -rf public/wasm
	mkdir -p public/wasm
	flutter build web --release --web-renderer skwasm
	cp -r build/web/* public/wasm/
