From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 22 Dec 2018 19:12:38 -0500
Subject: master - cleanup: use zalloc
Message-ID: <201812230012.wBN0CclM005365@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=44aeb6d6b8766dc547ba56a7d1580ccb0da974c7
Commit:        44aeb6d6b8766dc547ba56a7d1580ccb0da974c7
Parent:        fc479b2b079735afce810d3d352e367216d5a931
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 22 23:33:23 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 22 23:55:48 2018 +0100

cleanup: use zalloc

Some places forget to use zalloc().
---
 daemons/cmirrord/cluster.c          |   10 ++++------
 daemons/lvmlockd/lvmlockd-core.c    |    3 +--
 daemons/lvmlockd/lvmlockd-dlm.c     |    3 +--
 daemons/lvmlockd/lvmlockd-sanlock.c |    6 ++----
 4 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index c516447..9df321a 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -17,6 +17,7 @@
 #include "link_mon.h"
 #include "local.h"
 #include "lib/mm/xlate.h"
+#include "base/memory/zalloc.h"
 
 /* FIXME: remove this and the code */
 #define CMIRROR_HAS_CHECKPOINT 0
@@ -402,13 +403,12 @@ static struct checkpoint_data *prepare_checkpoint(struct clog_cpg *entry,
 		return NULL;
 	}
 
-	new = malloc(sizeof(*new));
+	new = zalloc(sizeof(*new));
 	if (!new) {
 		LOG_ERROR("Unable to create checkpoint data for %u",
 			  cp_requester);
 		return NULL;
 	}
-	memset(new, 0, sizeof(*new));
 	new->requester = cp_requester;
 	strncpy(new->uuid, entry->name.value, entry->name.length);
 
@@ -643,13 +643,12 @@ static int export_checkpoint(struct checkpoint_data *cp)
 	rq_size += RECOVERING_REGION_SECTION_SIZE;
 	rq_size += cp->bitmap_size * 2; /* clean|sync_bits */
 
-	rq = malloc(rq_size);
+	rq = zalloc(rq_size);
 	if (!rq) {
 		LOG_ERROR("export_checkpoint: "
 			  "Unable to allocate transfer structs");
 		return -ENOMEM;
 	}
-	memset(rq, 0, rq_size);
 
 	dm_list_init(&rq->u.list);
 	rq->u_rq.request_type = DM_ULOG_CHECKPOINT_READY;
@@ -1621,12 +1620,11 @@ int create_cluster_cpg(char *uuid, uint64_t luid)
 			return -EEXIST;
 		}
 
-	new = malloc(sizeof(*new));
+	new = zalloc(sizeof(*new));
 	if (!new) {
 		LOG_ERROR("Unable to allocate memory for clog_cpg");
 		return -ENOMEM;
 	}
-	memset(new, 0, sizeof(*new));
 	dm_list_init(&new->list);
 	new->lowest_id = 0xDEAD;
 	dm_list_init(&new->startup_list);
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index e643d76..1ec3efd 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -405,12 +405,11 @@ struct lockspace *alloc_lockspace(void)
 {
 	struct lockspace *ls;
 
-	if (!(ls = malloc(sizeof(struct lockspace)))) {
+	if (!(ls = zalloc(sizeof(struct lockspace)))) {
 		log_error("out of memory for lockspace");
 		return NULL;
 	}
 
-	memset(ls, 0, sizeof(struct lockspace));
 	INIT_LIST_HEAD(&ls->actions);
 	INIT_LIST_HEAD(&ls->resources);
 	pthread_mutex_init(&ls->mutex, NULL);
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 668c75b..e73be51 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -272,10 +272,9 @@ static int lm_add_resource_dlm(struct lockspace *ls, struct resource *r, int wit
 	int rv;
 
 	if (r->type == LD_RT_GL || r->type == LD_RT_VG) {
-		buf = malloc(sizeof(struct val_blk) + DLM_LVB_LEN);
+		buf = zalloc(sizeof(struct val_blk) + DLM_LVB_LEN);
 		if (!buf)
 			return -ENOMEM;
-		memset(buf, 0, sizeof(struct val_blk) + DLM_LVB_LEN);
 
 		rdd->vb = (struct val_blk *)buf;
 		rdd->lksb.sb_lvbptr = buf + sizeof(struct val_blk);
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 7cbf92d..f960daf 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1393,7 +1393,7 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 		goto fail;
 	}
 
-	lms = malloc(sizeof(struct lm_sanlock));
+	lms = zalloc(sizeof(struct lm_sanlock));
 	if (!lms) {
 		ret = -ENOMEM;
 		goto fail;
@@ -1402,7 +1402,6 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 	memset(lsname, 0, sizeof(lsname));
 	strncpy(lsname, ls->name, SANLK_NAME_LEN);
 
-	memset(lms, 0, sizeof(struct lm_sanlock));
 	memcpy(lms->ss.name, lsname, SANLK_NAME_LEN);
 	lms->ss.host_id_disk.offset = 0;
 	lms->ss.host_id = ls->host_id;
@@ -1615,10 +1614,9 @@ static int lm_add_resource_sanlock(struct lockspace *ls, struct resource *r)
 	/* LD_RT_LV offset is set in each lm_lock call from lv_args. */
 
 	if (r->type == LD_RT_GL || r->type == LD_RT_VG) {
-		rds->vb = malloc(sizeof(struct val_blk));
+		rds->vb = zalloc(sizeof(struct val_blk));
 		if (!rds->vb)
 			return -ENOMEM;
-		memset(rds->vb, 0, sizeof(struct val_blk));
 	}
 
 	return 0;


