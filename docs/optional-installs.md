# Optional installs

These tools are not included in `setup.sh` or the Brewfile because they're not needed on every machine or have caused setup issues in the past. Install them manually if you need them.

---

## SDKMAN (Java version manager)

SDKMAN requires bash 4+. macOS ships with bash 3.2, which causes the installer to fail if run during `setup.sh`. Install it manually after setup completes and you have a fresh terminal session.

```bash
curl -s "https://get.sdkman.io" | bash
```

Then open a new terminal and install Java:

```bash
sdk install java    # installs the current LTS
```

To see all available versions first:

```bash
sdk list java
```
