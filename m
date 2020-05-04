From: David Teigland <teigland@sourceware.org>
Date: Mon,  4 May 2020 18:40:30 +0000 (GMT)
Subject: master - lvmlockd: replace lock adopt info source
Message-ID: <20200504184030.59F4A3870909@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5263551a2d14e52a3f62152616bb8fb9ac8c384c
Commit:        5263551a2d14e52a3f62152616bb8fb9ac8c384c
Parent:        d945b53ff7076bf7713f5e3b9ad7b79ed1db14c0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon May 4 13:35:03 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 4 13:35:03 2020 -0500

lvmlockd: replace lock adopt info source

The lock adopt feature was disabled since it had used
lvmetad as a source of info.  This replaces the lvmetad
info with a local file and enables the adopt feature again
(enabled with lvmlockd --adopt 1).
---
 daemons/lvmlockd/lvmlockd-client.h   |   1 +
 daemons/lvmlockd/lvmlockd-core.c     | 370 +++++++++++++++++------------------
 daemons/lvmlockd/lvmlockd-dlm.c      |   8 +-
 daemons/lvmlockd/lvmlockd-internal.h |   1 +
 man/lvmlockd.8_main                  |  14 +-
 5 files changed, 207 insertions(+), 187 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-client.h b/daemons/lvmlockd/lvmlockd-client.h
index 16d16132a..62ffb732a 100644
--- a/daemons/lvmlockd/lvmlockd-client.h
+++ b/daemons/lvmlockd/lvmlockd-client.h
@@ -14,6 +14,7 @@
 #include "libdaemon/client/daemon-client.h"
 
 #define LVMLOCKD_SOCKET DEFAULT_RUN_DIR "/lvmlockd.socket"
+#define LVMLOCKD_ADOPT_FILE DEFAULT_RUN_DIR "/lvmlockd.adopt"
 
 /* Wrappers to open/close connection */
 
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 39275fb17..84272c4d7 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -38,6 +38,8 @@
 #define EXTERN
 #include "lvmlockd-internal.h"
 
