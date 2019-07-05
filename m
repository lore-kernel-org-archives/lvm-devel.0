From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 5 Jul 2019 19:26:41 -0400
Subject: stable-2.02 - tests: add settle wait before issue remove
Message-ID: <201907052326.x65NQfPF010090@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2f846697fcb16b2e0954a051577bd47c8cf6721c
Commit:        2f846697fcb16b2e0954a051577bd47c8cf6721c
Parent:        cff9bff0afc21d9593dd6585bbd375384fdf47be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 4 16:58:27 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jul 6 01:24:28 2019 +0200

tests: add settle wait before issue remove

Some older BB with older cryptsetup tool do not 'retry' on remove
and when  remove is issued right after 'fsck'  - it might be
rejected with:

Device @PREFIX at -tcrypt2 is busy.

Try to use udevadm settle.
---
 test/shell/fsadm-crypt.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index 9377e89..4b8fc4e 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -83,6 +83,7 @@ export LVM_BINARY
 test ! -d "$mount_dir" && mkdir "$mount_dir"
 
 crypt_close() {
+	aux udev_wait
 	cryptsetup remove "$1"
 	if [ "$?" -eq 0 -a -n "$DROP_SYMLINK" ]; then
 		rm -f "$DM_DEV_DIR/mapper/$1"


