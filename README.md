## How To

```sh
git clone git@github.com:GitPaulo/vscode-themes.git
cd vscode-themes
```

and

```sh
code --install-extension .
```
### Install a release

```sh
curl -L -o gitpaulo-vscode-themes.vsix \
  https://github.com/GitPaulo/vscode-themes/releases/download/v0.0.1/gitpaulo-vscode-themes-0.0.1.vsix
# Install it into VS Code
code --install-extension gitpaulo-vscode-themes.vsix
```

### For codespaces consider

For example, structure it like this:

```
my-project/
├── .devcontainer/
├── gpthemes/
│   ├── package.json
│   └── themes/
│       └── minimal_one.json
├── ...
```

```json
{
  "name": "My Codespace Dev Container",
  "extensions": [],
  "customizations": {
    "vscode": {
      "extensions": [
        "gpthemes"
      ]
    }
  },
  "postCreateCommand": "export THEME_VERSION=v0.0.1 && \
  curl -L -o gitpaulo-vscode-themes.vsix https://github.com/GitPaulo/vscode-themes/releases/download/$THEME_VERSION/gitpaulo-vscode-themes-$THEME_VERSION.vsix && \
  code --install-extension gitpaulo-vscode-themes.vsix"
}
```
