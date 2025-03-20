## Granting access to the volume
Granting access to the n8n volume can be done using the following command:

```bash
sudo chown -R your_user:your_group /home/node/.n8n
```

For n8n specifically, the default user is often node with group node (UID 1000, GID 1000), so you might try:

```bash
sudo chown -R 1000:1000 /home/node/.n8n
```