PACKER_FILE = debian-12-bookworm.pkr.hcl
PACKER_FLAGS = -var-file='../credentials.pkrvars.hcl'


build: validate $(PACKER_FILE)
	packer build $(PACKER_FLAGS) $(PACKER_FILE)

validate: $(PACKER_FILE)
	packer validate $(PACKER_FLAGS) $(PACKER_FILE)