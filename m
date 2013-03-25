From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 25 Mar 2013 15:22:46 +0000 (UTC)
Subject: master - metadata: use PV's internal UNLABELLED_PV flag more consistently
Message-ID: <20130325152246.18CA112EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5c93f3997b11b33742c562b39d60949bf7e6c01d
Commit:        5c93f3997b11b33742c562b39d60949bf7e6c01d
Parent:        32ae07cef1a30064d3269b5e10f2c54f6486c446
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 25 16:21:59 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 25 16:21:59 2013 +0100

metadata: use PV's internal UNLABELLED_PV flag more consistently

Set when new PV created, cleared on PV write.
---
 lib/metadata/metadata.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a913597..911a4c8 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1527,14 +1527,13 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 	log_verbose("Set up physical volume for \"%s\" with %" PRIu64
 		    " available sectors", pv_name, pv_size(pv));
 
+	pv->status |= UNLABELLED_PV;
 	if (write_now) {
 		struct pv_to_create pvc;
 		pvc.pp = pp;
 		pvc.pv = pv;
 		if (!_pvcreate_write(cmd, &pvc))
 			goto bad;
-	} else {
-		pv->status |= UNLABELLED_PV;
 	}
 
 	return pv;
@@ -2572,7 +2571,6 @@ int vg_write(struct volume_group *vg)
         dm_list_iterate_items(pv_to_create, &vg->pvs_to_create) {
 		if (!_pvcreate_write(vg->cmd, pv_to_create))
 			return 0;
-		pv_to_create->pv->status &= ~UNLABELLED_PV;
         }
 
 	/* Write to each copy of the metadata area */
@@ -3779,6 +3777,8 @@ int pv_write(struct cmd_context *cmd __attribute__((unused)),
 	if (!pv->fmt->ops->pv_write(pv->fmt, pv))
 		return_0;
 
+	pv->status &= ~UNLABELLED_PV;
+
 	if (!lvmetad_pv_found(&pv->id, pv->dev, pv->fmt, pv->label_sector,
 			      NULL, NULL))
 		return_0;


