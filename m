From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 10 Jul 2009 11:38:53 -0400
Subject: [PATCH 3/5] Move orphan lock inside vg_remove_single.
In-Reply-To: <1247240335-18769-3-git-send-email-dwysocha@redhat.com>
References: <1247240335-18769-1-git-send-email-dwysocha@redhat.com>
	<1247240335-18769-2-git-send-email-dwysocha@redhat.com>
	<1247240335-18769-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1247240335-18769-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move the vg orphan lock inside vg_remove_single, now a complete liblvm
function.  Note that this changes the order of the locks - originally
VG_ORPHAN was obtained first, then the vgname lock.  With the current
policy of non-blocking second locks, this could mean we get a failure
obtaining the orphan lock.  In the case of a vg with lvs being removed,
this could result in the lvs being removed but not the vg.  Such a
scenario could have happened prior though with a different failure.
Other tools were examined for side-effects, and no major problems
were noted.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    7 +++++++
 tools/vgremove.c        |    7 -------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9b19421..a471ed5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -388,8 +388,14 @@ int vg_remove_single(vg_t *vg)
 	if (!archive(vg))
 		return 0;
 
+	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		return 0;
+	}
+
 	if (!vg_remove(vg)) {
 		log_error("vg_remove %s failed", vg->name);
+		unlock_vg(vg->cmd, VG_ORPHANS);
 		return 0;
 	}
 
@@ -423,6 +429,7 @@ int vg_remove_single(vg_t *vg)
 	else
 		log_error("Volume group \"%s\" not properly removed", vg->name);
 
+	unlock_vg(vg->cmd, VG_ORPHANS);
 	return ret;
 }
 
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 1bfff1e..92c10fe 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -56,16 +56,9 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
-	}
-
 	ret = process_each_vg(cmd, argc, argv,
 			      READ_FOR_UPDATE,
 			      NULL, &vgremove_single);
 
-	unlock_vg(cmd, VG_ORPHANS);
-
 	return ret;
 }
-- 
1.6.0.6


