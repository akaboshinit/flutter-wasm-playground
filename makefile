builds:
	make build-default
	make build-canvas
	make build-html
	make build-wasm

build-default:
	rm -rf build
	rm -rf public/default
	mkdir -p public/default
	flutter build web --release
	cp -r build/web/* public/default/

build-canvas:
	rm -rf build
	rm -rf public/canvas
	flutter build web --release --web-renderer canvaskit
	mkdir -p public/canvas
	cp -r build/web/* public/canvas/

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
