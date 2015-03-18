From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 18 Mar 2015 23:58:16 +0000 (UTC)
Subject: master - pvs: Hide inaccessible clustered PVs.
Message-ID: <20150318235816.D85B86025C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bf74f2997cedb481e0fac21e3aa30fc61f8e5b1
Commit:        5bf74f2997cedb481e0fac21e3aa30fc61f8e5b1
Parent:        87941ccd1706ac9818f0f4828cade1d4cfae622d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Mar 18 23:31:46 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Mar 18 23:31:46 2015 +0000

pvs: Hide inaccessible clustered PVs.

Inaccessible clustered PVs can be hidden from pvs -a in the same way as
foreign PVs, rather than showing them as if they do not belong to a VG.
---
 WHATS_NEW       |    1 +
 tools/toollib.c |   15 +++++++++++++--
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2e50b18..b182925 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Remove inaccessible clustered PVs from 'pvs -a'.
   Don't invalidate cached orphan information while global lock is held.
   Avoid rescan of all devices when requested pvscan for removed device.
   Measure configuration timestamps with nanoseconds when available.
diff --git a/tools/toollib.c b/tools/toollib.c
index 12fe1e2..98e5879 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -175,6 +175,7 @@ const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
  *   and the command option has been used to ignore clustered vgs.
  *
  * Case c covers the other errors returned when reading the VG.
+ *   If *skip is 1, it's OK for the caller to read the list of PVs in the VG.
  */
 static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 		      struct dm_list *arg_vgnames, int allow_inconsistent, int *skip)
@@ -211,7 +212,14 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 		}
 	}
 
+	if ((read_error == FAILED_CLUSTERED)) {
+		*skip = 1;
+		stack;	/* Error already logged */
+		return 1;
+	}
+
 	if (read_error != SUCCESS) {
+		*skip = 0;
 		log_error("Cannot process volume group %s", vg_name);
 		return 1;
 	}
@@ -2718,8 +2726,11 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 		if (_ignore_vg(vg, vg_name, NULL, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret_max = ECMD_FAILED;
-			release_vg(vg);
-			continue;
+			if (!skip) {
+				release_vg(vg);
+				continue;
+			}
+			/* Drop through to eliminate a clustered VG's PVs from the devices list */
 		}
 		
 		/*


