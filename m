From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:42 +0000 (UTC)
Subject: master - dmeventd: syslog -> log_xxxxx
Message-ID: <20151013140342.02C2060EDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=915f0faac1fa3541f4a01092536fac5f2ab5982f
Commit:        915f0faac1fa3541f4a01092536fac5f2ab5982f
Parent:        0641e3a5fd19628db0e08fca252c13f40230ffa2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 9 21:57:48 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 14:43:30 2015 +0200

dmeventd: syslog -> log_xxxxx

Convert logging of dmeventd to libdm logging macros.
---
 WHATS_NEW_DM                                       |    1 +
 daemons/dmeventd/dmeventd.c                        |   94 +++++++++-----------
 daemons/dmeventd/libdevmapper-event.c              |   34 ++++----
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c       |    6 +-
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c  |   46 +++++-----
 daemons/dmeventd/plugins/raid/dmeventd_raid.c      |   38 ++++----
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |   30 ++++---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c      |   53 ++++++------
 8 files changed, 145 insertions(+), 157 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a1c121a..ff4ac22 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Convert dmeventd to use common logging macro system from libdm.
   Return -ENOMEM when device registration fails instead of 0 (=success).
   Enforce writethrough mode for cleaner policy.
   Add support for recognition and deactivation of MD devices to blkdeactivate.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 844b2a6..581ce18 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -718,13 +718,12 @@ static int _event_wait(struct thread_status *thread, struct dm_task **task)
 		} else if (thread->status == DM_THREAD_SHUTDOWN && ioctl_errno == EINTR)
 			ret = DM_WAIT_FATAL;
 		else {
-			syslog(LOG_NOTICE, "dm_task_run failed, errno = %d, %s",
-			       ioctl_errno, strerror(ioctl_errno));
 			if (ioctl_errno == ENXIO) {
-				syslog(LOG_ERR, "%s disappeared, detaching",
-				       thread->device.name);
+				log_error("%s disappeared, detaching.",
+					  thread->device.name);
 				ret = DM_WAIT_FATAL;
-			}
+			} else
+				log_sys_error("dm_task_run", "");
 		}
 	}
 	DEBUGLOG("Completed waitevent task for %s", thread->device.uuid);
@@ -778,8 +777,8 @@ static void _monitor_unregister(void *arg)
 
 	DEBUGLOG("_monitor_unregister thread cleanup handler running");
 	if (!_do_unregister_device(thread))
