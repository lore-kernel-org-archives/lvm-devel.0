From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  9 Jul 2015 13:15:24 +0000 (UTC)
Subject: master - coverity: missing return value checks
Message-ID: <20150709131524.33BB4611FD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10d27998b3d2f6100e9e29e83d1d99948c55875f
Commit:        10d27998b3d2f6100e9e29e83d1d99948c55875f
Parent:        a9a7c297aebe82ddc9092b7b19cc9cfcc27e117e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 9 15:15:15 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 9 15:15:15 2015 +0200

coverity: missing return value checks

---
 daemons/lvmetad/lvmetad-core.c         |    3 ++-
 daemons/lvmlockd/lvmlockctl.c          |    3 ++-
 daemons/lvmlockd/lvmlockd-core.c       |   10 +++++++---
 daemons/lvmlockd/lvmlockd-dlm.c        |   10 +++++++---
 daemons/lvmlockd/lvmlockd-sanlock.c    |    9 ++++++---
 daemons/lvmpolld/lvmpolld-data-utils.c |    8 ++++----
 lib/cache/lvmetad.c                    |   29 ++++++++++++++++++++++-------
 lib/locking/lvmlockd.c                 |   14 +++++++++-----
 lib/report/report.c                    |    6 +++++-
 9 files changed, 64 insertions(+), 28 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index b4382c7..7b57dc4 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1338,7 +1338,8 @@ inval:
 		if (!info)
 			goto bad;
 		memset(info, 0, sizeof(struct vg_info));
-		dm_hash_insert(s->vgid_to_info, uuid, (void*)info);
+		if (!dm_hash_insert(s->vgid_to_info, uuid, (void*)info))
+			goto bad;
 	}
 
 	info->external_version = new_version;
diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index bc5ec78..4b27a57 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -443,7 +443,8 @@ static int do_dump(const char *req_name)
 	else
 		format_info();
 out:
-	close(fd);
+	if (close(fd))
+		log_error("failed to close dump socket %d", fd);
 	return rv;
 }
 
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index eee1da1..fee0b88 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -4347,7 +4347,9 @@ static void *client_thread_main(void *arg_in)
 						  cl->id, cl->pi, cl->fd);
 					/* assert cl->pi != -1 */
 					/* assert pollfd[pi].fd == FD_IGNORE */
-					close(cl->fd);
+					if (close(cl->fd))
+						log_error("client close %d pi %d fd %d failed",
+							  cl->id, cl->pi, cl->fd);
 					rem_pollfd(cl->pi);
 					cl->pi = -1;
 					cl->fd = -1;
@@ -5534,7 +5536,8 @@ static int main_loop(daemon_state *ds_arg)
 					cl->pi = -1;
 					cl->fd = -1;
 					cl->poll_ignore = 0;
-					close(pollfd[i].fd);
+					if (close(pollfd[i].fd))
+						log_error("close fd %d failed", pollfd[i].fd);
 					pollfd[i].fd = POLL_FD_UNUSED;
 					pollfd[i].events = 0;
 					pollfd[i].revents = 0;
@@ -5559,7 +5562,8 @@ static int main_loop(daemon_state *ds_arg)
 				/* don't think this can happen */
 				log_error("no client for index %d fd %d",
 					  i, pollfd[i].fd);
-				close(pollfd[i].fd);
+				if (close(pollfd[i].fd))
+					log_error("close fd %d failed", pollfd[i].fd);
 				pollfd[i].fd = POLL_FD_UNUSED;
 				pollfd[i].events = 0;
 				pollfd[i].revents = 0;
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index de19532..f41599d 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -96,6 +96,7 @@ static int check_args_version(char *vg_args)
 
 static int read_cluster_name(char *clustername)
 {
+	static const char close_error_msg[] = "read_cluster_name: close_error %d";
 	char *n;
 	int fd;
 	int rv;
@@ -114,14 +115,16 @@ static int read_cluster_name(char *clustername)
 	rv = read(fd, clustername, MAX_ARGS - 1);
 	if (rv < 0) {
 		log_error("read_cluster_name: cluster name read error %d, check dlm_controld", fd);
-		close(fd);
+		if (close(fd))
+			log_error(close_error_msg, fd);
 		return rv;
 	}
 
 	n = strstr(clustername, "\n");
 	if (n)
 		*n = '\0';
-	close(fd);
+	if (close(fd))
+		log_error(close_error_msg, fd);
 	return 0;
 }
 
