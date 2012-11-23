From: Ondrej Kozina <okozina@redhat.com>
Date: Fri, 23 Nov 2012 15:48:35 +0100
Subject: [PATCH 0/3] Add support for btrfs into fsadm script
Message-ID: <1353682118-17855-1-git-send-email-okozina@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch propose basic support for btrfs in fsadm script. But in my opinion,
btrfs enabled fsadm script shouldn't be used before taking into consideration
following notes:

btrfsck doesn't work as one would expect. It can't detect block device was
resized w/o proper filesystem resize in advance. It's reproducible by trivial
test (not subject to LVM/dm only. You'll get same results if you use standard
partition instead):

	- lvcreate -n test_lv -L1G test_vg
	- mkfs.btrfs /dev/mapper/test_vg-test_lv
	- (mount and fill w/ data)
	- lvresize -nf -L512M  test_vg/test_lv
	- btrfsck /dev/mapper/test_vg-test_lv

btrfsck tool doesn't complain about missing data chunks. Neither does mount
command. So you never know something ugly happened to your fs until you start
getting wall of i/o errors in syslog. Hopefully, this will fixed as btrfsck
tool mature over time.

Also there are some difficulties identifying mountpoint for btrfs (sub)volume.
This is caused mainly by the fact that btrfs (pool) can span across multiple
devices and there's only one entry in /dev/disk/by-uuid directory per btrfs
main instance. Moreover, the entry may change over time as devices are added to
or removed from the pool. This is the reason I can't use simple command as:

findmnt -o TARGET -S UUID=

but instead I have to check for any mounted btrfs (sub)volume and grep for
first mountpoint in the output.

btrfs-progs version used 0.20-rc1
kernel 3.6

Ondrej Kozina (3):
  - add btrfs support into fsadm
  - minor change in fsadm man page
  - add simple test for fsadm btrfs suport

 man/fsadm.8.in            |   6 +-
 scripts/fsadm.sh          | 141 ++++++++++++++++++++++++++++++++++++++---
 test/shell/fsadm-btrfs.sh | 156 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 293 insertions(+), 10 deletions(-)
 create mode 100644 test/shell/fsadm-btrfs.sh

-- 
1.8.0


