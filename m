From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  3 Dec 2013 13:43:54 +0000 (UTC)
Subject: master - vgdisplay: select only active volumes groups if -A option is used
Message-ID: <20131203134354.D51D960F2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6232cac86cea332efb1e538fc8cd1922dc35bd01
Commit:        6232cac86cea332efb1e538fc8cd1922dc35bd01
Parent:        c35394959758ec17389529f95a33bf7f5b15c56b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Dec 3 14:41:25 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Dec 3 14:43:00 2013 +0100

vgdisplay: select only active volumes groups if -A option is used

Where "active" means "at least one LV is active in the volume group".
---
 WHATS_NEW              |    1 +
 man/vgdisplay.8.in     |    3 ++-
 test/shell/covercmd.sh |   22 ++++++++++++++++++++++
 tools/vgdisplay.c      |    4 +++-
 4 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 043b7ef..c91acff 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Select only active volume groups if vgdisplay -A is used.
   Add -p and LVM_LVMETAD_PID env var to lvmetad to change pid file.
   Allow lvmetad to reuse stale socket.
   Only unlink lvmetad socket on error if created by the same process.
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
index 9016a45..4dada16 100644
--- a/man/vgdisplay.8.in
+++ b/man/vgdisplay.8.in
@@ -57,7 +57,8 @@ See \fBlvm\fP(8) for common options and \fBvgs\fP(8) for options given with
 \fB\-\-columns\fP.
 .TP
 .BR \-A ", " \-\-activevolumegroups
-Only select the active volume groups.
+Only select the active volume groups. The volume group is considered active
+if at least one of its logical volumes is active.
 .TP
 .BR \-c ", " \-\-colon
 Generate colon separated output for easier parsing in scripts or programs.
diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index 04074c1..59500d6 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -100,3 +100,25 @@ not lvmchange
 not lvrename $vg
 not lvrename $vg-xxx
 not lvrename $vg  $vg/$lv-rename $vg/$lv
+
+#test vgdisplay -A to select only active VGs
+# all LVs active - VG considered active
+pvcreate -f $dev1 $dev2 $dev3
+
+vgcreate $vg1 $dev1
+lvcreate -l1 $vg1
+lvcreate -l1 $vg1
+
+# at least one LV active - VG considered active
+vgcreate $vg2 $dev2
+lvcreate -l1 $vg2
+lvcreate -l1 $vg2
+
+# no LVs active - VG considered inactive
+vgcreate $vg3 $dev3
+lvcreate -l1 -an -Zn $vg3
+lvcreate -l1 -an -Zn $vg3
+
+vgdisplay -s -A | grep $vg1
+vgdisplay -s -A | grep $vg2
+vgdisplay -s -A | not grep $vg3
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index afc92fe..81ffbd9 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -19,7 +19,9 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg,
 			    void *handle __attribute__((unused)))
 {
-	/* FIXME Do the active check here if activevolumegroups_ARG ? */
+	if (arg_count(cmd, activevolumegroups_ARG) && !lvs_in_vg_activated(vg))
+		return ECMD_PROCESSED;
+
 	vg_check_status(vg, EXPORTED_VG);
 
 	if (arg_count(cmd, colon_ARG)) {