@@ -630,7 +633,8 @@ int lm_get_lockspaces_dlm(struct list_head *ls_rejoin)
 			continue;
 
 		if (!(ls = alloc_lockspace())) {
-			closedir(ls_dir);
+			if (closedir(ls_dir))
+				log_error("lm_get_lockspace_dlm: closedir failed");
 			return -ENOMEM;
 		}
 
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index f52528f..e83986b 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -236,7 +236,8 @@ static int read_host_id_file(void)
 			break;
 		}
 	}
-	fclose(file);
+	if (fclose(file))
+		log_error("failed to close host id file %s", daemon_host_id_file);
 out:
 	log_debug("host_id %d from %s", host_id, daemon_host_id_file);
 	return host_id;
@@ -1138,7 +1139,8 @@ out:
 	return 0;
 
 fail:
-	close(lms->sock);
+	if (close(lms->sock))
+		log_error("failed to close sanlock daemon socket connection");
 	free(lms);
 	ls->lm_data = NULL;
 	return rv;
@@ -1174,7 +1176,8 @@ int lm_rem_lockspace_sanlock(struct lockspace *ls, int free_vg)
 		}
 	}
 out:
-	close(lms->sock);
+	if (close(lms->sock))
+		log_error("failed to close sanlock daemon socket connection");
 
 	free(lms);
 	ls->lm_data = NULL;
diff --git a/daemons/lvmpolld/lvmpolld-data-utils.c b/daemons/lvmpolld/lvmpolld-data-utils.c
index f28bc51..efe31cf 100644
--- a/daemons/lvmpolld/lvmpolld-data-utils.c
+++ b/daemons/lvmpolld/lvmpolld-data-utils.c
@@ -376,16 +376,16 @@ void lvmpolld_thread_data_destroy(void *thread_private)
 		data->errpipe[0] = -1;
 
 	if (data->outpipe[0] >= 0)
-		close(data->outpipe[0]);
+		(void) close(data->outpipe[0]);
 
 	if (data->outpipe[1] >= 0)
-		close(data->outpipe[1]);
+		(void) close(data->outpipe[1]);
 
 	if (data->errpipe[0] >= 0)
-		close(data->errpipe[0]);
+		(void) close(data->errpipe[0]);
 
 	if (data->errpipe[1] >= 0)
-		close(data->errpipe[1]);
+		(void) close(data->errpipe[1]);
 
 	dm_free(data);
 }
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 8905640..d22df75 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -154,16 +154,23 @@ static daemon_reply _lvmetad_send(const char *id, ...)
 	unsigned total_usecs_waited = 0;
 	unsigned max_remaining_sleep_times = 1;
 	unsigned wait_usecs;
+	int r;
 
 retry:
 	req = daemon_request_make(id);
 
-	if (_lvmetad_token)
-		daemon_request_extend(req, "token = %s", _lvmetad_token, NULL);
+	if (_lvmetad_token && !daemon_request_extend(req, "token = %s", _lvmetad_token, NULL)) {
+		repl.error = ENOMEM;
+		return repl;
+	}
 
 	va_start(ap, id);
-	daemon_request_extend_v(req, ap);
+	r = daemon_request_extend_v(req, ap);
 	va_end(ap);
+	if (!r) {
+		repl.error = ENOMEM;
+		return repl;
+	}
 
 	repl = daemon_send(_lvmetad, req);
 
@@ -1052,7 +1059,10 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 		if (!pvl->pv->dev)
 			continue;
 
