# `gitpaulo-*` themes

<img width="1506" height="935" alt="image" src="https://github.com/user-attachments/assets/762a5f18-ceb2-4780-960d-567759e01f20" />

<img width="490" height="70" alt="image" src="https://github.com/user-attachments/assets/ab120943-1a55-43ee-8087-71a93f54c7e8" />

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