+static int str_to_mode(const char *str);
+
 /*
  * Basic operation of lvmlockd
  *
@@ -142,6 +144,8 @@ static const char *lvmlockd_protocol = "lvmlockd";
 static const int lvmlockd_protocol_version = 1;
 static int daemon_quit;
 static int adopt_opt;
+static uint32_t adopt_update_count;
+static const char *adopt_file;
 
 /*
  * We use a separate socket for dumping daemon info.
@@ -811,6 +815,144 @@ int version_from_args(char *args, unsigned int *major, unsigned int *minor, unsi
 	return 0;
 }
 
+/*
+ * Write new info when a command exits if that command has acquired a new LV
+ * lock.  If the command has released an LV lock we don't bother updating the
+ * info.  When adopting, we eliminate any LV lock adoptions if there is no dm
+ * device for that LV.  If lvmlockd is terminated after acquiring but before
+ * writing this file, those LV locks would not be adopted on restart.
+ */
+
+#define ADOPT_VERSION_MAJOR 1
+#define ADOPT_VERSION_MINOR 0
+
+static void write_adopt_file(void)
+{
+	struct lockspace *ls;
+	struct resource *r;
+	struct lock *lk;
+	time_t t;
+	FILE *fp;
+
+	if (!(fp = fopen(adopt_file, "w")))
+		return;
+
+	adopt_update_count++;
+
+	t = time(NULL);
+	fprintf(fp, "lvmlockd adopt_version %u.%u pid %d updates %u %s",
+		ADOPT_VERSION_MAJOR, ADOPT_VERSION_MINOR, getpid(), adopt_update_count, ctime(&t));
+
+	pthread_mutex_lock(&lockspaces_mutex);
+	list_for_each_entry(ls, &lockspaces, list) {
+		if (ls->lm_type == LD_LM_DLM && !strcmp(ls->name, gl_lsname_dlm))
+			continue;
+		fprintf(fp, "VG: %38s %s %s %s\n",
+			ls->vg_uuid, ls->vg_name, lm_str(ls->lm_type), ls->vg_args);
+		list_for_each_entry(r, &ls->resources, list) {
+			if (r->type != LD_RT_LV)
+				continue;
+			if ((r->mode != LD_LK_EX) && (r->mode != LD_LK_SH))
+				continue;
+			list_for_each_entry(lk, &r->locks, list) {
+				fprintf(fp, "LV: %38s %s %s %s %u\n",
+					ls->vg_uuid, r->name, r->lv_args, mode_str(r->mode), r->version);
+			}
+		}
+	}
+	pthread_mutex_unlock(&lockspaces_mutex);
+
+	fflush(fp);
+	fclose(fp);
+}
+
+static int read_adopt_file(struct list_head *vg_lockd)
+{
+	char adopt_line[512];
+	char vg_uuid[72];
+	char lm_type_str[16];
+	char mode[8];
+	struct lockspace *ls, *ls2;
+	struct resource *r;
+	FILE *fp;
+
+	if (MAX_ARGS != 64 || MAX_NAME != 64)
+		return -1;
+
+	if (!(fp = fopen(adopt_file, "r")))
+		return 0;
+
+	while (fgets(adopt_line, sizeof(adopt_line), fp)) {
+		if (adopt_line[0] == '#')
+			continue;
+		else if (!strncmp(adopt_line, "lvmlockd", 8)) {
+			unsigned int v_major = 0, v_minor = 0;
+			sscanf(adopt_line, "lvmlockd adopt_version %u.%u", &v_major, &v_minor);
+			if (v_major != ADOPT_VERSION_MAJOR)
+				goto fail;
+
+		} else if (!strncmp(adopt_line, "VG:", 3)) {
+			if (!(ls = alloc_lockspace()))
+				goto fail;
+
+			memset(vg_uuid, 0, sizeof(vg_uuid));
+
+			if (sscanf(adopt_line, "VG: %63s %64s %16s %64s",
+				   vg_uuid, ls->vg_name, lm_type_str, ls->vg_args) != 4) {
+				goto fail;
+			}
+
+			memcpy(ls->vg_uuid, vg_uuid, 64);
+
+			if ((ls->lm_type = str_to_lm(lm_type_str)) < 0)
+				goto fail;
+
+			list_add(&ls->list, vg_lockd);
+
+		} else if (!strncmp(adopt_line, "LV:", 3)) {
+			if (!(r = alloc_resource()))
+				goto fail;
+
+			r->type = LD_RT_LV;
+
+			memset(vg_uuid, 0, sizeof(vg_uuid));
+
+			if (sscanf(adopt_line, "LV: %64s %64s %s %8s %u",
+				   vg_uuid, r->name, r->lv_args, mode, &r->version) != 5) {
+				goto fail;
+			}
+
+			if ((r->adopt_mode = str_to_mode(mode)) == LD_LK_IV)
+				goto fail;
+
+			if (ls && !memcmp(ls->vg_uuid, vg_uuid, 64)) {
+				list_add(&r->list, &ls->resources);
+				r = NULL;
+			} else {
+				list_for_each_entry(ls2, vg_lockd, list) {
+					if (memcmp(ls2->vg_uuid, vg_uuid, 64))
+						continue;
+					list_add(&r->list, &ls2->resources);
+					r = NULL;
+					break;
+				}
+			}
+
+			if (r) {
+				log_error("No lockspace found for resource %s vg_uuid %s", r->name, vg_uuid);
+				goto fail;
+			}
+		}
+	}
+
+	fclose(fp);
+	return 0;
+
+fail:
+	fclose(fp);
+	return -1;
+}
+
 /*
  * These are few enough that arrays of function pointers can
  * be avoided.
@@ -4689,6 +4831,7 @@ static void *client_thread_main(void *arg_in)
 	struct client *cl;
 	struct action *act;
 	struct action *act_un;
+	uint32_t lock_acquire_count = 0, lock_acquire_written = 0;
 	int rv;
 
 	while (1) {
@@ -4720,6 +4863,9 @@ static void *client_thread_main(void *arg_in)
 				rv = -1;
 			}
 
+			if (act->flags & LD_AF_LV_LOCK)
+				lock_acquire_count++;
+
 			/*
 			 * The client failed after we acquired an LV lock for
 			 * it, but before getting this reply saying it's done.
@@ -4741,6 +4887,11 @@ static void *client_thread_main(void *arg_in)
 			continue;
 		}
 
+		if (adopt_opt && (lock_acquire_count > lock_acquire_written)) {
+			lock_acquire_written = lock_acquire_count;
+			write_adopt_file();
+		}
+
 		/*
 		 * Queue incoming actions for lockspace threads
 		 */