-		info = lvmcache_info_from_pvid((const char *)&pvl->pv->id, 0);
+		if (!(info = lvmcache_info_from_pvid((const char *)&pvl->pv->id, 0))) {
+			log_error("Failed to find cached info for PV %s.", pv_dev_name(pvl->pv));
+			return NULL;
+		}
 
 		baton.vg = NULL;
 		baton.fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info), &fic);
@@ -1351,7 +1361,8 @@ static int _lvmetad_get_pv_cache_list(struct cmd_context *cmd, struct dm_list *p
 /*
  * Opening the device RDWR should trigger a udev db update.
  * FIXME: is there a better way to update the udev db than
- * doing an open/close of the device?
+ * doing an open/close of the device? - For example writing
+ * "change" to /sys/block/<device>/uevent?
  */
 static void _update_pv_in_udev(struct cmd_context *cmd, dev_t devt)
 {
@@ -1365,9 +1376,13 @@ static void _update_pv_in_udev(struct cmd_context *cmd, dev_t devt)
 		return;
 	}
 
-	if (!dev_open(dev))
+	if (!dev_open(dev)) {
+		stack;
 		return;
-	dev_close(dev);
+	}
+
+	if (!dev_close(dev))
+		stack;
 }
 
 /*
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 4fdb818..b861334 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -898,6 +898,9 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg)
 	log_debug("lockd start VG %s lock_type %s",
 		  vg->name, vg->lock_type ? vg->lock_type : "empty");
 
+	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
+		return_0;
+
 	if (vg->lock_type && !strcmp(vg->lock_type, "sanlock")) {
 		/*
 		 * This is the big difference between starting
@@ -912,8 +915,6 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg)
 		host_id = find_config_tree_int(cmd, local_host_id_CFG, NULL);
 	}
 
-	id_write_format(&vg->id, uuid, sizeof(uuid));
-
 	reply = _lockd_send("start_vg",
 				"pid = %d", getpid(),
 				"vg_name = %s", vg->name,
@@ -1806,7 +1807,8 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 	if (!_lvmlockd_connected)
 		return 0;
 
-	id_write_format(lv_id, lv_uuid, sizeof(lv_uuid));
+	if (!id_write_format(lv_id, lv_uuid, sizeof(lv_uuid)))
+		return_0;
 
 	/*
 	 * For lvchange/vgchange activation, def_mode is "sh" or "ex"
@@ -2000,7 +2002,8 @@ static int _init_lv_sanlock(struct cmd_context *cmd, struct volume_group *vg,
 	if (!_lvmlockd_connected)
 		return 0;
 
-	id_write_format(lv_id, lv_uuid, sizeof(lv_uuid));
+	if (!id_write_format(lv_id, lv_uuid, sizeof(lv_uuid)))
+		return_0;
 
 	reply = _lockd_send("init_lv",
 				"pid = %d", getpid(),
@@ -2066,7 +2069,8 @@ static int _free_lv(struct cmd_context *cmd, struct volume_group *vg,
 	if (!_lvmlockd_connected)
 		return 0;
 
-	id_write_format(lv_id, lv_uuid, sizeof(lv_uuid));
+	if (!id_write_format(lv_id, lv_uuid, sizeof(lv_uuid)))
+		return_0;
 
 	reply = _lockd_send("free_lv",
 				"pid = %d", getpid(),
diff --git a/lib/report/report.c b/lib/report/report.c
index 80d189a..79802b7 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1004,7 +1004,11 @@ static int _translate_time_items(struct dm_report *rh, struct time_info *info,
 	dm_pool_free(info->mem, info->ti_list);
 	info->ti_list = NULL;
 
-	dm_snprintf(buf, sizeof(buf), "@%ld:@%ld", t1, t2);
+	if (dm_snprintf(buf, sizeof(buf), "@%ld:@%ld", t1, t2) == -1) {
+		log_error("_translate_time_items: dm_snprintf failed");
+		return 0;
+	}
+
 	if (!(*data_out = dm_pool_strdup(info->mem, buf))) {
 		log_error("_translate_time_items: dm_pool_strdup failed");
 		return 0;


