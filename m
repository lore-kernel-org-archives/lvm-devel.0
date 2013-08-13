From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 13 Aug 2013 15:52:23 +0000 (UTC)
Subject: master - blkdeactivate: add support for bind mounts
Message-ID: <20130813155223.44B176032A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=268b370e245ee0d6abaeeedff513c9678eeb7f54
Commit:        268b370e245ee0d6abaeeedff513c9678eeb7f54
Parent:        a854398764968fe2847ba6cbfec7650a7ca04b37
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 13 17:26:36 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 13 17:51:40 2013 +0200

blkdeactivate: add support for bind mounts

Recent version of util-linux/umount (v2.23+) provides
umount --all-targets that can unmount all the mount targets of
the same device (the bind mounts). Use this if available when
calling the umount blkdeactivate.

Otherwise, for older versions of util-linux, use findmnt
(that is also a part of the util-linux) to iterate over all
mount targets of the same device - this is the manual way.
---
 WHATS_NEW                   |    1 +
 scripts/blkdeactivate.sh.in |   30 +++++++++++++++++++++++++-----
 2 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dd90726..40e99e6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Add support for bind mounts in blkdeactivate.
   Add blkdeactivate -v/--verbose for debug output from external tools used.
   Add blkdeactivate -e/--errors for error messages from external tools used.
   Suppress messages from external tools called in blkdeactivate by default.
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 48f9fe3..b6d0117 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -36,7 +36,13 @@ UMOUNT="/bin/umount"
 DMSETUP="@sbindir@/dmsetup"
 LVM="@sbindir@/lvm"
 
-UMOUNT_OPTS=""
+if $UMOUNT --help | grep -- "--all-targets" >$DEV_DIR/null; then
+	UMOUNT_OPTS="--all-targets "
+else
+	UMOUNT_OPTS=""
+	FINDMNT="/bin/findmnt -r --noheadings -u -o TARGET"
+	FINDMNT_READ="read -r mnt"
+fi
 DMSETUP_OPTS=""
 LVM_OPTS=""
 
@@ -132,10 +138,8 @@ is_top_level_device() {
 	test -z "$files"
 }
 
-device_umount () {
-	test -z "$mnt" && return 0;
-
-	test "$devtype" != "lvm" && test "${kname:0:3}" != "dm-" && return 0
+device_umount_one() {
+	test -z "$mnt" && return 0
 
 	if test -z "${SKIP_UMOUNT_LIST["$mnt"]}" -a "$DO_UMOUNT" -eq "1"; then
 		echo -n "  [UMOUNT]: unmounting $name ($kname) mounted on $mnt... "
@@ -151,6 +155,22 @@ device_umount () {
 	fi
 }
 
+device_umount() {
+	test "$devtype" != "lvm" && test "${kname:0:3}" != "dm-" && return 0
+
+	# FINDMNT is defined only if umount --all-targets is not available.
+	# In that case, read the list of multiple mount points of one device
+	# using FINDMNT and unmount it one by one manually.
+	if test -z "$FINDMNT"; then
+		device_umount_one
+	else
+		while $FINDMNT_READ; do
+			device_umount_one || return 1
+		done <<< "`$FINDMNT $DEV_DIR/$kname`"
+	fi
+
+}
+
 deactivate_holders () {
 	local skip=1; $LSBLK_VARS
 


