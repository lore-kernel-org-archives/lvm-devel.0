From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Jun 2014 13:24:41 +0000 (UTC)
Subject: master - cleanup: we already know max device name size
Message-ID: <20140617132441.F19F961207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0558b1a0869f9a68d78e80140500874756c70e4d
Commit:        0558b1a0869f9a68d78e80140500874756c70e4d
Parent:        7aef45f9bb8620e194d086ebeeaca0312e8aee04
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 16 12:39:32 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 17 13:43:04 2014 +0200

cleanup: we already know max device name size

Use NAME_LEN constant to simplify creation of device name.
Since the max size should be already tested in validation,
throw INTERNAL_ERROR if the size of vg/lv is bigger then NAME_LEN.
---
 tools/lvconvert.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 731d4c8..75eb565 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -884,15 +884,13 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 	 *   the polldaemon, lvconvert, pvmove code that a comprehensive
 	 *   audit/rework is needed
 	 */
-	int len = strlen(lv->vg->name) + strlen(lv->name) + 2;
-	char *uuid = alloca(sizeof(lv->lvid));
-	char *lv_full_name = alloca(len);
+	char uuid[sizeof(lv->lvid)];
+	char lv_full_name[NAME_LEN];
 
-	if (!uuid || !lv_full_name)
-		return_0;
-
-	if (dm_snprintf(lv_full_name, len, "%s/%s", lv->vg->name, lv->name) < 0)
-		return_0;
+	if (dm_snprintf(lv_full_name, sizeof(lv_full_name), "%s/%s", lv->vg->name, lv->name) < 0) {
+		log_error(INTERNAL_ERROR "Name \"%s/%s\" is too long.", lv->vg->name, lv->name);
+		return 0;
+	}
 
 	memcpy(uuid, &lv->lvid, sizeof(lv->lvid));
 


