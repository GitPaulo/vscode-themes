# `gitpaulo-*` themes

These are my vscode themes that i've used and changed over the years~

<img width="1506" height="935" alt="image" src="https://github.com/user-attachments/assets/762a5f18-ceb2-4780-960d-567759e01f20" />

<img width="960" height="118" alt="image" src="https://github.com/user-attachments/assets/6d37a2a0-7d6f-4245-9085-fd6f369db125" />


### Install a release

```sh
curl -L -o gitpaulo-vscode-themes.vsix \
  https://github.com/GitPaulo/vscode-themes/releases/download/v0.0.x/gitpaulo-vscode-themes-0.0.x.vsix
```

install it,

```sh
code --install-extension gitpaulo-vscode-themes.vsix
```

### For codespaces consider

> [!NOTE]
> Probably just install in a profile (from outside a codespace workspace)

For example, structure it like this:

```
my-project/
├── .devcontainer/
├── gpthemes/
│   ├── package.json
│   └── themes/
│       └── gitpaulo-*.json
├── ...
```

### Local Dev

```sh
npm run build # build themes
npm run dev # builds and installs
```

Make sure to uninstall if already previously installed or the themes will not update.
