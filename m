From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 10 Sep 2015 14:50:31 +0000 (UTC)
Subject: master - lvmlockd: check all variations of lvb values
Message-ID: <20150910145031.0C68C610F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3670f095c7d13a8052b129b3a264bb5a06e8b26e
Commit:        3670f095c7d13a8052b129b3a264bb5a06e8b26e
Parent:        f11d690967c9d352cb19076a99de81661ee43343
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 9 14:40:48 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 10 09:47:26 2015 -0500

lvmlockd: check all variations of lvb values

The dlm will often lose the lvb content, so we need to
check quite a few possibilities for lvb values that
were not being checked before.

Refactoring was required to pass the entire lvb value
back to the core code instead of the single value.

The only functional change should be detecting new
lvb states where metadata is now invalidated where
it wasn't before.
---
 daemons/lvmlockd/lvmlockd-core.c     |  313 ++++++++++++++++++++++++----------
 daemons/lvmlockd/lvmlockd-dlm.c      |   97 ++++++-----
 daemons/lvmlockd/lvmlockd-internal.h |   10 +-
 daemons/lvmlockd/lvmlockd-sanlock.c  |   32 ++--
 4 files changed, 297 insertions(+), 155 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 8b78af3..0b0161a 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -873,14 +873,14 @@ static int lm_rem_lockspace(struct lockspace *ls, struct action *act, int free_v
 }
 
 static int lm_lock(struct lockspace *ls, struct resource *r, int mode, struct action *act,
-		   uint32_t *r_version, int *retry, int adopt)
+		   struct val_blk *vb_out, int *retry, int adopt)
 {
 	int rv;
 
 	if (ls->lm_type == LD_LM_DLM)
-		rv = lm_lock_dlm(ls, r, mode, r_version, adopt);
+		rv = lm_lock_dlm(ls, r, mode, vb_out, adopt);
 	else if (ls->lm_type == LD_LM_SANLOCK)
-		rv = lm_lock_sanlock(ls, r, mode, r_version, retry, adopt);
+		rv = lm_lock_sanlock(ls, r, mode, vb_out, retry, adopt);
 	else
 		return -1;
 
@@ -1022,8 +1022,12 @@ static void add_work_action(struct action *act)
 static int res_lock(struct lockspace *ls, struct resource *r, struct action *act, int *retry)
 {
 	struct lock *lk;
-	uint32_t r_version = 0;
-	int rv;
+	struct val_blk vb;
+	uint32_t new_version = 0;
+	int inval_meta;
+	int rv = 0;
+
+	memset(&vb, 0, sizeof(vb));
 
 	if (r->type == LD_RT_LV)
 		log_debug("S %s R %s res_lock mode %s (%s)", ls->name, r->name, mode_str(act->mode), act->lv_name);
@@ -1036,114 +1040,245 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 	if (r->type == LD_RT_LV && act->lv_args[0])
 		memcpy(r->lv_args, act->lv_args, MAX_ARGS);
 
-	rv = lm_lock(ls, r, act->mode, act, &r_version, retry, act->flags & LD_AF_ADOPT);
-	if (rv == -EAGAIN)
-		return rv;
-	if (rv < 0) {
-		log_error("S %s R %s res_lock lm error %d", ls->name, r->name, rv);
-		return rv;
-	}
+	rv = lm_lock(ls, r, act->mode, act, &vb, retry, act->flags & LD_AF_ADOPT);
+
+	if (r->use_vb)
+		log_debug("S %s R %s res_lock %d read vb %x %x %u",
+			  ls->name, r->name, rv, vb.version, vb.flags, vb.r_version);
+	else
+		log_debug("S %s R %s res_lock %d", ls->name, r->name, rv);
 
-	log_debug("S %s R %s res_lock lm done r_version %u",
-		  ls->name, r->name, r_version);
+	if (rv < 0)
+		return rv;
 
 	if (sanlock_gl_dup && ls->sanlock_gl_enabled)
 		act->flags |= LD_AF_DUP_GL_LS;
 
-	/* lm_lock() reads new r_version */
+	/*
+	 * Check new lvb values to decide if lvmetad cache should
+	 * be invalidated.  When we need to invalidate the lvmetad
+	 * cache, but don't have a usable r_version from the lvb,
+	 * send lvmetad new_version 0 which causes it to invalidate
+	 * the VG metdata without comparing against the currently
+	 * cached VG seqno.
+	 */
+
+	inval_meta = 0;
 
-	if ((r_version != r->version) || (!r->version && !r->version_zero_valid)) {
+	if (!r->use_vb) {
+		/* LV locks don't use an lvb. */
+
+	} else if (vb.version && ((vb.version & 0xFF00) > (VAL_BLK_VERSION & 0xFF00))) {
+		log_error("S %s R %s res_lock invalid val_blk version %x flags %x r_version %u",
+			  ls->name, r->name, vb.version, vb.flags, vb.r_version);
+		inval_meta = 1;
+		new_version = 0;
+		rv = -EINVAL;
+
+	} else if (vb.r_version && (vb.r_version == r->version)) {
+		/*
+		 * Common case when the version hasn't changed.
+		 * Do nothing.
+		 */
+	} else if (r->version && vb.r_version && (vb.r_version > r->version)) {
+		/*
+		 * Common case when the version has changed.  Another host
+		 * has changed the data protected by the lock since we last
+		 * acquired it, and increased r_version so we know that our
+		 * cache is invalid.
+		 */
+		log_debug("S %s R %s res_lock got version %u our %u",
+			  ls->name, r->name, vb.r_version, r->version);
+		r->version = vb.r_version;
+		new_version = vb.r_version;
+		r->version_zero_valid = 0;
+		inval_meta = 1;
+
+	} else if (r->version_zero_valid && !vb.r_version) {
+		/*
+		 * The lvb is in a persistent zero state, which will end
+		 * once someone uses the lock and writes a new lvb value.
+		 * Do nothing.
+		 */
+		log_debug("S %s R %s res_lock version_zero_valid still zero", ls->name, r->name);
 
+	} else if (r->version_zero_valid && vb.r_version) {
 		/*
-		 * r_version only increases, so if it goes down, it means the
-		 * dlm lvb became invalid (happens during recovery if the
-		 * resource master leaves).
+		 * Someone has written to the lvb after it was in a
+		 * persistent zero state.  Begin tracking normal
+		 * non-zero changes.  We may or may not have known
+		 * about a previous non-zero version (in r->version).
+		 * If we did, it means the lvb content was lost and
+		 * has now been reinitialized.
+		 *
+		 * If the new reinitialized value is less than the
+		 * previous non-zero value in r->version, then something
+		 * unusual has happened.  For a VG lock, it probably
+		 * means the VG was removed and recreated.  Invalidate
+		 * our cache and begin using the new VG version.  For
+		 * a GL lock, another host may have reinitialized a
+		 * lost/zero lvb with a value less than we'd seen
+		 * before.  Invalidate the cache, and begin using
+		 * the lower version (or continue using our old
+		 * larger version?)
 		 */
-		if (r_version < r->version) {
-			log_debug("S %s R %s res_lock lvb invalid r_version %u prev %u",
-				  ls->name, r->name, r_version, r->version);
+		if (r->version && (r->version >= vb.r_version)) {
+			log_debug("S %s R %s res_lock version_zero_valid got version %u less than our %u",
+				  ls->name, r->name, vb.r_version, r->version);
+			new_version = 0;
+		} else {
+			log_debug("S %s R %s res_lock version_zero_valid got version %u our %u",
+				ls->name, r->name, vb.r_version, r->version);
+			new_version = vb.r_version;
 		}
+		r->version = vb.r_version;
+		r->version_zero_valid = 0;
+		inval_meta = 1;
 
+	} else if (!r->version && vb.r_version) {
 		/*
-		 * New r_version of the lock: means that another
-		 * host has changed data protected by this lock
-		 * since the last time we acquired it.  We
-		 * should invalidate any local cache of the data
-		 * protected by this lock and reread it from disk.
+		 * The first time we've acquired the lock and seen the lvb.
 		 */
-		r->version = r_version;
+		log_debug("S %s R %s res_lock initial version %u", ls->name, r->name, vb.r_version);
+		r->version = vb.r_version;
+		inval_meta = 1;
+		new_version = vb.r_version;
+		r->version_zero_valid = 0;
 
+	} else if (!r->version && !vb.r_version) {
 		/*
-		 * When a new global lock is enabled in a new vg,
-		 * it will have version zero, and the first time
-		 * we use it we need to validate the global cache
-		 * since we don't have any version history to know
-		 * the state of the cache.  The version could remain
-		 * zero for a long time if no global state is changed
-		 * to cause the GL version to be incremented to 1.
+		 * The lock may have never been used to change something.
+		 * (e.g. a new sanlock GL?)
 		 */
+		log_debug("S %s R %s res_lock all versions zero", ls->name, r->name);
+		if (!r->version_zero_valid) {
+			inval_meta = 1;
+			new_version = 0;
+		}
 		r->version_zero_valid = 1;
 
+	} else if (r->version && !vb.r_version) {
 		/*
-		 * r is vglk: tell lvmetad to set the vg invalid
-		 * flag, and provide the new r_version.  If lvmetad finds
-		 * that its cached vg has seqno less than the value
-		 * we send here, it will set the vg invalid flag.
-		 * lvm commands that read the vg from lvmetad, will
-		 * see the invalid flag returned, will reread the
-		 * vg from disk, update the lvmetad copy, and go on.
+		 * The lvb content has been lost or never been initialized.
+		 * It can be lost during dlm recovery when the master node
+		 * is removed.
+		 *
+		 * If we're the next to write the lvb, reinitialze it to the
+		 * new VG seqno, or a new GL counter larger than was seen by
+		 * any hosts before (how to estimate that?)
 		 *
-		 * r is global: tell lvmetad to set the global invalid
-		 * flag.  When commands see this flag returned from lvmetad,
-		 * they will reread metadata from disk, update the lvmetad
-		 * caches, and tell lvmetad to set global invalid to 0.
+		 * If we see non-zero values before we next write to it, use
+		 * those values.
+		 *
+		 * While the lvb values remain zero, the data for the lock
+		 * is unchanged and we don't need to invalidate metadata.
 		 */
+		if ((ls->lm_type == LD_LM_DLM) && !vb.version && !vb.flags)
+			log_debug("S %s R %s res_lock all lvb content is blank",
+				  ls->name, r->name);
+		log_debug("S %s R %s res_lock our version %u got vb %x %x %u",
+			  ls->name, r->name, r->version, vb.version, vb.flags, vb.r_version);
+		r->version_zero_valid = 1;
+		inval_meta = 1;
+		new_version = 0;
 
-		if ((r->type == LD_RT_VG) && lvmetad_connected) {
-			daemon_reply reply;
-			char *uuid;
+	} else if (r->version && vb.r_version && (vb.r_version < r->version)) {
+		/*
+		 * The lvb value has gone backwards, which shouldn't generally happen,
+		 * but could when the dlm lvb is lost and reinitialized, or the VG
+		 * is removed and recreated.
+		 *
+		 * If this is a VG lock, it probably means the VG has been removed
+		 * and recreated while we had the dlm lockspace running.
+		 * FIXME: how does the cache validation and replacement in lvmetad
+		 * work in this case?
+		 */
+		log_debug("S %s R %s res_lock got version %u less than our version %u",
+			  ls->name, r->name, vb.r_version, r->version);
+		r->version = vb.r_version;
+		inval_meta = 1;
+		new_version = 0;
+		r->version_zero_valid = 0;
+	} else {
+		log_debug("S %s R %s res_lock undefined vb condition vzv %d our version %u vb %x %x %u",
+			  ls->name, r->name, r->version_zero_valid, r->version,
+			  vb.version, vb.flags, vb.r_version);
+	}
 
-			log_debug("S %s R %s res_lock set lvmetad vg version %u",
-				  ls->name, r->name, r_version);
+	if (vb.version && vb.r_version && (vb.flags & VBF_REMOVED)) {
+		/* Should we set ls->thread_stop = 1 ? */
+		log_debug("S %s R %s res_lock vb flag REMOVED",
+			  ls->name, r->name);
+		rv = -EREMOVED;
+	}
+
+	if (!lvmetad_connected && inval_meta)
+		log_debug("S %s R %s res_lock no lvmetad connection to invalidate",
+			  ls->name, r->name);
+
+	/*
+	 * r is vglk: tell lvmetad to set the vg invalid
+	 * flag, and provide the new r_version.  If lvmetad finds
+	 * that its cached vg has seqno less than the value
+	 * we send here, it will set the vg invalid flag.
+	 * lvm commands that read the vg from lvmetad, will
+	 * see the invalid flag returned, will reread the
+	 * vg from disk, update the lvmetad copy, and go on.
+	 *
+	 * r is global: tell lvmetad to set the global invalid
+	 * flag.  When commands see this flag returned from lvmetad,
+	 * they will reread metadata from disk, update the lvmetad
+	 * caches, and tell lvmetad to set global invalid to 0.
+	 */
+
+	if (lvmetad_connected && inval_meta && (r->type == LD_RT_VG)) {
+		daemon_reply reply;
+		char *uuid;
+
+		log_debug("S %s R %s res_lock set lvmetad vg version %u",
+			  ls->name, r->name, new_version);
 	
-			if (!ls->vg_uuid[0] || !strcmp(ls->vg_uuid, "none"))
-				uuid = (char *)"none";
-			else
-				uuid = ls->vg_uuid;
+		if (!ls->vg_uuid[0] || !strcmp(ls->vg_uuid, "none"))
+			uuid = (char *)"none";
+		else
+			uuid = ls->vg_uuid;
 
-			pthread_mutex_lock(&lvmetad_mutex);
-			reply = daemon_send_simple(lvmetad_handle, "set_vg_info",
-						   "token = %s", "skip",
-						   "uuid = %s", uuid,
-						   "name = %s", ls->vg_name,
-						   "version = %d", (int)r_version,
-						   NULL);
+		pthread_mutex_lock(&lvmetad_mutex);
+		reply = daemon_send_simple(lvmetad_handle, "set_vg_info",
+					   "token = %s", "skip",
+					   "uuid = %s", uuid,
+					   "name = %s", ls->vg_name,
+					   "version = %d", (int)new_version,
+					   NULL);
 			pthread_mutex_unlock(&lvmetad_mutex);
 
-			if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK"))
-				log_error("set_vg_info in lvmetad failed %d", reply.error);
-			daemon_reply_destroy(reply);
-		}
+		if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK"))
+			log_error("set_vg_info in lvmetad failed %d", reply.error);
+		daemon_reply_destroy(reply);
+	}
 
-		if ((r->type == LD_RT_GL) && lvmetad_connected) {
-			daemon_reply reply;
+	if (lvmetad_connected && inval_meta && (r->type == LD_RT_GL)) {
+		daemon_reply reply;
 
-			log_debug("S %s R %s res_lock set lvmetad global invalid",
-				  ls->name, r->name);
+		log_debug("S %s R %s res_lock set lvmetad global invalid",
+			  ls->name, r->name);
 
-			pthread_mutex_lock(&lvmetad_mutex);
-			reply = daemon_send_simple(lvmetad_handle, "set_global_info",
+		pthread_mutex_lock(&lvmetad_mutex);
+		reply = daemon_send_simple(lvmetad_handle, "set_global_info",
 						   "token = %s", "skip",
 						   "global_invalid = %d", 1,
 						   NULL);
-			pthread_mutex_unlock(&lvmetad_mutex);
+		pthread_mutex_unlock(&lvmetad_mutex);
 
-			if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK"))
-				log_error("set_global_info in lvmetad failed %d", reply.error);
-			daemon_reply_destroy(reply);
-		}
+		if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK"))
+			log_error("set_global_info in lvmetad failed %d", reply.error);
+		daemon_reply_destroy(reply);
 	}
 
+	/*
+	 * Record the new lock state.
+	 */
+
 	r->mode = act->mode;
 
 add_lk:
@@ -1163,7 +1298,7 @@ add_lk:
 
 	list_add_tail(&lk->list, &r->locks);
 
-	return 0;
+	return rv;
 }
 
 static int res_convert(struct lockspace *ls, struct resource *r,
@@ -1320,12 +1455,14 @@ do_unlock:
 		r->version++;
 		lk->version = r->version;
 		r_version = r->version;
+		r->version_zero_valid = 0;
 
 		log_debug("S %s R %s res_unlock r_version inc %u", ls->name, r->name, r_version);
 
 	} else if ((r->type == LD_RT_VG) && (r->mode == LD_LK_EX) && (lk->version > r->version)) {
 		r->version = lk->version;
 		r_version = r->version;
+		r->version_zero_valid = 0;
 
 		log_debug("S %s R %s res_unlock r_version new %u",
 			  ls->name, r->name, r_version);
@@ -1967,15 +2104,18 @@ static struct resource *find_resource_act(struct lockspace *ls,
 		return NULL;
 
 	r->type = act->rt;
-
 	r->mode = LD_LK_UN;
 
-	if (r->type == LD_RT_GL)
+	if (r->type == LD_RT_GL) {
 		strncpy(r->name, R_NAME_GL, MAX_NAME);
-	else if (r->type == LD_RT_VG)
+		r->use_vb = 1;
+	} else if (r->type == LD_RT_VG) {
 		strncpy(r->name, R_NAME_VG, MAX_NAME);
-	else if (r->type == LD_RT_LV)
+		r->use_vb = 1;
+	} else if (r->type == LD_RT_LV) {
 		strncpy(r->name, act->lv_uuid, MAX_NAME);
+		r->use_vb = 0;
+	}
 
 	list_add_tail(&r->list, &ls->resources);
 
@@ -2502,14 +2642,10 @@ static int add_lockspace_thread(const char *ls_name,
 {
 	struct lockspace *ls, *ls2;
 	struct resource *r;
-	uint32_t version = 0;
 	int rv;
 
-	if (act)
-		version = act->version;
-
 	log_debug("add_lockspace_thread %s %s version %u",
-		  lm_str(lm_type), ls_name, version);
+		  lm_str(lm_type), ls_name, act ? act->version : 0);
 
 	if (!(ls = alloc_lockspace()))
 		return -ENOMEM;
@@ -2539,7 +2675,7 @@ static int add_lockspace_thread(const char *ls_name,
 
 	r->type = LD_RT_VG;
 	r->mode = LD_LK_UN;
-	r->version = version;
+	r->use_vb = 1;
 	strncpy(r->name, R_NAME_VG, MAX_NAME);
 	list_add_tail(&r->list, &ls->resources);
 
@@ -4634,6 +4770,7 @@ static int get_lockd_vgs(struct list_head *vg_lockd)
 					goto next;
 				}
 
+				r->use_vb = 0;
 				r->type = LD_RT_LV;
 				strncpy(r->name, lv_uuid, MAX_NAME);
 				if (lock_args)
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 6640821..7f65abc 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -343,7 +343,7 @@ static int to_dlm_mode(int ld_mode)
 }
 
 static int lm_adopt_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
-			uint32_t *r_version)
+			struct val_blk *vb_out)
 {
 	struct lm_dlm *lmd = (struct lm_dlm *)ls->lm_data;
 	struct rd_dlm *rdd = (struct rd_dlm *)r->lm_data;
@@ -352,7 +352,7 @@ static int lm_adopt_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
 	int mode;
 	int rv;
 
-	*r_version = 0;
+	memset(vb_out, 0, sizeof(struct val_blk));
 
 	if (!r->lm_init) {
 		rv = lm_add_resource_dlm(ls, r, 0);
@@ -431,15 +431,13 @@ static int lm_adopt_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
  */
 
 int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
-		uint32_t *r_version, int adopt)
+		struct val_blk *vb_out, int adopt)
 {
 	struct lm_dlm *lmd = (struct lm_dlm *)ls->lm_data;
 	struct rd_dlm *rdd = (struct rd_dlm *)r->lm_data;
 	struct dlm_lksb *lksb;
 	struct val_blk vb;
 	uint32_t flags = 0;
-	uint16_t vb_version;
-	uint16_t vb_flags;
 	int mode;
 	int rv;
 
@@ -447,7 +445,7 @@ int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
 		/* When adopting, we don't follow the normal method
 		   of acquiring a NL lock then converting it to the
 		   desired mode. */
-		return lm_adopt_dlm(ls, r, ld_mode, r_version);
+		return lm_adopt_dlm(ls, r, ld_mode, vb_out);
 	}
 
 	if (!r->lm_init) {
@@ -475,7 +473,7 @@ int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
 	log_debug("S %s R %s lock_dlm", ls->name, r->name);
 
 	if (daemon_test) {
-		*r_version = 0;
+		memset(vb_out, 0, sizeof(struct val_blk));
 		return 0;
 	}
 
@@ -513,35 +511,22 @@ lockrv:
 		if (lksb->sb_flags & DLM_SBF_VALNOTVALID) {
 			log_debug("S %s R %s lock_dlm VALNOTVALID", ls->name, r->name);
 			memset(rdd->vb, 0, sizeof(struct val_blk));
-			*r_version = 0;
+			memset(vb_out, 0, sizeof(struct val_blk));
 			goto out;
 		}
 
+		/*
+		 * 'vb' contains disk endian values, not host endian.
+		 * It is copied directly to rdd->vb which is also kept
+		 * in disk endian form.
+		 * vb_out is returned to the caller in host endian form.
+		 */
 		memcpy(&vb, lksb->sb_lvbptr, sizeof(struct val_blk));
-		vb_version = le16_to_cpu(vb.version);
-		vb_flags = le16_to_cpu(vb.flags);
-
-		if (vb_version && ((vb_version & 0xFF00) > (VAL_BLK_VERSION & 0xFF00))) {
-			log_error("S %s R %s lock_dlm ignore vb_version %x",
-				  ls->name, r->name, vb_version);
-			*r_version = 0;
-			free(rdd->vb);
-			rdd->vb = NULL;
-			lksb->sb_lvbptr = NULL;
-			goto out;
-		}
-
-		*r_version = le32_to_cpu(vb.r_version);
-		memcpy(rdd->vb, &vb, sizeof(vb)); /* rdd->vb saved as le */
+		memcpy(rdd->vb, &vb, sizeof(vb));
 
-		log_debug("S %s R %s lock_dlm get r_version %u flags %x",
-			  ls->name, r->name, *r_version, vb_flags);
-
-		if (vb_flags & VBF_REMOVED) {
-			log_debug("S %s R %s lock_dlm VG has been removed",
-				  ls->name, r->name);
-			return -EREMOVED;
-		}
+		vb_out->version = le16_to_cpu(vb.version);
+		vb_out->flags = le16_to_cpu(vb.flags);
+		vb_out->r_version = le32_to_cpu(vb.r_version);
 	}
 out:
 	return 0;
@@ -602,12 +587,12 @@ int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
 	struct lm_dlm *lmd = (struct lm_dlm *)ls->lm_data;
 	struct rd_dlm *rdd = (struct rd_dlm *)r->lm_data;
 	struct dlm_lksb *lksb = &rdd->lksb;
+	struct val_blk vb_prev;
+	struct val_blk vb_next;
 	uint32_t flags = 0;
+	int new_vb = 0;
 	int rv;
 
-	log_debug("S %s R %s unlock_dlm r_version %u flags %x",
-		  ls->name, r->name, r_version, lmu_flags);
-
 	/*
 	 * Do not set PERSISTENT, because we don't need an orphan
 	 * NL lock to protect anything.
@@ -616,22 +601,45 @@ int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
 	flags |= LKF_CONVERT;
 
 	if (rdd->vb && (r->mode == LD_LK_EX)) {
-		if (!rdd->vb->version) {
-			/* first time vb has been written */
-			rdd->vb->version = cpu_to_le16(VAL_BLK_VERSION);
+
+		/* vb_prev and vb_next are in disk endian form */
+		memcpy(&vb_prev, rdd->vb, sizeof(struct val_blk));
+		memcpy(&vb_next, rdd->vb, sizeof(struct val_blk));
+
+		if (!vb_prev.version) {
+			vb_next.version = cpu_to_le16(VAL_BLK_VERSION);
+			new_vb = 1;
 		}
-		if (r_version)
-			rdd->vb->r_version = cpu_to_le32(r_version);
 
-		if ((lmu_flags & LMUF_FREE_VG) && (r->type == LD_RT_VG))
-			rdd->vb->flags = cpu_to_le16(VBF_REMOVED);
+		if ((lmu_flags & LMUF_FREE_VG) && (r->type == LD_RT_VG)) {
+			vb_next.flags = cpu_to_le16(VBF_REMOVED);
+			new_vb = 1;
+		}
 
-		memcpy(lksb->sb_lvbptr, rdd->vb, sizeof(struct val_blk));
+		if (r_version) {
+			vb_next.r_version = cpu_to_le32(r_version);
+			new_vb = 1;
+		}
 
-		log_debug("S %s R %s unlock_dlm set r_version %u",
-			  ls->name, r->name, r_version);
+		if (new_vb) {
+			memcpy(rdd->vb, &vb_next, sizeof(struct val_blk));
+			memcpy(lksb->sb_lvbptr, &vb_next, sizeof(struct val_blk));
+
+			log_debug("S %s R %s unlock_dlm vb old %x %x %u new %x %x %u",
+				  ls->name, r->name,
+				  le16_to_cpu(vb_prev.version),
+				  le16_to_cpu(vb_prev.flags),
+				  le32_to_cpu(vb_prev.r_version),
+				  le16_to_cpu(vb_next.version),
+				  le16_to_cpu(vb_next.flags),
+				  le32_to_cpu(vb_next.r_version));
+		} else {
+			log_debug("S %s R %s unlock_dlm vb unchanged", ls->name, r->name);
+		}
 
 		flags |= LKF_VALBLK;
+	} else {
+		log_debug("S %s R %s unlock_dlm", ls->name, r->name);
 	}
 
 	if (daemon_test)
@@ -700,3 +708,4 @@ int lm_is_running_dlm(void)
 		return 0;
 	return 1;
 }
+
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index a58976f..6bdd4c7 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -143,9 +143,9 @@ struct resource {
 	unsigned int lm_init : 1;	/* lm_data is initialized */
 	unsigned int adopt : 1;		/* temp flag in remove_inactive_lvs */
 	unsigned int version_zero_valid : 1;
+	unsigned int use_vb : 1;
 	struct list_head locks;
 	struct list_head actions;
-	struct val_blk *vb;
 	char lv_args[MAX_ARGS+1];
 	char lm_data[0];		/* lock manager specific data */
 };
@@ -356,7 +356,7 @@ int lm_prepare_lockspace_dlm(struct lockspace *ls);
 int lm_add_lockspace_dlm(struct lockspace *ls, int adopt);
 int lm_rem_lockspace_dlm(struct lockspace *ls, int free_vg);
 int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
-		uint32_t *r_version, int adopt);
+		struct val_blk *vb_out, int adopt);
 int lm_convert_dlm(struct lockspace *ls, struct resource *r,
 		   int ld_mode, uint32_t r_version);
 int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