-		syslog(LOG_ERR, "%s: %s unregister failed\n", __func__,
-		       thread->device.name);
+		log_error("%s: %s unregister failed.", __func__,
+			  thread->device.name);
 	if (thread->current_task) {
 		dm_task_destroy(thread->current_task);
 		thread->current_task = NULL;
@@ -981,8 +980,8 @@ static struct dso_data *_load_dso(struct message_data *data)
 
 	if (!(dl = dlopen(data->dso_name, RTLD_NOW))) {
 		const char *dlerr = dlerror();
-		syslog(LOG_ERR, "dmeventd %s dlopen failed: %s", data->dso_name,
-		       dlerr);
+		log_error("dmeventd %s dlopen failed: %s.",
+			  data->dso_name, dlerr);
 		data->msg->size =
 		    dm_asprintf(&(data->msg->data), "%s %s dlopen failed: %s",
 				data->id, data->dso_name, dlerr);
@@ -1309,8 +1308,7 @@ static int _open_fifos(struct dm_event_fifos *fifos)
 	/* Create client fifo. */
 	(void) dm_prepare_selinux_context(fifos->client_path, S_IFIFO);
 	if ((mkfifo(fifos->client_path, 0600) == -1) && errno != EEXIST) {
-		syslog(LOG_ERR, "%s: Failed to create client fifo %s: %m.\n",
-		       __func__, fifos->client_path);
+		log_sys_error("client mkfifo", fifos->client_path);
 		(void) dm_prepare_selinux_context(NULL, 0);
 		goto fail;
 	}
@@ -1318,8 +1316,7 @@ static int _open_fifos(struct dm_event_fifos *fifos)
 	/* Create server fifo. */
 	(void) dm_prepare_selinux_context(fifos->server_path, S_IFIFO);
 	if ((mkfifo(fifos->server_path, 0600) == -1) && errno != EEXIST) {
-		syslog(LOG_ERR, "%s: Failed to create server fifo %s: %m.\n",
-		       __func__, fifos->server_path);
+		log_sys_error("server mkfifo", fifos->server_path);
 		(void) dm_prepare_selinux_context(NULL, 0);
 		goto fail;
 	}
@@ -1328,58 +1325,53 @@ static int _open_fifos(struct dm_event_fifos *fifos)
 
 	/* Warn about wrong permissions if applicable */
 	if ((!stat(fifos->client_path, &st)) && (st.st_mode & 0777) != 0600)
-		syslog(LOG_WARNING, "Fixing wrong permissions on %s: %m.\n",
-		       fifos->client_path);
+		log_warn("WARNING: Fixing wrong permissions on %s: %s.\n",
+			 fifos->client_path, strerror(errno));
 
 	if ((!stat(fifos->server_path, &st)) && (st.st_mode & 0777) != 0600)
-		syslog(LOG_WARNING, "Fixing wrong permissions on %s: %m.\n",
-		       fifos->server_path);
+		log_warn("WARNING: Fixing wrong permissions on %s: %s.\n",
+			 fifos->server_path, strerror(errno));
 
 	/* If they were already there, make sure permissions are ok. */
 	if (chmod(fifos->client_path, 0600)) {
-		syslog(LOG_ERR, "Unable to set correct file permissions on %s: %m.\n",
-		       fifos->client_path);
+		log_sys_error("chmod", fifos->client_path);
 		goto fail;
 	}
 
 	if (chmod(fifos->server_path, 0600)) {
-		syslog(LOG_ERR, "Unable to set correct file permissions on %s: %m.\n",
-		       fifos->server_path);
+		log_sys_error("chmod", fifos->server_path);
 		goto fail;
 	}
 
 	/* Need to open read+write or we will block or fail */
 	if ((fifos->server = open(fifos->server_path, O_RDWR)) < 0) {
-		syslog(LOG_ERR, "Failed to open fifo server %s: %m.\n",
-		       fifos->server_path);
+		log_sys_error("server open", fifos->server_path);
 		goto fail;
 	}
 
 	if (fcntl(fifos->server, F_SETFD, FD_CLOEXEC) < 0) {
-		syslog(LOG_ERR, "Failed to set FD_CLOEXEC for fifo server %s: %m.\n",
-		       fifos->server_path);
+		log_sys_error("fcntl(FD_CLOEXEC)", fifos->server_path);
 		goto fail;
 	}
 
 	/* Need to open read+write for select() to work. */
 	if ((fifos->client = open(fifos->client_path, O_RDWR)) < 0) {
-		syslog(LOG_ERR, "Failed to open fifo client %s: %m", fifos->client_path);
+		log_sys_error("client open", fifos->client_path);
 		goto fail;
 	}
 
 	if (fcntl(fifos->client, F_SETFD, FD_CLOEXEC) < 0) {
-		syslog(LOG_ERR, "Failed to set FD_CLOEXEC for fifo client %s: %m.\n",
-		       fifos->client_path);
+		log_sys_error("fcntl(FD_CLOEXEC)", fifos->client_path);
 		goto fail;
 	}
 
 	return 1;
 fail:
 	if (fifos->server >= 0 && close(fifos->server))
-		syslog(LOG_ERR, "Failed to close fifo server %s: %m", fifos->server_path);
+		log_sys_error("server close", fifos->server_path);
 
 	if (fifos->client >= 0 && close(fifos->client))
-		syslog(LOG_ERR, "Failed to close fifo client %s: %m", fifos->client_path);
+		log_sys_error("client close", fifos->client_path);
 
 	return 0;
 }
@@ -1591,7 +1583,7 @@ static void _process_request(struct dm_event_fifos *fifos)
 
 	if (die) {
 		if (unlink(DMEVENTD_PIDFILE))
-			perror(DMEVENTD_PIDFILE ": unlink failed");
+			log_sys_error("unlink", DMEVENTD_PIDFILE);
 		_exit(0);
 	}
 }
@@ -1637,15 +1629,14 @@ static void _cleanup_unused_threads(void)
 				if (ret == ESRCH) {
 					thread->status = DM_THREAD_DONE;
 				} else if (ret) {
-					syslog(LOG_ERR, "Unable to terminate thread: %s",
-					       strerror(ret));
+					log_error("Unable to terminate thread: %s",
+						  strerror(ret));
 				}
 				break;
 			}
 
 			dm_list_del(l);
-			syslog(LOG_ERR,
-			       "thread can't be on unused list unless !thread->events");
+			log_error("thread can't be on unused list unless !thread->events");
 			thread->status = DM_THREAD_RUNNING;
 			LINK_THREAD(thread);
 
@@ -1665,7 +1656,7 @@ static void _cleanup_unused_threads(void)
 	_unlock_mutex();
 
 	if (join_ret)
-		syslog(LOG_ERR, "Failed pthread_join: %s\n", strerror(join_ret));
+		log_error("Failed pthread_join: %s.", strerror(join_ret));
 }
 
 static void _sig_alarm(int signum __attribute__((unused)))
@@ -1709,14 +1700,14 @@ static int _set_oom_adj(const char *oom_adj_path, int val)
 	FILE *fp;
 
 	if (!(fp = fopen(oom_adj_path, "w"))) {
-		perror("oom_adj: fopen failed");
+		log_sys_error("open", oom_adj_path);
 		return 0;
 	}
 
 	fprintf(fp, "%i", val);
 
 	if (dm_fclose(fp))
-		perror("oom_adj: fclose failed");
+		log_sys_error("fclose", oom_adj_path);
 
 	return 1;
 }
