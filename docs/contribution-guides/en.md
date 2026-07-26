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

> This project requires **Node.js 22.12 or newer** (`@electron/packager` 20 and `nodegit` 0.28 both need it).

### Building for macOS

`intergitive` is an Electron app, so it can be packaged for macOS. Because `nodegit` is a native module, packaging must run on a Mac (the native binary cannot be cross-compiled from Windows/Linux).

Both **Apple Silicon (arm64)** and **Intel (x64)** are supported natively.

- Via GitHub Actions (recommended):
  - The `Build macOS app` workflow (`.github/workflows/build-mac.yml`) builds both architectures and uploads each zipped `.app` as an artifact. Trigger it from the repository's **Actions** tab (Run workflow), then download `intergitive-mac-arm64` or `intergitive-mac-x64`.
- Locally on a Mac:
  - Install dependencies and `nodegit` (see the setup steps above, using `./post-npm-install-mac.sh`)
  - Run `npm run build-pack-mac-arm64` (Apple Silicon) or `npm run build-pack-mac` (Intel)
  - The packaged app appears at `out/intergitive-darwin-<arch>/intergitive.app`

> The app is unsigned. On first launch macOS Gatekeeper may block it (it can even report the app as "damaged"); open it via right-click → Open, or run `xattr -dr com.apple.quarantine /path/to/intergitive.app`.

#### Keep the Electron version pinned to the nodegit ABI

`nodegit` publishes prebuilt binaries per Electron ABI. This project pins `electron` to **41.3.0** because `nodegit` 0.28.0-alpha.38 ships prebuilts tagged `electron-v41.3` for darwin/win32/linux on both arm64 and x64.

If you change the `electron` version, you must pick one whose `major.minor` still has a matching `nodegit` prebuilt, and update `target` in `.npmrc`, `post-npm-install-mac.sh`, and the CI workflow to match. Otherwise `node-pre-gyp` falls back to compiling `nodegit` from source, which is slow and fragile. The available prebuilts can be listed from `nodegit`'s binary host:

```
curl -s "https://axonodegit.s3.amazonaws.com/?list-type=2&prefix=nodegit/nodegit/nodegit-v0.28&max-keys=1000" | tr '<' '\n' | grep -o 'nodegit-v[^<]*darwin[^<]*'
```

### Before Pushing Commits

- Please be sure the style checks are passed: execute `npm run lint` or `npm run fix-lint` to fix errors automatically
- Please be sure that all tests are passed: execute `npm run test`