@@ -394,7 +394,7 @@ static inline int lm_rem_lockspace_dlm(struct lockspace *ls, int free_vg)
 }
 
 static inline int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
-		uint32_t *r_version, int adopt)
+		struct val_blk *vb_out, int adopt)
 {
 	return -1;
 }
@@ -448,7 +448,7 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls);
 int lm_add_lockspace_sanlock(struct lockspace *ls, int adopt);
 int lm_rem_lockspace_sanlock(struct lockspace *ls, int free_vg);
 int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
-		    uint32_t *r_version, int *retry, int adopt);
+		    struct val_blk *vb_out, int *retry, int adopt);
 int lm_convert_sanlock(struct lockspace *ls, struct resource *r,
 		       int ld_mode, uint32_t r_version);
 int lm_unlock_sanlock(struct lockspace *ls, struct resource *r,
@@ -506,7 +506,7 @@ static inline int lm_rem_lockspace_sanlock(struct lockspace *ls, int free_vg)
 }
 
 static inline int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
-		    uint32_t *r_version, int *retry, int adopt)
+		    struct val_blk *vb_out, int *retry, int adopt)
 {
 	return -1;
 }
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 4317aad..1e691eb 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1300,7 +1300,7 @@ int lm_rem_resource_sanlock(struct lockspace *ls, struct resource *r)
 }
 
 int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
