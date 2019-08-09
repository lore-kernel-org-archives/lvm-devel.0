From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Aug 2019 06:58:53 -0400
Subject: master - tests: add settle wait before issue remove
Message-ID: <201908091058.x79Awrlq031628@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1e553159d5147c601ae4b524198461309016b496
Commit:        1e553159d5147c601ae4b524198461309016b496
Parent:        d3903d94e910b7ca673ef090c6fe9f79b04b7dd5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 4 16:58:27 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 9 12:57:21 2019 +0200

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