@@ -1730,14 +1721,11 @@ static int _protect_against_oom_killer(void)
 
 	if (stat(OOM_ADJ_FILE, &st) == -1) {
 		if (errno != ENOENT)
-			perror(OOM_ADJ_FILE ": stat failed");
+			log_sys_error("stat", OOM_ADJ_FILE);
 
 		/* Try old oom_adj interface as a fallback */
 		if (stat(OOM_ADJ_FILE_OLD, &st) == -1) {
-			if (errno == ENOENT)
-				perror(OOM_ADJ_FILE_OLD " not found");
-			else
-				perror(OOM_ADJ_FILE_OLD ": stat failed");
+			log_sys_error("stat", OOM_ADJ_FILE_OLD);
 			return 1;
 		}
 
@@ -1826,14 +1814,14 @@ out:
 static void _remove_files_on_exit(void)
 {
 	if (unlink(DMEVENTD_PIDFILE))
-		perror(DMEVENTD_PIDFILE ": unlink failed");
+		log_sys_error("unlink", DMEVENTD_PIDFILE);
 
 	if (!_systemd_activation) {
 		if (unlink(DM_EVENT_FIFO_CLIENT))
-			perror(DM_EVENT_FIFO_CLIENT " : unlink failed");
+			log_sys_error("unlink", DM_EVENT_FIFO_CLIENT);
 
 		if (unlink(DM_EVENT_FIFO_SERVER))
-			perror(DM_EVENT_FIFO_SERVER " : unlink failed");
+			log_sys_error("unlink", DM_EVENT_FIFO_SERVER);
 	}
 }
 
@@ -1855,7 +1843,7 @@ static void _daemonize(void)
 
 	switch (pid = fork()) {
 	case -1:
-		perror("fork failed:");
+		log_sys_error("fork", "");
 		exit(EXIT_FAILURE);
 
 	case 0:		/* Child */
@@ -2167,7 +2155,7 @@ int main(int argc, char *argv[])
 #ifdef __linux__
 	/* Systemd has adjusted oom killer for us already */
 	if (!_systemd_activation && !_protect_against_oom_killer())
-		syslog(LOG_ERR, "Failed to protect against OOM killer");
+		log_error("Failed to protect against OOM killer.");
 #endif
 
 	_init_thread_signals();
@@ -2185,7 +2173,7 @@ int main(int argc, char *argv[])
 	/* Signal parent, letting them know we are ready to go. */
 	if (!_foreground)
 		kill(getppid(), SIGTERM);
-	syslog(LOG_NOTICE, "dmeventd ready for processing.");
+	log_notice("dmeventd ready for processing.");
 
 	if (_initial_registrations)
 		_process_initial_registrations();
@@ -2204,8 +2192,8 @@ int main(int argc, char *argv[])
 			_unlock_mutex();
 			if (nothreads)
 				break;
-			syslog(LOG_ERR, "There are still devices being monitored.");
-			syslog(LOG_ERR, "Refusing to exit.");
+			log_error("There are still devices being monitored.");
+			log_error("Refusing to exit.");
 		}
 		_process_request(&fifos);
 		_cleanup_unused_threads();
@@ -2215,7 +2203,7 @@ int main(int argc, char *argv[])
 
 	pthread_mutex_destroy(&_global_mutex);
 
-	syslog(LOG_NOTICE, "dmeventd shutting down.");
+	log_notice("dmeventd shutting down.");
 	closelog();
 
 	exit(EXIT_SUCCESS);
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 9b04b02..ee4a35c 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -198,7 +198,7 @@ static int _check_message_id(struct dm_event_daemon_message *msg)
 	if ((sscanf(msg->data, "%d:%d", &pid, &seq_nr) != 2) ||
 	    (pid != getpid()) || (seq_nr != _sequence_nr)) {
 		log_error("Ignoring out-of-sequence reply from dmeventd. "
-			  "Expected %d:%d but received %s", getpid(),
+			  "Expected %d:%d but received %s.", getpid(),
 			  _sequence_nr, msg->data);
 		return 0;
 	}
@@ -233,7 +233,7 @@ static int _daemon_read(struct dm_event_fifos *fifos,
 			FD_SET(fifos->server, &fds);
 			ret = select(fifos->server + 1, &fds, NULL, NULL, &tval);
 			if (ret < 0 && errno != EINTR) {
-				log_error("Unable to read from event server");
+				log_error("Unable to read from event server.");
 				return 0;
 			}
 			if ((ret == 0) && (i > 4) && !bytes) {
@@ -299,7 +299,7 @@ static int _daemon_write(struct dm_event_fifos *fifos,
 		if (ret < 0) {
 			if (errno == EINTR)
 				continue;
-			log_error("Unable to talk to event daemon");
+			log_error("Unable to talk to event daemon.");
 			return 0;
 		}
 		if (ret == 0)
@@ -308,7 +308,7 @@ static int _daemon_write(struct dm_event_fifos *fifos,
 		if (ret < 0) {
 			if ((errno == EINTR) || (errno == EAGAIN))
 				continue;
-			log_error("Unable to talk to event daemon");
+			log_error("Unable to talk to event daemon.");
 			return 0;
 		}
 	}
@@ -320,7 +320,7 @@ static int _daemon_write(struct dm_event_fifos *fifos,
 			FD_SET(fifos->client, &fds);
 			ret = select(fifos->client + 1, NULL, &fds, NULL, NULL);
 			if ((ret < 0) && (errno != EINTR)) {
-				log_error("Unable to talk to event daemon");
+				log_error("Unable to talk to event daemon.");
 				return 0;
 			}
 		} while (ret < 1);
@@ -330,7 +330,7 @@ static int _daemon_write(struct dm_event_fifos *fifos,
 			if ((errno == EINTR) || (errno == EAGAIN))
 				continue;
 			else {
-				log_error("Unable to talk to event daemon");
+				log_error("Unable to talk to event daemon.");
 				return 0;
 			}
 		}
@@ -360,7 +360,7 @@ int daemon_talk(struct dm_event_fifos *fifos,
 			  getpid(), _sequence_nr,
 			  dso_name ? : "-", dev_name ? : "-", evmask, timeout)))
 	    < 0) {
-		log_error("_daemon_talk: message allocation failed");
+		log_error("_daemon_talk: message allocation failed.");
 		return -ENOMEM;
 	}
 	msg->cmd = cmd;
@@ -448,11 +448,11 @@ static int _start_daemon(char *dmeventd_path, struct dm_event_fifos *fifos)
 
 	else if (!pid) {
 		execvp(args[0], args);
-		log_error("Unable to exec dmeventd: %s", strerror(errno));
+		log_error("Unable to exec dmeventd: %s.", strerror(errno));
 		_exit(EXIT_FAILURE);
 	} else {
 		if (waitpid(pid, &status, 0) < 0)
-			log_error("Unable to start dmeventd: %s",
+			log_error("Unable to start dmeventd: %s.",
 				  strerror(errno));
 		else if (WEXITSTATUS(status))
 			log_error("Unable to start dmeventd.");
@@ -525,7 +525,7 @@ static struct dm_task *_get_device_info(const struct dm_event_handler *dmevh)
 	struct dm_info info;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_INFO))) {
-		log_error("_get_device_info: dm_task creation for info failed");
+		log_error("_get_device_info: dm_task creation for info failed.");
 		return NULL;
 	}
 
