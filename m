From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Mar 2014 00:02:21 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20140319000221.016EC60FD8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6eb2ac10ab509a74f83b9333ff195b63d64d8ef
Commit:        b6eb2ac10ab509a74f83b9333ff195b63d64d8ef
Parent:        852a2b98be2c83a3ddb31396f49854a3d14cf6ed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 00:24:09 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 19 00:58:02 2014 +0100

cleanup: indent

---
 lib/metadata/metadata.c |    4 ++--
 tools/pvdisplay.c       |   16 ++++++++--------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c79f223..279043b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4157,7 +4157,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 			       uint64_t status_flags, uint32_t misc_flags)
 {
 	struct volume_group *vg = NULL;
- 	int consistent = 1;
+	int consistent = 1;
 	int consistent_in;
 	uint32_t failure = 0;
 	int already_locked;
@@ -4279,7 +4279,7 @@ bad:
  * *consistent = 1.
  */
 struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
-	      const char *vgid, uint32_t flags)
+			     const char *vgid, uint32_t flags)
 {
 	uint64_t status = UINT64_C(0);
 	uint32_t lock_flags = LCK_VG_READ;
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 198267c..34ec3d5 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -36,18 +36,18 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 			return ret;
 		}
 
-	 	/*
+		/*
 		 * Replace possibly incomplete PV structure with new one
 		 * allocated in vg_read_internal() path.
 		 */
-		 if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			 log_error("Unable to find \"%s\" in volume group \"%s\"",
-				   pv_name, vg->name);
-			 ret = ECMD_FAILED;
-			 goto out;
-		 }
-
-		 pv = pvl->pv;
+		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
+			log_error("Unable to find \"%s\" in volume group \"%s\"",
+				  pv_name, vg->name);
+			ret = ECMD_FAILED;
+			goto out;
+		}
+
+		pv = pvl->pv;
 	}
 
 	if (is_orphan(pv))


