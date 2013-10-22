From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Oct 2013 14:25:29 +0000 (UTC)
Subject: master - blkdeactivate: fix endless loop if device(s) given and unable to umount/deactivate
Message-ID: <20131022142529.2E682610EA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b109bfc1ef7e20a72170a83dc9244c8b21ea658c
Commit:        b109bfc1ef7e20a72170a83dc9244c8b21ea658c
Parent:        c3f44a0c66abf8916bebafe2de9da30132cea9e2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 22 16:10:20 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 22 16:24:39 2013 +0200

blkdeactivate: fix endless loop if device(s) given and unable to umount/deactivate

The blkdeactivate script iterates over the list of devices if they're
given as an argument and it tries to umount/deactivate them one by one.

This iteration failed to proceed if any of the umount/deactivation
was unsuccessful - there was a missing "shift" call to move to the
next argument (device) for processing. As a result of this, the same
device was tried again and again, causing an endless loop, never
proceeding to the next device given.
---
 WHATS_NEW                   |    1 +
 scripts/blkdeactivate.sh.in |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2d7792b..c2e511f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Fix endless loop for blkdeactivte <device>... if unable to umount/deactivate.
   Add dev-block-<major>:<minor>.device systemd alias for complete PV tracking.
   Use major:minor as short form of --major and --minor arg for pvscan --cache.
   Remove 2>/dev/null from three lvm commands executed by vgimportclone.
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index b6d0117..f454154 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -323,7 +323,10 @@ deactivate_all() {
 				$LSBLK_READ <<< "`$LSBLK --nodeps $1`"
 
 				# check if the device is not on the skip list already
-				test -z ${SKIP_DEVICE_LIST["$kname"]} || continue
+				test -z ${SKIP_DEVICE_LIST["$kname"]} || {
+					shift
+					continue
+				}
 
 				deactivate
 			else


