From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jan 2017 10:22:21 +0000 (UTC)
Subject: master - blkdeactivate: also unmount mount point on top of MD device if using blkdeactivate -u
Message-ID: <20170106102221.3ECAF60E0C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d90320f4f161658c6a004631c5685b40202af2cc
Commit:        d90320f4f161658c6a004631c5685b40202af2cc
Parent:        b92a9c3e1ab9972b059ef797136c7e04b4b9368f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 6 11:16:07 2017 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 6 11:16:07 2017 +0100

blkdeactivate: also unmount mount point on top of MD device if using blkdeactivate -u

The blkdeactivate script processes MD devices too so we should unmount
any mount point on top of an MD device if blkdeactivate -u|--umount is
called.

Diagnosed and reported by: Rick Warner <rick@microway.com>
See also https://bugzilla.redhat.com/show_bug.cgi?id=1410585.
---
 WHATS_NEW                   |    1 +
 scripts/blkdeactivate.sh.in |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3fde645..44b1df8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Also unmount mount point on top of MD device if using blkdeactivate -u.
   Restore check preventing resize of cache type volumes (2.02.158).
   Add missing udev sync when flushing dirty cache content.
   vgchange -p accepts only uint32 numbers.
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 443af9c..436c72e 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -171,7 +171,8 @@ device_umount_one() {
 }
 
 device_umount() {
-	test "$devtype" != "lvm" && test "${kname:0:3}" != "dm-" && return 0
+	test "$devtype" != "lvm" && test "${kname:0:3}" != "dm-" \
+          && test "${kname:0:2}" != "md" && return 0
 
 	# FINDMNT is defined only if umount --all-targets is not available.
 	# In that case, read the list of multiple mount points of one device


