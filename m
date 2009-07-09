From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Jul 2009 18:17:48 -0400
Subject: [PATCH 3/4] Move orphan lock inside vg_remove_single.
In-Reply-To: <1247177869-12526-3-git-send-email-dwysocha@redhat.com>
References: <1247177869-12526-1-git-send-email-dwysocha@redhat.com>
	<1247177869-12526-2-git-send-email-dwysocha@redhat.com>
	<1247177869-12526-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1247177869-12526-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move the vg orphan lock inside vg_remove_single, now a complete liblvm
function.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    7 +++++++
 tools/vgremove.c        |    7 -------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5257801..bbfce76 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -390,8 +390,14 @@ int vg_remove_single(vg_t *vg)
 	if (!archive(vg))
 		return 0;
 
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		return 0;
+	}
+
 	if (!vg_remove(vg)) {
 		log_error("vg_remove %s failed", vg_name);
+		unlock_vg(cmd, VG_ORPHANS);
 		return 0;
 	}
 
@@ -425,6 +431,7 @@ int vg_remove_single(vg_t *vg)
 	else
 		log_error("Volume group \"%s\" not properly removed", vg_name);
 
+	unlock_vg(cmd, VG_ORPHANS);
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


