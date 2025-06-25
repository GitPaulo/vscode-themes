## How To

```sh
git clone git@github.com:GitPaulo/vscode-themes.git
cd vscode-themes
```

and

```sh
code --install-extension .
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
  "postCreateCommand": "code --install-extension ./gpthemes"
}
```
