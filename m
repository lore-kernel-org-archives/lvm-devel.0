From: Paul van Genderen-Tjie A Loi <paul.vangenderen@freedom.nl>
Date: Mon, 24 Jul 2023 13:05:51 +0200
Subject: Command failed with status code 5
Message-ID: <1b7f1a83ec13979da2cb4ca2e502c37c@freedom.nl>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

Invoking "vgscan --mknodes" or "vgmknodes" can result in the following
error message: Command failed with status code 5. Furthermore, it is
possible for this particular message to be printed regardless of any
actual failure. The exit code of the commands match the printed code.

For instance, using QEMU utilities to create a block device:
qemu-img -f qcow2 testmknodes.qcow2 20G
qemu-nbd --connect=/dev/nbd0 testmknodes.qcow2
pvcreate /dev/nbd0
vgcreate testvg /dev/nbd0
lvcreate -l 100%FREE --thinpool testtp testvg
lvcreate -V 10G --thinpool testtp testvg

Everything works as expected until the thin LV is created. In case of
additional errors, please ensure both "dm_thin_pool" and "nbd" modules
are loaded into the kernel. After creating volumes this way and they're
configured to be activated (the default), the commands fail.

Status code 5 matches ECMD_FAILED which is defined in tools/errors.h and
is returned by _vgmknodes_single in tools/vgmknodes.c
_vgmknodes_single calls lv_mknodes which calls dev_manager_mknodes and
that function resides in lib/activate/dev_manager.c

dev_manager_mknodes by default returns 0 (line 2057) and this return
value is only changed on 2 conditions, the first of which using a nested
if statement. The nested if omits an else clause and adding one right
there has fixed the problem for me. Diff attached.

I've tested this against commit e84b00964 running on Linux 6.1.38 and
6.3.12. There may well be other use cases that trigger this failure
condition and I must admit that I've only tested the thin pool case.

Regards,
Paul
-------------- next part --------------
A non-text attachment was scrubbed...
Name: dev_manager_mknodes.diff
Type: text/x-diff
Size: 376 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230724/e3da2764/attachment.bin>
