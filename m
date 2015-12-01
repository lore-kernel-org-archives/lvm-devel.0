From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  1 Dec 2015 15:12:13 +0000 (UTC)
Subject: master - toollib: remove unused function
Message-ID: <20151201151213.3D6A260F67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e43ec15ce0a34ac29c82f232f21a2b0ea7f3a26
Commit:        1e43ec15ce0a34ac29c82f232f21a2b0ea7f3a26
Parent:        aa4932674aa6c7e1f2526781caaa98a1920fd72a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 30 14:17:33 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 1 09:10:01 2015 -0600

toollib: remove unused function

---
 tools/toollib.c |   29 -----------------------------
 1 files changed, 0 insertions(+), 29 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index ce1cdda..f979475 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1997,35 +1997,6 @@ endvg:
 }
 
 /*
- * Copy the contents of a str_list of VG names to a name list, filling
- * in the vgid with NULL (unknown).
- */
-static int _copy_str_to_vgnameid_list(struct cmd_context *cmd, struct dm_list *sll,
-				      struct dm_list *vgnll)
-{
-	const char *vgname;
-	struct dm_str_list *sl;
-	struct vgnameid_list *vgnl;
-
-	dm_list_iterate_items(sl, sll) {
-		vgname = sl->str;
-
-		vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl));
-		if (!vgnl) {
-			log_error("vgnameid_list allocation failed.");
-			return ECMD_FAILED;
-		}
-
-		vgnl->vgid = NULL;
-		vgnl->vg_name = dm_pool_strdup(cmd->mem, vgname);
-
-		dm_list_add(vgnll, &vgnl->list);
-	}
-
-	return ECMD_PROCESSED;
-}
-
-/*
  * Check if a command line VG name is ambiguous, i.e. there are multiple VGs on
  * the system that have the given name.  If *one* VG with the given name is
  * local and the rest are foreign, then use the local VG (removing foreign VGs


