all: sudo destroy build package.box import test

sudo:
	sudo echo "Sudo confirmed to work! Will be used while running test.sh in a later step."
clean:
	rm -f *.log *.box site.retry

destroy: clean
	vagrant destroy -f
	(cd tmp; vagrant destroy -f)
	rm -rf .vagrant tmp
	vagrant box update # Next run will be with latest box version
	vagrant box prune --name ubuntu/bionic64

build:
	vagrant up --provision

package.box: .vagrant
	vagrant halt
	vagrant package default --output package.box
	sha256sum package.box # Vagrant 2.0.2 only support 256, so don't use longer

rebuild: destroy build

import: package.box
	vagrant box add --force seravo/wordpress-beta package.box

rimport: rebuild import

test:
	./test.sh