-		    uint32_t *r_version, int *retry, int adopt)
+		    struct val_blk *vb_out, int *retry, int adopt)
 {
 	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
 	struct rd_sanlock *rds = (struct rd_sanlock *)r->lm_data;
@@ -1308,7 +1308,6 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 	uint64_t lock_lv_offset;
 	uint32_t flags = 0;
 	struct val_blk vb;
-	uint16_t vb_version;
 	int added = 0;
 	int rv;
 
@@ -1384,7 +1383,7 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 		  (unsigned long long)rs->disks[0].offset);
 
 	if (daemon_test) {
-		*r_version = 0;
+		memset(vb_out, 0, sizeof(struct val_blk));
 		return 0;
 	}
 
@@ -1501,26 +1500,23 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 		rv = sanlock_get_lvb(0, rs, (char *)&vb, sizeof(vb));
 		if (rv < 0) {
 			log_error("S %s R %s lock_san get_lvb error %d", ls->name, r->name, rv);
-			*r_version = 0;
+			memset(rds->vb, 0, sizeof(struct val_blk));
+			memset(vb_out, 0, sizeof(struct val_blk));
 			goto out;
 		}
 
-		vb_version = le16_to_cpu(vb.version);
-
-		if (vb_version && ((vb_version & 0xFF00) > (VAL_BLK_VERSION & 0xFF00))) {
-			log_error("S %s R %s lock_san ignore vb_version %x",
-				  ls->name, r->name, vb_version);
-			*r_version = 0;
-			free(rds->vb);
-			rds->vb = NULL;
-			goto out;
-		}
+		/*
+		 * 'vb' contains disk endian values, not host endian.
+		 * It is copied directly to rrs->vb which is also kept
+		 * in disk endian form.
+		 * vb_out is returned to the caller in host endian form.
+		 */
 
-		*r_version = le32_to_cpu(vb.r_version);
-		memcpy(rds->vb, &vb, sizeof(vb)); /* rds->vb saved as le */
+		memcpy(rds->vb, &vb, sizeof(vb));
 
-		log_debug("S %s R %s lock_san get r_version %u",
-			  ls->name, r->name, *r_version);
+		vb_out->version = le16_to_cpu(vb.version);
+		vb_out->flags = le16_to_cpu(vb.flags);
+		vb_out->r_version = le32_to_cpu(vb.r_version);
 	}
 out:
 	return rv;


