From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Jul 2009 18:17:49 -0400
Subject: [PATCH 4/4] Move orphan lock obtain/release inside vg_extend().
In-Reply-To: <1247177869-12526-4-git-send-email-dwysocha@redhat.com>
References: <1247177869-12526-1-git-send-email-dwysocha@redhat.com>
	<1247177869-12526-2-git-send-email-dwysocha@redhat.com>
	<1247177869-12526-3-git-send-email-dwysocha@redhat.com>
	<1247177869-12526-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1247177869-12526-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

With this change we now have vgcreate/vgextend liblvm functions.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   12 ++++++++++--
 tools/vgcreate.c        |    8 --------
 tools/vgextend.c        |    7 -------
 3 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index bbfce76..5ff28d5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -439,6 +439,13 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 {
 	int i;
 	struct physical_volume *pv;
+	struct cmd_context *cmd = vg->cmd;
+
+	/* FIXME: orphan lock needs tied to vg handle or inside library call */
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		return 0;
+	}
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
@@ -447,18 +454,19 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 				  "physical volume", pv_names[i]);
 			goto bad;
 		}
-		
 		if (!add_pv_to_vg(vg, pv_names[i], pv))
 			goto bad;
 	}
 
 /* FIXME Decide whether to initialise and add new mdahs to format instance */
 
+	unlock_vg(cmd, VG_ORPHANS);
 	return 1;
-	
+
       bad:
 	log_error("Unable to add physical volume '%s' to "
 		  "volume group '%s'.", pv_names[i], vg->name);
+	unlock_vg(cmd, VG_ORPHANS);
 	return 0;
 }
 
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 7cfd0f2..c41c50f 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -46,12 +46,6 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (validate_vg_create_params(cmd, &vp_new))
 	    return EINVALID_CMD_LINE;
 
-	/* FIXME: orphan lock needs tied to vg handle or inside library call */
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
-	}
-
 	/* Create the new VG */
 	vg = vg_create(cmd, vp_new.vg_name);
 	if (vg_read_error(vg))
@@ -113,7 +107,6 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	unlock_vg(cmd, vp_new.vg_name);
-	unlock_vg(cmd, VG_ORPHANS);
 
 	backup(vg);
 
@@ -126,6 +119,5 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 bad:
 	vg_release(vg);
 	unlock_vg(cmd, vp_new.vg_name);
-	unlock_vg(cmd, VG_ORPHANS);
 	return ECMD_FAILED;
 }
diff --git a/tools/vgextend.c b/tools/vgextend.c
index a08d4db..728d9f4 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -36,17 +36,11 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	argc--;
 	argv++;
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
-	}
-
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL,
 				READ_REQUIRE_RESIZEABLE);
 	if (vg_read_error(vg)) {
 		vg_release(vg);
-		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 /********** FIXME
@@ -77,6 +71,5 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 
 error:
 	unlock_and_release_vg(cmd, vg, vg_name);
-	unlock_vg(cmd, VG_ORPHANS);
 	return r;
 }
-- 
1.6.0.6