@@ -4814,6 +4965,8 @@ static void *client_thread_main(void *arg_in)
 			pthread_mutex_unlock(&client_mutex);
 	}
 out:
+	if (adopt_opt && lock_acquire_written)
+		unlink(adopt_file);
 	return NULL;
 }
 
@@ -4846,180 +4999,6 @@ static void close_client_thread(void)
 		log_error("pthread_join client_thread error %d", perrno);
 }
 
-/*
- * Get a list of all VGs with a lockd type (sanlock|dlm).
- * We'll match this list against a list of existing lockspaces that are
- * found in the lock manager.
- *
- * For each of these VGs, also create a struct resource on ls->resources to
- * represent each LV in the VG that uses a lock.  For each of these LVs
- * that are active, we'll attempt to adopt a lock.
- */
-
-static int get_lockd_vgs(struct list_head *vg_lockd)
-{
-	/* FIXME: get VGs some other way */
-	return -1;
-#if 0
-	struct list_head update_vgs;
-	daemon_reply reply;
-	struct dm_config_node *cn;
-	struct dm_config_node *metadata;
-	struct dm_config_node *md_cn;
-	struct dm_config_node *lv_cn;
-	struct lockspace *ls, *safe;
-	struct resource *r;
-	const char *vg_name;
-	const char *vg_uuid;
-	const char *lv_uuid;
-	const char *lock_type;
-	const char *lock_args;
-	char find_str_path[PATH_MAX];
-	int rv = 0;
-
-	INIT_LIST_HEAD(&update_vgs);
-
-	reply = send_lvmetad("vg_list", "token = %s", "skip", NULL);
-
-	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
-		log_error("vg_list from lvmetad failed %d", reply.error);
-		rv = -EINVAL;
-		goto destroy;
-	}
-
-	if (!(cn = dm_config_find_node(reply.cft->root, "volume_groups"))) {
-		log_error("get_lockd_vgs no vgs");
-		rv = -EINVAL;
-		goto destroy;
-	}
-
-	/* create an update_vgs list of all vg uuids */
-
-	for (cn = cn->child; cn; cn = cn->sib) {
-		vg_uuid = cn->key;
-
-		if (!(ls = alloc_lockspace())) {
-			rv = -ENOMEM;
-			break;
-		}
-
-		strncpy(ls->vg_uuid, vg_uuid, 64);
-		list_add_tail(&ls->list, &update_vgs);
-		log_debug("get_lockd_vgs %s", vg_uuid);
-	}
- destroy:
-	daemon_reply_destroy(reply);
-
-	if (rv < 0)
-		goto out;
-
-	/* get vg_name and lock_type for each vg uuid entry in update_vgs */
-
-	list_for_each_entry(ls, &update_vgs, list) {
-		reply = send_lvmetad("vg_lookup",
-				     "token = %s", "skip",
-				     "uuid = %s", ls->vg_uuid,
-				     NULL);
-
-		if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
-			log_error("vg_lookup from lvmetad failed %d", reply.error);
-			rv = -EINVAL;
-			goto next;
-		}
-
-		vg_name = daemon_reply_str(reply, "name", NULL);
-		if (!vg_name) {
-			log_error("get_lockd_vgs %s no name", ls->vg_uuid);
-			rv = -EINVAL;
-			goto next;
-		}
-
-		strncpy(ls->vg_name, vg_name, MAX_NAME);
-
-		metadata = dm_config_find_node(reply.cft->root, "metadata");
-		if (!metadata) {
-			log_error("get_lockd_vgs %s name %s no metadata",
-				  ls->vg_uuid, ls->vg_name);
-			rv = -EINVAL;
-			goto next;
-		}
-
-		lock_type = dm_config_find_str(metadata, "metadata/lock_type", NULL);
-		ls->lm_type = str_to_lm(lock_type);
-
-		if ((ls->lm_type != LD_LM_SANLOCK) && (ls->lm_type != LD_LM_DLM)) {
-			log_debug("get_lockd_vgs %s not lockd type", ls->vg_name);
-			continue;
-		}
-
-		lock_args = dm_config_find_str(metadata, "metadata/lock_args", NULL);
-		if (lock_args)
-			strncpy(ls->vg_args, lock_args, MAX_ARGS);
-
-		log_debug("get_lockd_vgs %s lock_type %s lock_args %s",
-			  ls->vg_name, lock_type, lock_args ?: "none");
-
-		/*
-		 * Make a record (struct resource) of each lv that uses a lock.
-		 * For any lv that uses a lock, we'll check if the lv is active
-		 * and if so try to adopt a lock for it.
-		 */
-
-		for (md_cn = metadata->child; md_cn; md_cn = md_cn->sib) {
-			if (strcmp(md_cn->key, "logical_volumes"))
-				continue;
-
-			for (lv_cn = md_cn->child; lv_cn; lv_cn = lv_cn->sib) {
-				snprintf(find_str_path, PATH_MAX, "%s/lock_args", lv_cn->key);
-				lock_args = dm_config_find_str(lv_cn, find_str_path, NULL);
-				if (!lock_args)
-					continue;
-
-				snprintf(find_str_path, PATH_MAX, "%s/id", lv_cn->key);
-				lv_uuid = dm_config_find_str(lv_cn, find_str_path, NULL);
-
-				if (!lv_uuid) {
-					log_error("get_lock_vgs no lv id for name %s", lv_cn->key);
-					continue;
-				}
-
-				if (!(r = alloc_resource())) {
-					rv = -ENOMEM;
-					goto next;
-				}
-
-				r->use_vb = 0;
-				r->type = LD_RT_LV;
-				strncpy(r->name, lv_uuid, MAX_NAME);
-				if (lock_args)
-					strncpy(r->lv_args, lock_args, MAX_ARGS);
-				list_add_tail(&r->list, &ls->resources);
-				log_debug("get_lockd_vgs %s lv %s %s (name %s)",
-					  ls->vg_name, r->name, lock_args ? lock_args : "", lv_cn->key);
-			}
-		}
- next:
-		daemon_reply_destroy(reply);
-
-		if (rv < 0)
-			break;
-	}
-out:
-	/* Return lockd VG's on the vg_lockd list. */
-
-	list_for_each_entry_safe(ls, safe, &update_vgs, list) {
-		list_del(&ls->list);
-
-		if ((ls->lm_type == LD_LM_SANLOCK) || (ls->lm_type == LD_LM_DLM))
-			list_add_tail(&ls->list, vg_lockd);
-		else
-			free(ls);
-	}
-
-	return rv;
-#endif
-}
-
 static char _dm_uuid[DM_UUID_LEN];
 
 static char *get_dm_uuid(char *dm_name)
