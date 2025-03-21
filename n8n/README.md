# Deploy n8n on Raspberry Pi

## Requirements
Ensure that the shared postgres database has been created and that the n8n database has been created. This will be required for the setup of the n8n service.


## Granting access to the volume
Granting access to the n8n volume can be done using the following command:

```bash
sudo chown -R your_user:your_group /home/node/.n8n
```

For n8n specifically, the default user is often node with group node (UID 1000, GID 1000), so you might try:

```bash
sudo chown -R 1000:1000 <volume>
```


Then restart the container to ensure the changes are applied
