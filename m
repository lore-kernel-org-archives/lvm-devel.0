From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 15 Jun 2009 15:29:23 -0400
Subject: [PATCH] Add --repair option to vgck.
Message-ID: <1245094163-13196-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Repair option will correct inconsistent metadata.  We could add other
correction options but for now it suffices that vgck has the ability
to actually correct some inconsistencies rather than just checking
for them.  Also add an output line for each vg that checks out
successfully.  This gives the user feedback on what precisely was
checked and is known to be correct.
Partially addresses rhbz:
https://bugzilla.redhat.com/show_bug.cgi?id=248191

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/vgck.8.in    |    7 ++++++-
 tools/commands.h |    4 +++-
 tools/vgck.c     |   17 ++++++++++++++---
 3 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/man/vgck.8.in b/man/vgck.8.in
index 2e5d926..0822cb8 100644
--- a/man/vgck.8.in
+++ b/man/vgck.8.in
@@ -3,10 +3,15 @@
 vgck \- check volume group metadata
 .SH SYNOPSIS
 .B vgck
-[\-d|\-\-debug] [\-h|\-?|\-\-help] [\-v|\-\-verbose] [VolumeGroupName...]
+[\-d|\-\-debug] [\-h|\-?|\-\-help] [\-\-repair] [\-v|\-\-verbose] [VolumeGroupName...]
 .SH DESCRIPTION
 vgck checks LVM metadata for each named volume group for consistency.
 .SH OPTIONS
+.TP
+.I \-\-repair
+Attempt to repair the volume group metadata if inconsistency found.
+.br
+.TP
 See \fBlvm\fP for common options.
 .SH SEE ALSO
 .BR lvm (8),
diff --git a/tools/commands.h b/tools/commands.h
index ee39bf9..9664ef2 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -698,9 +698,11 @@ xx(vgck,
    "vgck "
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
+   "\t[--repair]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
-   "\t[VolumeGroupName...]\n" )
+   "\t[VolumeGroupName...]\n",
+   repair_ARG)
 
 xx(vgconvert,
    "Change volume group metadata format",
diff --git a/tools/vgck.c b/tools/vgck.c
index 977f447..266c800 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -27,12 +27,23 @@ static int vgck_single(struct cmd_context *cmd __attribute((unused)),
 	if (!vg_validate(vg))
 		return ECMD_FAILED;
 
+	log_print("No problems found with metadata on volume group %s\n",
+		  vg_name);
 	return ECMD_PROCESSED;
 }
 
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
-	return process_each_vg(cmd, argc, argv, LCK_VG_READ,
-			       VG_INCONSISTENT_ABORT, NULL,
-			       &vgck_single);
+	int repair = arg_count(cmd, repair_ARG);
+
+	if (repair) {
+		cmd->handles_missing_pvs = 1;
+		return process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
+				       VG_INCONSISTENT_REPAIR, NULL,
+				       &vgck_single);
+	}
+	else
+		return process_each_vg(cmd, argc, argv, LCK_VG_READ,
+				       VG_INCONSISTENT_ABORT, NULL,
+				       &vgck_single);
 }
-- 
1.6.0.6


