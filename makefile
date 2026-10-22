NAME := LemonSign
PLATFORM := iphoneos
SCHEMES := Ksign
TMP := $(TMPDIR)/$(NAME)
STAGE := $(TMP)/stage
APP := $(TMP)/Build/Products/Release-$(PLATFORM)

.PHONY: all clean $(SCHEMES)

all: $(SCHEMES)

clean:
	rm -rf "$(TMP)"
	rm -rf packages
	rm -rf Payload

deps:
	mkdir -p deps
	@if [ ! -f deps/server.crt ] || [ ! -f deps/server.pem ]; then \
		echo "Fetching SSL certificates from pack.json..."; \
		curl -s -L https://backloop.dev/pack.json -o deps/pack.json || true; \
		if [ -s deps/pack.json ]; then \
			python3 -c "import json; data=json.load(open('deps/pack.json')); open('deps/server.crt','w').write(data['cert']); open('deps/server.pem','w').write(data['key1']+data['key2']); open('deps/commonName.txt','w').write(data['info']['domains']['commonName'])" 2>/dev/null || true; \
			rm -f deps/pack.json; \
		fi \
	fi
	@if [ ! -f deps/commonName.txt ]; then echo "*.backloop.dev" > deps/commonName.txt; fi

$(SCHEMES): deps
	xcodebuild \
	    -project Ksign.xcodeproj \
	    -scheme "$@" \
	    -configuration Release \
	    -arch arm64 \
	    -sdk $(PLATFORM) \
	    -derivedDataPath $(TMP) \
	    -skipPackagePluginValidation \
	    CODE_SIGNING_ALLOWED=NO \
	    ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO

	rm -rf Payload
	rm -rf "$(STAGE)/"
	mkdir -p "$(STAGE)/Payload"

	@if [ -d "$(APP)/LemonSign.app" ]; then \
		mv "$(APP)/LemonSign.app" "$(STAGE)/Payload/LemonSign.app"; \
	elif [ -d "$(APP)/$@.app" ]; then \
		mv "$(APP)/$@.app" "$(STAGE)/Payload/LemonSign.app"; \
	else \
		mv "$$(find $(APP) -name '*.app' -maxdepth 1)" "$(STAGE)/Payload/LemonSign.app"; \
	fi

	chmod -R 0755 "$(STAGE)/Payload/LemonSign.app"
	codesign --force --sign - --timestamp=none "$(STAGE)/Payload/LemonSign.app"

	cp deps/* "$(STAGE)/Payload/LemonSign.app/" || true

	rm -rf "$(STAGE)/Payload/LemonSign.app/_CodeSignature"
	ln -sf "$(STAGE)/Payload" Payload
	
	mkdir -p packages
	zip -r9 "packages/LemonSign.ipa" Payload
	rm -f packages/Ksign.ipa
