From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:28 +0000 (GMT)
Subject: dev-next - tests: use aux mdadm_assemble wrapper
Message-ID: <20210331214928.280703857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=02e02a5ccc7275c23e59e65df25287c8f82276fa
Commit:        02e02a5ccc7275c23e59e65df25287c8f82276fa
Parent:        4c59b2aa216cb5649fe5e3f54230e85ee994869b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 16:07:24 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 20:39:41 2021 +0100

tests: use aux mdadm_assemble wrapper

---
 test/shell/lvm-on-md.sh            | 19 ++-----------------
 test/shell/pvcreate-md-fake-hdr.sh |  4 ++--
 2 files changed, 4 insertions(+), 19 deletions(-)

diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index 7c14e6748..d2810b8cf 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -27,19 +27,6 @@ _clear_online_files() {
 
 . lib/inittest
 
-which mdadm || skip
-
-STRACE=
-[ "$DM_DEV_DIR" = "/dev" ] && mdadm -V 2>&1 | grep " v3.2" && {
-	# use this 'trick' to slow down mdadm which otherwise
-	# is racing with udev rule since mdadm internally
-	# opens and closes raid leg devices in RW mode and then
-	# tries to get exlusive access to the leg device during
-	# insertion to kernel and fails during assembly
-        # There could be more affted version of mdadm.
-	STRACE="strace -f -o /dev/null"
-}
-
 # This stops lvm from taking advantage of hints which
 # will have already excluded md components.
 
@@ -121,8 +108,7 @@ test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 # should not show an active lv
 not dmsetup info $vg-$lv1
 
-$STRACE mdadm --assemble "$mddev" "$dev1" "$dev2"
-aux udev_wait
+aux mdadm_assemble "$mddev" "$dev1" "$dev2"
 
 not pvs "$dev1"
 not pvs "$dev2"
@@ -276,8 +262,7 @@ test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 not dmsetup info $vg-$lv1
 
 # start the md dev
-$STRACE mdadm --assemble "$mddev" "$dev1" "$dev2"
-aux udev_wait
+aux mdadm_assemble "$mddev" "$dev1" "$dev2"
 
 not pvs "$dev1"
 not pvs "$dev2"
diff --git a/test/shell/pvcreate-md-fake-hdr.sh b/test/shell/pvcreate-md-fake-hdr.sh
index 1550bc4c0..7a16ef5e4 100644
--- a/test/shell/pvcreate-md-fake-hdr.sh
+++ b/test/shell/pvcreate-md-fake-hdr.sh
@@ -88,8 +88,8 @@ if mdadm --detail "$mddev" ; then
 fi
 
 # now reassemble array from  PV1 & PV2
-mdadm --assemble --verbose "$mddev" "$dev1" "$dev2"
-aux udev_wait
+aux mdadm_assemble --verbose "$mddev" "$dev1" "$dev2"
+
 sleep 1
 
 # and let 'fake hdr' to be fixed from master/primary leg


