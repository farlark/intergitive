# Contribution Guide  

Welcom! `intergitive` appreciates any contribution.  

Contributions can mostly be made in two aspects: changes of main program or changes of tutorial contents. No matter which kind of contributions you would like to make, this guide will help you jump start.  

## Recommended Environment

Most part of `intergitive` is developed under the following environment settings. It is highly recommended to use the same settings to avoid possible errors caused by differences in environment.

- Windows 10
- PowerShell v5.1
- node v12.20.2
- npm v6.14.11
- VS code v1.46
  - ESLint v2.1.8: Currently this project adopts [JavaScript Standard style](https://standardjs.com/) because it needs least manual modifications while the project starting linting after a long time of development.
  - Vetur 0.24.0
  - vue 0.1.5
  - YAML 0.16.0

## Recommended Steps

### Initialize Project

- Clone the repository to your computer.  
- Open PowerShell. Change directory to the cloned project. If no extra notion is provided, we assume that "execute command" means executing PowerShell command in the project directory.  
- Install npm packages: execute command `npm install`
- **Important**: install `nodegit` (a package allows `intergitive` to operate git)。One may choose to install it via a script or manually (if you don't trust the installtion script)
  - Via the script
    - Allow PowerShell to execute scripts: execute command `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process`  
    - Run the script: execute `.\post-npm-install-win.ps1 -architecture x64`
  - On macOS, via the script
    - Make the script executable (first time only): `chmod +x ./post-npm-install-mac.sh`
    - Run the script: `./post-npm-install-mac.sh x64` (use `arm64` on Apple Silicon if you want a native build; `x64` also runs under Rosetta 2)
  - Manually. We will install `nodegit` for running in node and electron. We also maintain a cache for switching between the two modes quickly. 
    - Initialize cache: execute `node .\dev\module-switch.js init`
    - Clean up existing cache (one may skip this step if it is the first time of cloning `intergitive`): execute `node .\dev\module-switch.js drop nodegit`
    - Install `nodegit` for electron
      - Create `.npmrc` and fill in the following contents. If the file already exists, overwrite it:  
    ```
    $content = @"
    runtime = electron
    target = 8.2.0
    target_arch = $architecture
    disturl = "https://atom.io/download/atom-shell"
    ```  
      - Install `nodegit`: execute `npm install nodegit@0.26.x`
      - Cache it: execute `node .\dev\module-switch.js save nodegit electron`
    - Install `nodegit` for node
      - Delete `.npmrc`
      - Install `nodegit`: execute `npm install nodegit@0.26.x`  
      - Cache it: execute `node .\dev\module-switch.js save nodegit node` 

### Check if Initialized Successfully

- Run tests in node: execute `npm run test` (takes about 5-10 minutes)
- Run tests in electron: execute `npm run etest` (takes about 5-10 minutes)
- Execute the program: execute `npm run test-pack`

### NPM Commands

Here are a brief list of NPM commands that might be useful
- `load-native-node`: switch NPM native packages to node mode
- `load-native-electron`: switch NPM native packages to electron mode
- `test`: run tests in node
- `check-course`: checks if any assets used in tutorials is missing
- `etest`: run tests in electron
- `lint`: run style checks
- `fix-lint`: run style checks and try fix it automatically
- `pack`: pack the project in production mode. The entry point of packed product is `main.js` in the project folder
- `pack-dev`: pack the project in development mode. The entry point of packed product is `main.js` in the project folder
- `test-pack`: pack and execute the project in development mode
- `test-pack-production`: pack and execute the project in production mode
- `build-pack-win64`: pack the project in production mode and bundle it into the `out` folder. Please ensure the folder is empty before execution
- `build-pack-mac`: (macOS, Intel x64) pack in production mode and bundle a `.app` into the `out` folder
- `build-pack-mac-arm64`: (macOS, Apple Silicon) same as above but builds a native arm64 `.app`

### Building for macOS

`intergitive` is an Electron app, so it can be packaged for macOS. Because `nodegit` is a native module, the packaging must run on a Mac (the native binary cannot be cross-compiled from Windows/Linux).

We target **Intel (x64)**: `nodegit` 0.26.5 ships a prebuilt binary for `electron-v8.2` / `darwin-x64`, and an x64 Electron app also runs on Apple Silicon via Rosetta 2 — so one x64 build covers every Mac.

- Via GitHub Actions (recommended):
  - The `Build macOS app` workflow (`.github/workflows/build-mac.yml`) builds on a macOS runner and uploads the zipped `.app` as an artifact. Trigger it from the repository's **Actions** tab (Run workflow), then download the `intergitive-mac-x64` artifact.
- Locally on a Mac:
  - Install dependencies and build `nodegit` (see the setup steps above, using `./post-npm-install-mac.sh`)
  - Run `npm run build-pack-mac`
  - The packaged app appears at `out/intergitive-darwin-x64/intergitive.app`

> The app is unsigned. On first launch macOS Gatekeeper may block it; open it via right-click → Open, or run `xattr -dr com.apple.quarantine /path/to/intergitive.app`.

> **Native arm64 is not built.** `nodegit` 0.26.5 has no arm64 prebuilt, and its from-source fallback downloads OpenSSL from the now-defunct Bintray, so it cannot build unpatched. The `build-pack-mac-arm64` script and `./post-npm-install-mac.sh arm64` exist for anyone who patches `nodegit`'s OpenSSL fetch, but the supported path on Apple Silicon is to run the x64 build under Rosetta 2.

### Before Pushing Commits

- Please be sure the style checks are passed: execute `npm run lint` or `npm run fix-lint` to fix errors automatically
- Please be sure that all tests are passed: execute `npm run test`
