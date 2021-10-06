# geany-hcl-syntax-highlighting
Custom configuration file for the Geany text editor that allows highlighting of Terraform's HCL (Hashicorp configuration files) files. Supports highlighting of AWS and GCP resources.

## Installation on Linux

- Copy filetypes.HCL.conf to ~/.config/geany/filedefs
- Edit your ~/.config/geany/filetype_extensions.conf and add the following under [Extensions]:

```
HCL=*.tf;*.tfvars;
```
- Restart Geany
