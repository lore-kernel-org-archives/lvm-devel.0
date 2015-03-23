From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 23 Mar 2015 12:40:54 +0000 (UTC)
Subject: master - pvmove: use safe version of iteration when iterating over vg->lvs list in _poll_vg
Message-ID: <20150323124054.5D29660E58@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e7b24d34ff3da1c56718bb7def8a8ecd4258c43
Commit:        6e7b24d34ff3da1c56718bb7def8a8ecd4258c43
Parent:        361e2d8df726e8428ed917939dab54643761b9e4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 23 13:33:57 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 23 13:40:39 2015 +0100

pvmove: use safe version of iteration when iterating over vg->lvs list in _poll_vg

When we're iterating over LVs in _poll_vg fn, we need to use the safe
version of iteration - the LV can be removed from the list which we're
just iterating over if we're finishing or aborting pvmove operation.
---
 tools/polldaemon.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 10ca4a5..53dab96 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -192,7 +192,7 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 		    struct volume_group *vg, struct processing_handle *handle)
 {
 	struct daemon_parms *parms = (struct daemon_parms *) handle->custom_handle;
-	struct lv_list *lvl;
+	struct lv_list *lvl, *tmp_lvl;
 	struct logical_volume *lv;
 	const char *name;
 	int finished;
@@ -202,7 +202,7 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 		return ECMD_FAILED;
 	}
 
-	dm_list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items_safe(lvl, tmp_lvl, &vg->lvs) {
 		lv = lvl->lv;
 		if (!(lv->status & parms->lv_type))
 			continue;


