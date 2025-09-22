```bash
docker build -t docker.io/longdevdatabase/test_rofl .

docker push docker.io/longdevdatabase/test_rofl
rofl1qr95suussttd2g9ehu3zcpgx8ewtwgayyuzsl0x2
oasis rofl deploy --provider rofl1qr95suussttd2g9ehu3zcpgx8ewtwgayyuzsl0x2

oasis rofl provider update-offers

oasis rofl deploy --provider oasis1qrpptdcpsxvxn3re0cg3f6hfy0kyfujnz5ex7vgn --offer myaccount
```