@@ -543,17 +543,17 @@ static struct dm_task *_get_device_info(const struct dm_event_handler *dmevh)
 
 	/* FIXME Add name or uuid or devno to messages */
 	if (!dm_task_run(dmt)) {
-		log_error("_get_device_info: dm_task_run() failed");
+		log_error("_get_device_info: dm_task_run() failed.");
 		goto bad;
 	}
 
 	if (!dm_task_get_info(dmt, &info)) {
-		log_error("_get_device_info: failed to get info for device");
+		log_error("_get_device_info: failed to get info for device.");
 		goto bad;
 	}
 
 	if (!info.exists) {
-		log_error("_get_device_info: %s%s%s%.0d%s%.0d%s%s: device not found",
+		log_error("_get_device_info: %s%s%s%.0d%s%.0d%s%s: device not found.",
 			  dmevh->uuid ? : "",
 			  (!dmevh->uuid && dmevh->dev_name) ? dmevh->dev_name : "",
 			  (!dmevh->uuid && !dmevh->dev_name && dmevh->major > 0) ? "(" : "",
@@ -622,12 +622,12 @@ int dm_event_register_handler(const struct dm_event_handler *dmevh)
 	    !strstr(dmevh->dso, "libdevmapper-event-lvm2snapshot.so") &&
 	    !strstr(dmevh->dso, "libdevmapper-event-lvm2mirror.so") &&
 	    !strstr(dmevh->dso, "libdevmapper-event-lvm2raid.so"))
-		log_warn("WARNING: %s: dmeventd plugins are deprecated", dmevh->dso);
+		log_warn("WARNING: %s: dmeventd plugins are deprecated.", dmevh->dso);
 
 
 	if ((err = _do_event(DM_EVENT_CMD_REGISTER_FOR_EVENT, dmevh->dmeventd_path, &msg,
 			     dmevh->dso, uuid, dmevh->mask, dmevh->timeout)) < 0) {
-		log_error("%s: event registration failed: %s",
+		log_error("%s: event registration failed: %s.",
 			  dm_task_get_name(dmt),
 			  msg.data ? msg.data : strerror(-err));
 		ret = 0;
@@ -654,7 +654,7 @@ int dm_event_unregister_handler(const struct dm_event_handler *dmevh)
 
 	if ((err = _do_event(DM_EVENT_CMD_UNREGISTER_FOR_EVENT, dmevh->dmeventd_path, &msg,
 			    dmevh->dso, uuid, dmevh->mask, dmevh->timeout)) < 0) {
-		log_error("%s: event deregistration failed: %s",
+		log_error("%s: event deregistration failed: %s.",
 			  dm_task_get_name(dmt),
 			  msg.data ? msg.data : strerror(-err));
 		ret = 0;
@@ -933,7 +933,7 @@ int dm_event_get_timeout(const char *device_path, uint32_t *timeout)
 			     0, 0))) {
 		char *p = _skip_string(msg.data, ' ');
 		if (!p) {
-			log_error("malformed reply from dmeventd '%s'\n",
+			log_error("Malformed reply from dmeventd '%s'.",
 				  msg.data);
 			dm_free(msg.data);
 			return -EIO;
diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 7350623..ecaa058 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -155,8 +155,8 @@ int dmeventd_lvm2_command(struct dm_pool *mem, char *buffer, size_t size,
 	int r;
 
 	if (!dm_split_lvm_name(mem, device, &vg, &lv, &layer)) {
-		syslog(LOG_ERR, "Unable to determine VG name from %s.\n",
-		       device);
+		log_error("Unable to determine VG name from %s.",
+			  device);
 		return 0;
 	}
 
@@ -170,7 +170,7 @@ int dmeventd_lvm2_command(struct dm_pool *mem, char *buffer, size_t size,
 	dm_pool_free(mem, vg);
 
 	if (r < 0) {
-		syslog(LOG_ERR, "Unable to form LVM command. (too long).\n");
+		log_error("Unable to form LVM command. (too long).");
 		return 0;
 	}
 
diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 084be28..288e741 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -39,18 +39,15 @@ static int _process_status_code(const char status_code, const char *dev_name,
 	 *    U => Unclassified failure (bug)
 	 */ 
 	if (status_code == 'F') {
-		syslog(LOG_ERR, "%s device %s flush failed.",
-		       dev_type, dev_name);
+		log_error("%s device %s flush failed.", dev_type, dev_name);
 		r = ME_FAILURE;
 	} else if (status_code == 'S')
-		syslog(LOG_ERR, "%s device %s sync failed.",
-		       dev_type, dev_name);
+		log_error("%s device %s sync failed.", dev_type, dev_name);
 	else if (status_code == 'R')
-		syslog(LOG_ERR, "%s device %s read failed.",
-		       dev_type, dev_name);
+		log_error("%s device %s read failed.", dev_type, dev_name);
 	else if (status_code != 'A') {
-		syslog(LOG_ERR, "%s device %s has failed (%c).",
-		       dev_type, dev_name, status_code);
+		log_error("%s device %s has failed (%c).",
+			  dev_type, dev_name, status_code);
 		r = ME_FAILURE;
 	}
 
@@ -125,7 +122,8 @@ out:
 
 out_parse:
 	dm_free(args);
-	syslog(LOG_ERR, "Unable to parse mirror status string.");
+	log_error("Unable to parse mirror status string.");
+
 	return ME_IGNORE;
 }
 
@@ -142,7 +140,7 @@ static int _remove_failed_devices(const char *device)
 	r = dmeventd_lvm2_run(cmd_str);
 
 	if (!r)
-		syslog(LOG_INFO, "Re-scan of mirror device %s failed.", device);
+		log_info("Re-scan of mirror device %s failed.", device);
 
 	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(), cmd_str, sizeof(cmd_str),
 				  "lvconvert --config devices{ignore_suspended_devices=1} "
@@ -152,8 +150,8 @@ static int _remove_failed_devices(const char *device)
 	/* if repair goes OK, report success even if lvscan has failed */
 	r = dmeventd_lvm2_run(cmd_str);
 
-	syslog(LOG_INFO, "Repair of mirrored device %s %s.", device,
-	       (r) ? "finished successfully" : "failed");
+	log_info("Repair of mirrored device %s %s.", device,
+		 (r) ? "finished successfully" : "failed");
 
 	return (r) ? 0 : -1;
 }
@@ -175,12 +173,12 @@ void process_event(struct dm_task *dmt,
 					  &target_type, &params);
 
 		if (!target_type) {
-			syslog(LOG_INFO, "%s mapping lost.", device);
+			log_info("%s mapping lost.", device);
 			continue;
 		}
 
 		if (strcmp(target_type, "mirror")) {
-			syslog(LOG_INFO, "%s has unmirrored portion.", device);
+			log_info("%s has unmirrored portion.", device);
 			continue;
 		}
 
@@ -190,25 +188,25 @@ void process_event(struct dm_task *dmt,
 			   _part_ of the device is in sync
 			   Also, this is not an error
 			*/
-			syslog(LOG_NOTICE, "%s is now in-sync.", device);
+			log_notice("%s is now in-sync.", device);
 			break;
 		case ME_FAILURE:
-			syslog(LOG_ERR, "Device failure in %s.", device);
+			log_error("Device failure in %s.", device);
 			if (_remove_failed_devices(device))
 				/* FIXME Why are all the error return codes unused? Get rid of them? */
-				syslog(LOG_ERR, "Failed to remove faulty devices in %s.",
-				       device);
+				log_error("Failed to remove faulty devices in %s.",
+					  device);
 			/* Should check before warning user that device is now linear
 			else
-				syslog(LOG_NOTICE, "%s is now a linear device.\n",
-					device);
+				log_notice("%s is now a linear device.",
+					   device);
 			*/
 			break;
 		case ME_IGNORE:
 			break;
 		default:
 			/* FIXME Provide value then! */
-			syslog(LOG_INFO, "Unknown event received.");
+			log_info("Unknown event received.");
 		}
 	} while (next);
 
@@ -224,7 +222,7 @@ int register_device(const char *device,
 	if (!dmeventd_lvm2_init())
 		return 0;
 
-	syslog(LOG_INFO, "Monitoring mirror device %s for events.", device);
+	log_info("Monitoring mirror device %s for events.", device);
 
 	return 1;
 }
@@ -235,8 +233,8 @@ int unregister_device(const char *device,
 		      int minor __attribute__((unused)),
 		      void **unused __attribute__((unused)))
 {
-	syslog(LOG_INFO, "No longer monitoring mirror device %s for events.",
-	       device);
+	log_info("No longer monitoring mirror device %s for events.",
+		 device);
 	dmeventd_lvm2_exit();
 
 	return 1;
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 4690cfa..055bfc2 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -39,7 +39,7 @@ static int run_repair(const char *device)
 	r = dmeventd_lvm2_run(cmd_str);
 
 	if (!r)
-		syslog(LOG_INFO, "Re-scan of RAID device %s failed.", device);
+		log_info("Re-scan of RAID device %s failed.", device);
 
 	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(), cmd_str, sizeof(cmd_str),
 				  "lvconvert --config devices{ignore_suspended_devices=1} "
@@ -50,7 +50,7 @@ static int run_repair(const char *device)
 	r = dmeventd_lvm2_run(cmd_str);
 
 	if (!r)
-		syslog(LOG_INFO, "Repair of RAID device %s failed.", device);
+		log_info("Repair of RAID device %s failed.", device);
 
 	return (r) ? 0 : -1;
 }
@@ -69,8 +69,7 @@ static int _process_raid_event(char *params, const char *device)
 	 *                 <health chars> <resync ratio>
 	 */
 	if (!dm_split_words(params, 4, 0, a)) {
-		syslog(LOG_ERR, "Failed to process status line for %s\n",
-		       device);
+		log_error("Failed to process status line for %s.", device);
 		return -EINVAL;
 	}
 	raid_type = a[0];
@@ -79,8 +78,8 @@ static int _process_raid_event(char *params, const char *device)
 	resync_ratio = a[3];
 
 	if (!(n = atoi(num_devices))) {
-		syslog(LOG_ERR, "Failed to parse number of devices for %s: %s",
-		       device, num_devices);
+		log_error("Failed to parse number of devices for %s: %s.",
+			  device, num_devices);
 		return -EINVAL;
 	}
 
@@ -92,9 +91,8 @@ static int _process_raid_event(char *params, const char *device)
 			/* Device is 'a'live, but not yet in-sync */
 			break;
 		case 'D':
-			syslog(LOG_ERR,
-			       "Device #%d of %s array, %s, has failed.",
-			       i, raid_type, device);
+			log_error("Device #%d of %s array, %s, has failed.",
+				  i, raid_type, device);
 			failure++;
 			break;
 		default:
@@ -107,13 +105,13 @@ static int _process_raid_event(char *params, const char *device)
 
 	p = strstr(resync_ratio, "/");
 	if (!p) {
-		syslog(LOG_ERR, "Failed to parse resync_ratio for %s: %s",
-		       device, resync_ratio);
+		log_error("Failed to parse resync_ratio for %s: %s.",
+			  device, resync_ratio);
 		return -EINVAL;
 	}
 	p[0] = '\0';
-	syslog(LOG_INFO, "%s array, %s, is %s in-sync.",
-	       raid_type, device, strcmp(resync_ratio, p+1) ? "not" : "now");
+	log_info("%s array, %s, is %s in-sync.",
+		 raid_type, device, strcmp(resync_ratio, p+1) ? "not" : "now");
 
 	return 0;
 }
@@ -135,18 +133,18 @@ void process_event(struct dm_task *dmt,
 					  &target_type, &params);
 
 		if (!target_type) {
-			syslog(LOG_INFO, "%s mapping lost.", device);
+			log_info("%s mapping lost.", device);
 			continue;
 		}
 
 		if (strcmp(target_type, "raid")) {
-			syslog(LOG_INFO, "%s has non-raid portion.", device);
+			log_info("%s has non-raid portion.", device);
 			continue;
 		}
 
 		if (_process_raid_event(params, device))
-			syslog(LOG_ERR, "Failed to process event for %s",
-			       device);
+			log_error("Failed to process event for %s.",
+				  device);
 	} while (next);
 
 	dmeventd_lvm2_unlock();
@@ -161,7 +159,7 @@ int register_device(const char *device,
 	if (!dmeventd_lvm2_init())
 		return 0;
 
-	syslog(LOG_INFO, "Monitoring RAID device %s for events.", device);
+	log_info("Monitoring RAID device %s for events.", device);
 
 	return 1;
 }
@@ -172,8 +170,8 @@ int unregister_device(const char *device,
 		      int minor __attribute__((unused)),
 		      void **unused __attribute__((unused)))
 {
-	syslog(LOG_INFO, "No longer monitoring RAID device %s for events.",
-	       device);
+	log_info("No longer monitoring RAID device %s for events.",
+		 device);
 	dmeventd_lvm2_exit();
 
 	return 1;
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 1b1d977..1372769 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -62,7 +62,7 @@ static int _run(const char *cmd, ...)
                 va_end(ap);
 
                 execvp(cmd, (char **)argv);
-                syslog(LOG_ERR, "Failed to execute %s: %s.\n", cmd, strerror(errno));
+                log_sys_error("exec", cmd);
                 exit(127);
         }
 
@@ -90,9 +90,11 @@ static void _umount(const char *device, int major, int minor)
 	char buffer[4096];
 	char *words[3];
 	struct stat st;
+	const char procmounts[] = "/proc/mounts";
 
-	if (!(mounts = fopen("/proc/mounts", "r"))) {
-		syslog(LOG_ERR, "Could not read /proc/mounts. Not umounting %s.\n", device);
+	if (!(mounts = fopen(procmounts, "r"))) {
+		log_sys_error("fopen", procmounts);
+		log_error("Not umounting %s.", device);
 		return;
 	}
 
@@ -112,15 +114,15 @@ static void _umount(const char *device, int major, int minor)
 		if (S_ISBLK(st.st_mode) &&
 		    major(st.st_rdev) == major &&
 		    minor(st.st_rdev) == minor) {
-			syslog(LOG_ERR, "Unmounting invalid snapshot %s from %s.\n", device, words[1]);
-                        if (!_run(UMOUNT_COMMAND, "-fl", words[1], NULL))
-                                syslog(LOG_ERR, "Failed to umount snapshot %s from %s: %s.\n",
-                                       device, words[1], strerror(errno));
+			log_error("Unmounting invalid snapshot %s from %s.", device, words[1]);
+			if (!_run(UMOUNT_COMMAND, "-fl", words[1], NULL))
+				log_error("Failed to umount snapshot %s from %s: %s.",
+					  device, words[1], strerror(errno));
 		}
 	}
 
 	if (fclose(mounts))
-		syslog(LOG_ERR, "Failed to close /proc/mounts.\n");
+		log_sys_error("close", procmounts);
 }
 
 void process_event(struct dm_task *dmt,
@@ -169,7 +171,7 @@ void process_event(struct dm_task *dmt,
 	 * the status string. Report the full status string to syslog.
 	 */
 	if (status->invalid || !status->total_sectors) {
-		syslog(LOG_ERR, "Snapshot %s changed state to: %s\n", device, params);
+		log_error("Snapshot %s changed state to: %s.", device, params);
 		state->percent_check = 0;
 		goto out;
 	}
@@ -181,10 +183,10 @@ void process_event(struct dm_task *dmt,
 		state->percent_check = (percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
 
 		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
-			syslog(LOG_WARNING, "Snapshot %s is now %i%% full.\n", device, percent);
+			log_warn("WARNING: Snapshot %s is now %i%% full.", device, percent);
 		/* Try to extend the snapshot, in accord with user-set policies */
 		if (!_extend(state->cmd_str))
-			syslog(LOG_ERR, "Failed to extend snapshot %s.\n", device);
+			log_error("Failed to extend snapshot %s.", device);
 	}
 
 out:
@@ -218,7 +220,7 @@ int register_device(const char *device,
 	state->percent_check = CHECK_MINIMUM;
 	*private = state;
 
-	syslog(LOG_INFO, "Monitoring snapshot %s\n", device);
+	log_info("Monitoring snapshot %s.", device);
 
 	return 1;
 bad:
@@ -226,7 +228,7 @@ bad:
 		dm_pool_destroy(statemem);
 	dmeventd_lvm2_exit();
 out:
-	syslog(LOG_ERR, "Failed to monitor snapshot %s.\n", device);
+	log_error("Failed to monitor snapshot %s.", device);
 
 	return 0;
 }
@@ -239,7 +241,7 @@ int unregister_device(const char *device,
 {
 	struct dso_state *state = *private;
 
-	syslog(LOG_INFO, "No longer monitoring snapshot %s\n", device);
+	log_info("No longer monitoring snapshot %s.", device);
 	dm_pool_destroy(state->mem);
 	dmeventd_lvm2_exit();
 
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 3f057a6..febf554 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -93,8 +93,8 @@ static int _has_deps(const char *name, int tp_major, int tp_minor, int *dev_mino
 	{
 		char dev_name[PATH_MAX];
 		if (dm_device_get_name(major, minor, 0, dev_name, sizeof(dev_name)))
-			syslog(LOG_DEBUG, "Found %s (%u:%u) depends on %s",
-			       name, major, *dev_minor, dev_name);
+			log_debug("Found %s (%u:%u) depends on %s.",
+				  name, major, *dev_minor, dev_name);
 	}
 #endif
 	r = 1;
@@ -144,7 +144,7 @@ out:
 static int _extend(struct dso_state *state)
 {
 #if THIN_DEBUG
-	syslog(LOG_INFO, "dmeventd executes: %s.\n", state->cmd_str);
+	log_info("dmeventd executes: %s.", state->cmd_str);
 #endif
 	return dmeventd_lvm2_run(state->cmd_str);
 }
@@ -173,7 +173,7 @@ static int _run(const char *cmd, ...)
 		va_end(ap);
 
 		execvp(cmd, (char **)argv);
-		syslog(LOG_ERR, "Failed to execute %s: %s.\n", cmd, strerror(errno));
+		log_sys_error("exec", cmd);
 		exit(127);
 	}
 
@@ -202,11 +202,11 @@ static int _umount_device(char *buffer, unsigned major, unsigned minor,
 	struct mountinfo_s *data = cb_data;
 
 	if ((major == data->info.major) && dm_bit(data->minors, minor)) {
-		syslog(LOG_INFO, "Unmounting thin volume %s from %s.\n",
-		       data->device, target);
+		log_info("Unmounting thin volume %s from %s.",
+			 data->device, target);
 		if (!_run(UMOUNT_COMMAND, "-fl", target, NULL))
-			syslog(LOG_ERR, "Failed to umount thin %s from %s: %s.\n",
-			       data->device, target, strerror(errno));
+			log_error("Failed to umount thin %s from %s: %s.",
+				  data->device, target, strerror(errno));
 	}
 
 	return 1;
@@ -230,17 +230,17 @@ static void _umount(struct dm_task *dmt, const char *device)
 	dmeventd_lvm2_unlock();
 
 	if (!(data.minors = dm_bitset_create(NULL, MINORS))) {
-		syslog(LOG_ERR, "Failed to allocate bitset. Not unmounting %s.\n", device);
+		log_error("Failed to allocate bitset. Not unmounting %s.", device);
 		goto out;
 	}
 
 	if (!_find_all_devs(data.minors, data.info.major, data.info.minor)) {
-		syslog(LOG_ERR, "Failed to detect mounted volumes for %s.\n", device);
+		log_error("Failed to detect mounted volumes for %s.", device);
 		goto out;
 	}
 
 	if (!dm_mountinfo_read(_umount_device, &data)) {
-		syslog(LOG_ERR, "Could not parse mountinfo file.\n");
+		log_error("Could not parse mountinfo file.");
 		goto out;
 	}
 
@@ -273,21 +273,21 @@ void process_event(struct dm_task *dmt,
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
 
 	if (!target_type || (strcmp(target_type, "thin-pool") != 0)) {
-		syslog(LOG_ERR, "Invalid target type.\n");
+		log_error("Invalid target type.");
 		goto out;
 	}
 
 	if (!dm_get_status_thin_pool(state->mem, params, &tps)) {
-		syslog(LOG_ERR, "Failed to parse status.\n");
+		log_error("Failed to parse status.");
 		_umount(dmt, device);
 		goto out;
 	}
 
 #if THIN_DEBUG
-	syslog(LOG_INFO, "%p: Got status %" PRIu64 " / %" PRIu64
-	       " %" PRIu64  " / %" PRIu64 ".\n", state,
-	       tps->used_metadata_blocks, tps->total_metadata_blocks,
-	       tps->used_data_blocks, tps->total_data_blocks);
+	log_debug("%p: Got status " FMTu64 " / " FMTu64 " " FMTu64
+		  " / " FMTu64 ".", state,
+		  tps->used_metadata_blocks, tps->total_metadata_blocks,
+		  tps->used_data_blocks, tps->total_data_blocks);
 #endif
 
 	/* Thin pool size had changed. Clear the threshold. */
@@ -311,12 +311,12 @@ void process_event(struct dm_task *dmt,
 
 		/* FIXME: extension of metadata needs to be written! */
 		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
-			syslog(LOG_WARNING, "Thin metadata %s is now %i%% full.\n",
-			       device, percent);
+			log_warn("WARNING: Thin metadata %s is now %i%% full.",
+				 device, percent);
 		 /* Try to extend the metadata, in accord with user-set policies */
 		if (!_extend(state)) {
-			syslog(LOG_ERR, "Failed to extend thin metadata %s.\n",
-			       device);
+			log_error("Failed to extend thin metadata %s.",
+				  device);
 			_umount(dmt, device);
 		}
 		/* FIXME: hmm READ-ONLY switch should happen in error path */
@@ -331,10 +331,11 @@ void process_event(struct dm_task *dmt,
 		state->data_percent_check = (percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
 
 		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
-			syslog(LOG_WARNING, "Thin %s is now %i%% full.\n", device, percent);
+			log_warn("WARNING: Thin %s is now %i%% full.",
+				 device, percent);
 		/* Try to extend the thin data, in accord with user-set policies */
 		if (!_extend(state)) {
-			syslog(LOG_ERR, "Failed to extend thin %s.\n", device);
+			log_error("Failed to extend thin %s.", device);
 			state->data_percent_check = 0;
 			_umount(dmt, device);
 		}
@@ -376,11 +377,11 @@ int register_device(const char *device,
 	state->data_percent_check = CHECK_MINIMUM;
 	*private = state;
 
-	syslog(LOG_INFO, "Monitoring thin %s.\n", device);
+	log_info("Monitoring thin %s.", device);
 
 	return 1;
 bad:
-	syslog(LOG_ERR, "Failed to monitor thin %s.\n", device);
+	log_error("Failed to monitor thin %s.", device);
 
 	return 0;
 }
@@ -393,7 +394,7 @@ int unregister_device(const char *device,
 {
 	struct dso_state *state = *private;
 
-	syslog(LOG_INFO, "No longer monitoring thin %s.\n", device);
+	log_info("No longer monitoring thin %s.", device);
 	dm_pool_destroy(state->mem);
 	dmeventd_lvm2_exit();
 


