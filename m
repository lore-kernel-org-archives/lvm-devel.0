From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  9 Jul 2015 10:09:01 +0000 (UTC)
Subject: master - coverity: fix possible invalid dereferences
Message-ID: <20150709100901.4E9DC602F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=023cf21848bdf75bade560f6f43b2dea62a54f80
Commit:        023cf21848bdf75bade560f6f43b2dea62a54f80
Parent:        cb305b9fc0ae3f554b71aa3839d091424c660e63
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 9 12:07:34 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 9 12:07:41 2015 +0200

coverity: fix possible invalid dereferences

lib/format1/import-export.c:167: var_deref_op: Dereferencing null pointer "vg->lvm1_system_id"
lib/cache/lvmetad.c:1023: var_deref_op: Dereferencing null pointer "this"
daemons/lvmlockd/lvmlockd-core.c:2659: check_after_deref: Null-checking "act" suggests that it may be null, but it has already been dereferenced on all paths leading to the check
/daemons/lvmetad/lvmetad-core.c:1024: check_after_deref: Null-checking "pvmeta" suggests that it may be null, but it has already been dereferenced on all paths leading to the check
---
 daemons/lvmetad/lvmetad-core.c   |    6 ++----
 daemons/lvmlockd/lvmlockd-core.c |    3 +--
 lib/cache/lvmetad.c              |    3 ++-
 lib/format1/import-export.c      |    2 +-
 4 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index f4e77b7..b4382c7 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -999,7 +999,8 @@ static response pv_gone(lvmetad_state *s, request r)
 
 	DEBUGLOG(s, "pv_gone (updated): %s / %" PRIu64, pvid, device);
 
-	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
+	if (!(pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid)))
+		return reply_unknown("PVID does not exist");
 	vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
 
 	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
@@ -1021,9 +1022,6 @@ static response pv_gone(lvmetad_state *s, request r)
 		dm_free(vgid);
 	}
 
-	if (!pvmeta)
-		return reply_unknown("PVID does not exist");
-
 	if (!alt_device)
 		dm_config_destroy(pvmeta);
 
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 1b7f494..ff5510c 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -2661,8 +2661,7 @@ static int rem_lockspace(struct action *act)
 	}
 	ls->thread_work = 1;
 	ls->thread_stop = 1;
-	if (act)
-		list_add_tail(&act->list, &ls->actions);
+	list_add_tail(&act->list, &ls->actions);
 	pthread_cond_signal(&ls->cond);
 	pthread_mutex_unlock(&ls->mutex);
 	pthread_mutex_unlock(&lockspaces_mutex);
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 783a114..8905640 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1017,7 +1017,8 @@ static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
 	struct _lvmetad_pvscan_baton *b = baton;
 	struct volume_group *this;
 
-	this = mda_is_ignored(mda) ? NULL : mda->ops->vg_read(b->fid, "", mda, NULL, NULL, 1);
+	if (!(this = mda_is_ignored(mda) ? NULL : mda->ops->vg_read(b->fid, "", mda, NULL, NULL, 1)))
+		return 1;
 
 	/* FIXME Also ensure contents match etc. */
 	if (!b->vg || this->seqno > b->vg->seqno)
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 72f6946..275583d 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -164,7 +164,7 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
 	/* Is VG already exported or being exported? */
 	if (vg && vg_is_exported(vg)) {
 		/* Does system_id need setting? */
-		if (!*vg->lvm1_system_id ||
+		if ((vg->lvm1_system_id && !*vg->lvm1_system_id) ||
 		    strncmp(vg->lvm1_system_id, EXPORTED_TAG,
 			    sizeof(EXPORTED_TAG) - 1)) {
 			if (!generate_lvm1_system_id(cmd, (char *)pvd->system_id, EXPORTED_TAG))