@@ -5236,9 +5215,9 @@ static void adopt_locks(void)
 	INIT_LIST_HEAD(&to_unlock);
 
 	/*
-	 * Get list of lockspaces from lock managers.
-	 * Get list of VGs from lvmetad with a lockd type.
-	 * Get list of active lockd type LVs from /dev.
+	 * Get list of lockspaces from currently running lock managers.
+	 * Get list of shared VGs from file written by prior lvmlockd.
+	 * Get list of active LVs (in the shared VGs) from the file.
 	 */
 
 	if (lm_support_dlm() && lm_is_running_dlm()) {
@@ -5262,12 +5241,17 @@ static void adopt_locks(void)
 	 * Adds a struct lockspace to vg_lockd for each lockd VG.
 	 * Adds a struct resource to ls->resources for each LV.
 	 */
-	rv = get_lockd_vgs(&vg_lockd);
+	rv = read_adopt_file(&vg_lockd);
 	if (rv < 0) {
-		log_error("adopt_locks get_lockd_vgs failed");
+		log_error("adopt_locks read_adopt_file failed");
 		goto fail;
 	}
 
+	if (list_empty(&vg_lockd)) {
+		log_debug("No lockspaces in adopt file");
+		return;
+	}
+
 	/*
 	 * For each resource on each lockspace, check if the
 	 * corresponding LV is active.  If so, leave the
@@ -5506,7 +5490,7 @@ static void adopt_locks(void)
 				goto fail;
 			act->op = LD_OP_LOCK;
 			act->rt = LD_RT_LV;
-			act->mode = LD_LK_EX;
+			act->mode = r->adopt_mode;
 			act->flags = (LD_AF_ADOPT | LD_AF_PERSISTENT);
 			act->client_id = INTERNAL_CLIENT_ID;
 			act->lm_type = ls->lm_type;
@@ -5604,8 +5588,9 @@ static void adopt_locks(void)
 			 * Adopt failed because the orphan has a different mode
 			 * than initially requested.  Repeat the lock-adopt operation
 			 * with the other mode.  N.B. this logic depends on first
-			 * trying sh then ex for GL/VG locks, and ex then sh for
-			 * LV locks.
+			 * trying sh then ex for GL/VG locks; for LV locks the mode
+			 * from the adopt file is tried first, the alternate
+			 * (if the mode in adopt file was wrong somehow.)
 			 */
 
 			if ((act->rt != LD_RT_LV) && (act->mode == LD_LK_SH)) {
@@ -5613,9 +5598,12 @@ static void adopt_locks(void)
 				act->mode = LD_LK_EX;
 				rv = add_lock_action(act);
 
-			} else if ((act->rt == LD_RT_LV) && (act->mode == LD_LK_EX)) {
-				/* LV locks: attempt to adopt sh after ex failed. */
-				act->mode = LD_LK_SH;
+			} else if (act->rt == LD_RT_LV) {
+				/* LV locks: attempt to adopt the other mode. */
+				if (act->mode == LD_LK_EX)
+					act->mode = LD_LK_SH;
+				else if (act->mode == LD_LK_SH)
+					act->mode = LD_LK_EX;
 				rv = add_lock_action(act);
 
 			} else {
@@ -5750,10 +5738,13 @@ static void adopt_locks(void)
 	if (count_start_fail || count_adopt_fail)
 		goto fail;
 
+	unlink(adopt_file);
+	write_adopt_file();
 	log_debug("adopt_locks done");
 	return;
 
 fail:
+	unlink(adopt_file);
 	log_error("adopt_locks failed, reset host");
 }
 
@@ -6028,6 +6019,8 @@ static void usage(char *prog, FILE *file)
 	fprintf(file, "        Set path to the pid file. [%s]\n", LVMLOCKD_PIDFILE);
 	fprintf(file, "  --socket-path | -s <path>\n");
 	fprintf(file, "        Set path to the socket to listen on. [%s]\n", LVMLOCKD_SOCKET);
+	fprintf(file, "  --adopt-file <path>\n");
+	fprintf(file, "        Set path to the adopt file. [%s]\n", LVMLOCKD_ADOPT_FILE);
 	fprintf(file, "  --syslog-priority | -S err|warning|debug\n");
 	fprintf(file, "        Write log messages from this level up to syslog. [%s]\n", _syslog_num_to_name(LOG_SYSLOG_PRIO));
 	fprintf(file, "  --gl-type | -g <str>\n");
@@ -6063,6 +6056,7 @@ int main(int argc, char *argv[])
 		{"daemon-debug",    no_argument,       0, 'D' },
 		{"pid-file",        required_argument, 0, 'p' },
 		{"socket-path",     required_argument, 0, 's' },
+		{"adopt-file",      required_argument, 0, 128 },
 		{"gl-type",         required_argument, 0, 'g' },
 		{"host-id",         required_argument, 0, 'i' },
 		{"host-id-file",    required_argument, 0, 'F' },
@@ -6085,6 +6079,9 @@ int main(int argc, char *argv[])
 		switch (c) {
 		case '0':
 			break;
+		case 128:
+			adopt_file = strdup(optarg);
+			break;
 		case 'h':
 			usage(argv[0], stdout);
 			exit(EXIT_SUCCESS);
@@ -6146,6 +6143,9 @@ int main(int argc, char *argv[])
 	if (!ds.socket_path)
 		ds.socket_path = LVMLOCKD_SOCKET;
 
+	if (!adopt_file)
+		adopt_file = LVMLOCKD_ADOPT_FILE;
+
 	/* runs daemon_main/main_loop */
 	daemon_start(ds);
 
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 75e6deec4..7915cc008 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -398,12 +398,18 @@ static int lm_adopt_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
 			  (void *)1, (void *)1, (void *)1,
 			  NULL, NULL);
 
-	if (rv == -1 && errno == -EAGAIN) {
+	if (rv == -1 && (errno == EAGAIN)) {
 		log_debug("S %s R %s adopt_dlm adopt mode %d try other mode",
 			  ls->name, r->name, ld_mode);
 		rv = -EUCLEAN;
 		goto fail;
 	}
+	if (rv == -1 && (errno == ENOENT)) {
+		log_debug("S %s R %s adopt_dlm adopt mode %d no lock",
+			  ls->name, r->name, ld_mode);
+		rv = -ENOENT;
+		goto fail;
+	}
 	if (rv < 0) {
 		log_debug("S %s R %s adopt_dlm mode %d flags %x error %d errno %d",
 			  ls->name, r->name, mode, flags, rv, errno);
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 85e8caf9a..04100c0c1 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -145,6 +145,7 @@ struct resource {
 	char name[MAX_NAME+1];		/* vg name or lv name */
 	int8_t type;			/* resource type LD_RT_ */
 	int8_t mode;
+	int8_t adopt_mode;
 	unsigned int sh_count;		/* number of sh locks on locks list */
 	uint32_t version;
 	uint32_t last_client_id;	/* last client_id to lock or unlock resource */
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 8ed5400e4..c21f7a916 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -58,6 +58,10 @@ For default settings, see lvmlockd -h.
 .I path
         Set path to the socket to listen on.
 
+.B  --adopt-file
+.I path
+        Set path to the adopt file.
+
 .B  --syslog-priority | -S err|warning|debug
         Write log messages from this level up to syslog.
 
@@ -76,6 +80,8 @@ For default settings, see lvmlockd -h.
 .I seconds
         Override the default sanlock I/O timeout.
 
+.B --adopt | -A 0|1
+        Enable (1) or disable (0) lock adoption.
 
 .SH USAGE
 
@@ -548,7 +554,13 @@ necessary locks.
 .B lvmlockd failure
 
 If lvmlockd fails or is killed while holding locks, the locks are orphaned
-in the lock manager.
+in the lock manager.  Orphaned locks must be cleared or adopted before the
+associated resources can be accessed normally.  If lock adoption is
+enabled, lvmlockd keeps a record of locks in the adopt-file.  A subsequent
+instance of lvmlockd will then adopt locks orphaned by the previous
+instance.  Adoption must be enabled in both instances (--adopt|-A 1).
+Without adoption, the lock manager or host would require a reset to clear
+orphaned lock state.
 
 .B dlm/corosync failure
 



