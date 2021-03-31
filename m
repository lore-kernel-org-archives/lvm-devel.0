From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:16 +0000 (GMT)
Subject: dev-next - tests: add workaround for older mdadm
Message-ID: <20210331214916.B1AAA3858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5feb99dda68dd492929fff0d7b15d3ef0ab86347
Commit:        5feb99dda68dd492929fff0d7b15d3ef0ab86347
Parent:        0558b223b87b922faa709e7a7e0e6aaa4b7f0c42
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 00:35:28 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 00:35:28 2021 +0100

tests: add workaround for older mdadm

Some older instancies of 'mdadm' opened legs in RW and
closed and opened again and expected exlusive access.
But here udev rule can be fired - so on these versions
slow down whole mdadm runtime by using strace, to
give system a bit more time to finish udev rule.
---
 test/shell/lvm-on-md.sh | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index 9187d44f5..7c14e6748 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -27,6 +27,18 @@ _clear_online_files() {
 
 . lib/inittest
 
+which mdadm || skip
+
+STRACE=
+[ "$DM_DEV_DIR" = "/dev" ] && mdadm -V 2>&1 | grep " v3.2" && {
+	# use this 'trick' to slow down mdadm which otherwise
+	# is racing with udev rule since mdadm internally
+	# opens and closes raid leg devices in RW mode and then
+	# tries to get exlusive access to the leg device during
+	# insertion to kernel and fails during assembly
+        # There could be more affted version of mdadm.
+	STRACE="strace -f -o /dev/null"
+}
 
 # This stops lvm from taking advantage of hints which
 # will have already excluded md components.
@@ -109,7 +121,7 @@ test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 # should not show an active lv
 not dmsetup info $vg-$lv1
 
-mdadm --assemble "$mddev" "$dev1" "$dev2"
+$STRACE mdadm --assemble "$mddev" "$dev1" "$dev2"
 aux udev_wait
 
 not pvs "$dev1"
@@ -264,7 +276,7 @@ test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 not dmsetup info $vg-$lv1
 
 # start the md dev
-mdadm --assemble "$mddev" "$dev1" "$dev2"
+$STRACE mdadm --assemble "$mddev" "$dev1" "$dev2"
 aux udev_wait
 
 not pvs "$dev1"


