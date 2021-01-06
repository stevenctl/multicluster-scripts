1. `cp .envtemplate .env`
2. Edit `.env` and fill in contexts
3. `./cleanup.sh` 
4. `./setup.sh`
5. `./deploy-verify.sh`
6. Wait until sleep and helloworld pods are ready
7. `./validate.sh` and ensure echo responses come from both clusters
8. `./cleanup.sh`
