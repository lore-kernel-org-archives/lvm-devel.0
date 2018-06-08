From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 8 Jun 2018 09:25:49 -0400
Subject: master - device_mapper: remove dbg_malloc.
Message-ID: <201806081325.w58DPna3015642@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d5da55ed85248adb066d293c2a1b863ce17d2779
Commit:        d5da55ed85248adb066d293c2a1b863ce17d2779
Parent:        c78239d8605f333915543c0e0c3ccf4f4ef5ee8f
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 8 13:40:53 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 8 13:40:53 2018 +0100

device_mapper: remove dbg_malloc.

I wrote dbg_malloc before we had valgrind.  These days there's just
no need.
---
 daemons/cmirrord/functions.c           |   14 +-
 daemons/dmeventd/dmeventd.c            |   72 +++---
 daemons/dmeventd/libdevmapper-event.c  |   64 +++---
 daemons/dmfilemapd/dmfilemapd.c        |   14 +-
 daemons/lvmetad/lvmetad-core.c         |   78 +++---
 daemons/lvmpolld/lvmpolld-cmd-utils.c  |   10 +-
 daemons/lvmpolld/lvmpolld-core.c       |   16 +-
 daemons/lvmpolld/lvmpolld-data-utils.c |   54 ++--
 device_mapper/Makefile                 |    1 -
 device_mapper/all.h                    |   44 +---
 device_mapper/datastruct/bitset.c      |    5 +-
 device_mapper/datastruct/hash.c        |   21 +-
 device_mapper/ioctl/libdm-iface.c      |   56 +++---
 device_mapper/libdm-common.c           |   57 +++---
 device_mapper/libdm-config.c           |    8 +-
 device_mapper/libdm-deptree.c          |    5 +-
 device_mapper/libdm-file.c             |    4 +-
 device_mapper/libdm-report.c           |   45 ++--
 device_mapper/libdm-stats.c            |  119 +++++-----
 device_mapper/libdm-string.c           |   12 +-
 device_mapper/libdm-timestamp.c        |    7 +-
 device_mapper/mm/dbg_malloc.c          |  413 --------------------------------
 device_mapper/mm/pool-debug.c          |   20 +-
 device_mapper/mm/pool-fast.c           |    9 +-
 lib/activate/activate.c                |    2 +-
 lib/activate/dev_manager.c             |    4 +-
 lib/activate/fs.c                      |    4 +-
 lib/cache/lvmcache.c                   |   57 +++---
 lib/cache/lvmetad.c                    |    4 +-
 lib/cache_segtype/cache.c              |    7 +-
 lib/commands/toolcontext.c             |   15 +-
 lib/config/config.c                    |   16 +-
 lib/device/bcache.c                    |   40 ++--
 lib/device/dev-cache.c                 |   29 ++-
 lib/device/dev-io.c                    |    4 +-
 lib/device/dev-type.c                  |    5 +-
 lib/device/device.h                    |    2 +-
 lib/error/errseg.c                     |    5 +-
 lib/filters/filter-composite.c         |   11 +-
 lib/filters/filter-fwraid.c            |    5 +-
 lib/filters/filter-internal.c          |    5 +-
 lib/filters/filter-md.c                |    5 +-
 lib/filters/filter-mpath.c             |    5 +-
 lib/filters/filter-partitioned.c       |    5 +-
 lib/filters/filter-persistent.c        |   19 +-
 lib/filters/filter-signature.c         |    5 +-
 lib/filters/filter-type.c              |    5 +-
 lib/filters/filter-usable.c            |   11 +-
 lib/format_text/archiver.c             |    8 +-
 lib/format_text/export.c               |   33 ++--
 lib/format_text/flags.c                |    4 +-
 lib/format_text/format-text.c          |   32 ++--
 lib/format_text/text_label.c           |   19 +-
 lib/freeseg/freeseg.c                  |    5 +-
 lib/label/label.c                      |   21 +-
 lib/log/log.c                          |   10 +-
 lib/lvmpolld/lvmpolld-client.c         |    4 +-
 lib/metadata/lv_manip.c                |    6 +-
 lib/metadata/metadata-liblvm.c         |    6 +-
 lib/mirror/mirrored.c                  |    7 +-
 lib/misc/lib.h                         |    1 +
 lib/misc/lvm-file.c                    |   10 +-
 lib/misc/lvm-flock.c                   |   14 +-
 lib/mm/memlock.c                       |    4 +-
 lib/raid/raid.c                        |   11 +-
 lib/snapshot/snapshot.c                |    7 +-
 lib/striped/striped.c                  |    5 +-
 lib/thin/thin.c                        |    7 +-
 lib/unknown/unknown.c                  |   11 +-
 lib/zero/zero.c                        |    5 +-
 libdaemon/client/config-util.c         |   10 +-
 libdaemon/client/daemon-client.c       |    6 +-
 libdaemon/server/daemon-log.c          |   12 +-
 libdaemon/server/daemon-server.c       |    4 +-
 tools/command.c                        |   36 ++--
 tools/dmsetup.c                        |   95 ++++----
 tools/lvmcmdlib.c                      |    4 +-
 tools/pvck.c                           |    3 +-
 tools/toollib.c                        |    2 +-
 tools/vgcfgbackup.c                    |   12 +-
 80 files changed, 714 insertions(+), 1118 deletions(-)

diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index 5e43e1a..61bcf16 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -435,7 +435,7 @@ static int _clog_ctr(char *uuid, uint64_t luid,
 			block_on_error = 1;
 	}
 
-	lc = dm_zalloc(sizeof(*lc));
+	lc = zalloc(sizeof(*lc));
 	if (!lc) {
 		LOG_ERROR("Unable to allocate cluster log context");
 		r = -ENOMEM;
@@ -532,9 +532,9 @@ fail:
 			LOG_ERROR("Close device error, %s: %s",
 				  disk_path, strerror(errno));
 		free(lc->disk_buffer);
-		dm_free(lc->sync_bits);
-		dm_free(lc->clean_bits);
-		dm_free(lc);
+		free(lc->sync_bits);
+		free(lc->clean_bits);
+		free(lc);
 	}
 	return r;
 }
@@ -659,9 +659,9 @@ static int clog_dtr(struct dm_ulog_request *rq)
 			  strerror(errno));
 	if (lc->disk_buffer)
 		free(lc->disk_buffer);
-	dm_free(lc->clean_bits);
-	dm_free(lc->sync_bits);
-	dm_free(lc);
+	free(lc->clean_bits);
+	free(lc->sync_bits);
+	free(lc);
 
 	return 0;
 }
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 533186b..4b4e1f0 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -264,19 +264,19 @@ static pthread_cond_t _timeout_cond = PTHREAD_COND_INITIALIZER;
 /* DSO data allocate/free. */
 static void _free_dso_data(struct dso_data *data)
 {
-	dm_free(data->dso_name);
-	dm_free(data);
+	free(data->dso_name);
+	free(data);
 }
 
 static struct dso_data *_alloc_dso_data(struct message_data *data)
 {
-	struct dso_data *ret = (typeof(ret)) dm_zalloc(sizeof(*ret));
+	struct dso_data *ret = (typeof(ret)) zalloc(sizeof(*ret));
 
 	if (!ret)
 		return_NULL;
 
-	if (!(ret->dso_name = dm_strdup(data->dso_name))) {
-		dm_free(ret);
+	if (!(ret->dso_name = strdup(data->dso_name))) {
+		free(ret);
 		return_NULL;
 	}
 
@@ -397,9 +397,9 @@ static void _free_thread_status(struct thread_status *thread)
 	_lib_put(thread->dso_data);
 	if (thread->wait_task)
 		dm_task_destroy(thread->wait_task);
-	dm_free(thread->device.uuid);
-	dm_free(thread->device.name);
-	dm_free(thread);
+	free(thread->device.uuid);
+	free(thread->device.name);
+	free(thread);
 }
 
 /* Note: events_field must not be 0, ensured by caller */
@@ -408,7 +408,7 @@ static struct thread_status *_alloc_thread_status(const struct message_data *dat
 {
 	struct thread_status *thread;
 
-	if (!(thread = dm_zalloc(sizeof(*thread)))) {
+	if (!(thread = zalloc(sizeof(*thread)))) {
 		log_error("Cannot create new thread, out of memory.");
 		return NULL;
 	}
@@ -422,11 +422,11 @@ static struct thread_status *_alloc_thread_status(const struct message_data *dat
 	if (!dm_task_set_uuid(thread->wait_task, data->device_uuid))
 		goto_out;
 
-	if (!(thread->device.uuid = dm_strdup(data->device_uuid)))
+	if (!(thread->device.uuid = strdup(data->device_uuid)))
 		goto_out;
 
 	/* Until real name resolved, use UUID */
-	if (!(thread->device.name = dm_strdup(data->device_uuid)))
+	if (!(thread->device.name = strdup(data->device_uuid)))
 		goto_out;
 
 	/* runs ioctl and may register lvm2 pluging */
@@ -515,7 +515,7 @@ static int _fetch_string(char **ptr, char **src, const int delimiter)
 	if ((p = strchr(*src, delimiter))) {
 		if (*src < p) {
 			*p = 0; /* Temporary exit with \0 */
-			if (!(*ptr = dm_strdup(*src))) {
+			if (!(*ptr = strdup(*src))) {
 				log_error("Failed to fetch item %s.", *src);
 				ret = 0; /* Allocation fail */
 			}
@@ -525,7 +525,7 @@ static int _fetch_string(char **ptr, char **src, const int delimiter)
 		(*src)++; /* Skip delmiter, next field */
 	} else if ((len = strlen(*src))) {
 		/* No delimiter, item ends with '\0' */
-		if (!(*ptr = dm_strdup(*src))) {
+		if (!(*ptr = strdup(*src))) {
 			log_error("Failed to fetch last item %s.", *src);
 			ret = 0; /* Fail */
 		}
@@ -538,11 +538,11 @@ out:
 /* Free message memory. */
 static void _free_message(struct message_data *message_data)
 {
-	dm_free(message_data->id);
-	dm_free(message_data->dso_name);
-	dm_free(message_data->device_uuid);
-	dm_free(message_data->events_str);
-	dm_free(message_data->timeout_str);
+	free(message_data->id);
+	free(message_data->dso_name);
+	free(message_data->device_uuid);
+	free(message_data->events_str);
+	free(message_data->timeout_str);
 }
 
 /* Parse a register message from the client. */
@@ -574,7 +574,7 @@ static int _parse_message(struct message_data *message_data)
 		ret = 1;
 	}
 
-	dm_free(msg->data);
+	free(msg->data);
 	msg->data = NULL;
 
 	return ret;
@@ -608,8 +608,8 @@ static int _fill_device_data(struct thread_status *ts)
 	if (!dm_task_run(dmt))
 		goto fail;
 
-	dm_free(ts->device.name);
-	if (!(ts->device.name = dm_strdup(dm_task_get_name(dmt))))
+	free(ts->device.name);
+	if (!(ts->device.name = strdup(dm_task_get_name(dmt))))
 		goto fail;
 
 	if (!dm_task_get_info(dmt, &dmi))
@@ -696,8 +696,8 @@ static int _get_status(struct message_data *message_data)
 
 	len = strlen(message_data->id);
 	msg->size = size + len + 1;
-	dm_free(msg->data);
-	if (!(msg->data = dm_malloc(msg->size)))
+	free(msg->data);
+	if (!(msg->data = malloc(msg->size)))
 		goto out;
 
 	memcpy(msg->data, message_data->id, len);
@@ -712,7 +712,7 @@ static int _get_status(struct message_data *message_data)
 	ret = 0;
  out:
 	for (j = 0; j < i; ++j)
-		dm_free(buffers[j]);
+		free(buffers[j]);
 
 	return ret;
 }
@@ -721,7 +721,7 @@ static int _get_parameters(struct message_data *message_data) {
 	struct dm_event_daemon_message *msg = message_data->msg;
 	int size;
 
-	dm_free(msg->data);
+	free(msg->data);
 	if ((size = dm_asprintf(&msg->data, "%s pid=%d daemon=%s exec_method=%s",
 				message_data->id, getpid(),
 				_foreground ? "no" : "yes",
@@ -1225,7 +1225,7 @@ static int _registered_device(struct message_data *message_data,
 	int r;
 	struct dm_event_daemon_message *msg = message_data->msg;
 
-	dm_free(msg->data);
+	free(msg->data);
 
 	if ((r = dm_asprintf(&(msg->data), "%s %s %s %u",
 			     message_data->id,
@@ -1365,7 +1365,7 @@ static int _get_timeout(struct message_data *message_data)
 	if (!thread)
 		return -ENODEV;
 
-	dm_free(msg->data);
+	free(msg->data);
 	msg->size = dm_asprintf(&(msg->data), "%s %" PRIu32,
 				message_data->id, thread->timeout);
 
@@ -1502,7 +1502,7 @@ static int _client_read(struct dm_event_fifos *fifos,
 			bytes = 0;
 			if (!size)
 				break; /* No data -> error */
-			buf = msg->data = dm_malloc(msg->size);
+			buf = msg->data = malloc(msg->size);
 			if (!buf)
 				break; /* No mem -> error */
 			header = 0;
@@ -1510,7 +1510,7 @@ static int _client_read(struct dm_event_fifos *fifos,
 	}
 
 	if (bytes != size) {
-		dm_free(msg->data);
+		free(msg->data);
 		msg->data = NULL;
 		return 0;
 	}
@@ -1530,7 +1530,7 @@ static int _client_write(struct dm_event_fifos *fifos,
 	fd_set fds;
 
 	size_t size = 2 * sizeof(uint32_t) + ((msg->data) ? msg->size : 0);
-	uint32_t *header = dm_malloc(size);
+	uint32_t *header = malloc(size);
 	char *buf = (char *)header;
 
 	if (!header) {
@@ -1560,7 +1560,7 @@ static int _client_write(struct dm_event_fifos *fifos,
 	}
 
 	if (header != temp)
-		dm_free(header);
+		free(header);
 
 	return (bytes == size);
 }
@@ -1622,7 +1622,7 @@ static int _do_process_request(struct dm_event_daemon_message *msg)
 			msg->size = dm_asprintf(&(msg->data), "%s %s %d", answer,
 						(msg->cmd == DM_EVENT_CMD_DIE) ? "DYING" : "HELLO",
 						DM_EVENT_PROTOCOL_VERSION);
-			dm_free(answer);
+			free(answer);
 		}
 	} else if (msg->cmd != DM_EVENT_CMD_ACTIVE && !_parse_message(&message_data)) {
 		stack;
@@ -1664,7 +1664,7 @@ static void _process_request(struct dm_event_fifos *fifos)
 
 	DEBUGLOG("<<< CMD:%s (0x%x) completed (result %d).", decode_cmd(cmd), cmd, msg.cmd);
 
-	dm_free(msg.data);
+	free(msg.data);
 
 	if (cmd == DM_EVENT_CMD_DIE) {
 		if (unlink(DMEVENTD_PIDFILE))
@@ -1975,7 +1975,7 @@ static int _reinstate_registrations(struct dm_event_fifos *fifos)
 	int i, ret;
 
 	ret = daemon_talk(fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0);
-	dm_free(msg.data);
+	free(msg.data);
 	msg.data = NULL;
 
 	if (ret) {
@@ -2061,13 +2061,13 @@ static void _restart_dmeventd(void)
 			++count;
 		}
 
-	if (!(_initial_registrations = dm_malloc(sizeof(char*) * (count + 1)))) {
+	if (!(_initial_registrations = malloc(sizeof(char*) * (count + 1)))) {
 		fprintf(stderr, "Memory allocation registration failed.\n");
 		goto bad;
 	}
 
 	for (i = 0; i < count; ++i) {
-		if (!(_initial_registrations[i] = dm_strdup(message))) {
+		if (!(_initial_registrations[i] = strdup(message))) {
 			fprintf(stderr, "Memory allocation for message failed.\n");
 			goto bad;
 		}
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 7f07228..4673f01 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -49,8 +49,8 @@ struct dm_event_handler {
 
 static void _dm_event_handler_clear_dev_info(struct dm_event_handler *dmevh)
 {
-	dm_free(dmevh->dev_name);
-	dm_free(dmevh->uuid);
+	free(dmevh->dev_name);
+	free(dmevh->uuid);
 	dmevh->dev_name = dmevh->uuid = NULL;
 	dmevh->major = dmevh->minor = 0;
 }
@@ -59,7 +59,7 @@ struct dm_event_handler *dm_event_handler_create(void)
 {
 	struct dm_event_handler *dmevh;
 
-	if (!(dmevh = dm_zalloc(sizeof(*dmevh)))) {
+	if (!(dmevh = zalloc(sizeof(*dmevh)))) {
 		log_error("Failed to allocate event handler.");
 		return NULL;
 	}
@@ -70,9 +70,9 @@ struct dm_event_handler *dm_event_handler_create(void)
 void dm_event_handler_destroy(struct dm_event_handler *dmevh)
 {
 	_dm_event_handler_clear_dev_info(dmevh);
-	dm_free(dmevh->dso);
-	dm_free(dmevh->dmeventd_path);
-	dm_free(dmevh);
+	free(dmevh->dso);
+	free(dmevh->dmeventd_path);
+	free(dmevh);
 }
 
 int dm_event_handler_set_dmeventd_path(struct dm_event_handler *dmevh, const char *dmeventd_path)
@@ -80,9 +80,9 @@ int dm_event_handler_set_dmeventd_path(struct dm_event_handler *dmevh, const cha
 	if (!dmeventd_path) /* noop */
 		return 0;
 
-	dm_free(dmevh->dmeventd_path);
+	free(dmevh->dmeventd_path);
 
-	if (!(dmevh->dmeventd_path = dm_strdup(dmeventd_path)))
+	if (!(dmevh->dmeventd_path = strdup(dmeventd_path)))
 		return -ENOMEM;
 
 	return 0;
@@ -93,9 +93,9 @@ int dm_event_handler_set_dso(struct dm_event_handler *dmevh, const char *path)
 	if (!path) /* noop */
 		return 0;
 
-	dm_free(dmevh->dso);
+	free(dmevh->dso);
 
-	if (!(dmevh->dso = dm_strdup(path)))
+	if (!(dmevh->dso = strdup(path)))
 		return -ENOMEM;
 
 	return 0;
@@ -108,7 +108,7 @@ int dm_event_handler_set_dev_name(struct dm_event_handler *dmevh, const char *de
 
 	_dm_event_handler_clear_dev_info(dmevh);
 
-	if (!(dmevh->dev_name = dm_strdup(dev_name)))
+	if (!(dmevh->dev_name = strdup(dev_name)))
 		return -ENOMEM;
 
 	return 0;
@@ -121,7 +121,7 @@ int dm_event_handler_set_uuid(struct dm_event_handler *dmevh, const char *uuid)
 
 	_dm_event_handler_clear_dev_info(dmevh);
 
-	if (!(dmevh->uuid = dm_strdup(uuid)))
+	if (!(dmevh->uuid = strdup(uuid)))
 		return -ENOMEM;
 
 	return 0;
@@ -261,7 +261,7 @@ static int _daemon_read(struct dm_event_fifos *fifos,
 		if (header && (bytes == 2 * sizeof(uint32_t))) {
 			msg->cmd = ntohl(header[0]);
 			msg->size = ntohl(header[1]);
-			buf = msg->data = dm_malloc(msg->size);
+			buf = msg->data = malloc(msg->size);
 			size = msg->size;
 			bytes = 0;
 			header = 0;
@@ -269,7 +269,7 @@ static int _daemon_read(struct dm_event_fifos *fifos,
 	}
 
 	if (bytes != size) {
-		dm_free(msg->data);
+		free(msg->data);
 		msg->data = NULL;
 	}
 	return bytes == size;
@@ -372,13 +372,13 @@ int daemon_talk(struct dm_event_fifos *fifos,
 	 */
 	if (!_daemon_write(fifos, msg)) {
 		stack;
-		dm_free(msg->data);
+		free(msg->data);
 		msg->data = NULL;
 		return -EIO;
 	}
 
 	do {
-		dm_free(msg->data);
+		free(msg->data);
 		msg->data = NULL;
 
 		if (!_daemon_read(fifos, msg)) {
@@ -621,7 +621,7 @@ static int _do_event(int cmd, char *dmeventd_path, struct dm_event_daemon_messag
 
 	ret = daemon_talk(&fifos, msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0);
 
-	dm_free(msg->data);
+	free(msg->data);
 	msg->data = 0;
 
 	if (!ret)
@@ -661,7 +661,7 @@ int dm_event_register_handler(const struct dm_event_handler *dmevh)
 		ret = 0;
 	}
 
-	dm_free(msg.data);
+	free(msg.data);
 
 	dm_task_destroy(dmt);
 
@@ -688,7 +688,7 @@ int dm_event_unregister_handler(const struct dm_event_handler *dmevh)
 		ret = 0;
 	}
 
-	dm_free(msg.data);
+	free(msg.data);
 
 	dm_task_destroy(dmt);
 
@@ -704,7 +704,7 @@ static char *_fetch_string(char **src, const int delimiter)
 	if ((p = strchr(*src, delimiter)))
 		*p = 0;
 
-	if ((ret = dm_strdup(*src)))
+	if ((ret = strdup(*src)))
 		*src += strlen(ret) + 1;
 
 	if (p)
@@ -724,11 +724,11 @@ static int _parse_message(struct dm_event_daemon_message *msg, char **dso_name,
 	    (*dso_name = _fetch_string(&p, ' ')) &&
 	    (*uuid = _fetch_string(&p, ' '))) {
 		*evmask = atoi(p);
-		dm_free(id);
+		free(id);
 		return 0;
 	}
 
-	dm_free(id);
+	free(id);
 	return -ENOMEM;
 }
 
@@ -770,7 +770,7 @@ int dm_event_get_registered_device(struct dm_event_handler *dmevh, int next)
 	dm_task_destroy(dmt);
 	dmt = NULL;
 
-	dm_free(msg.data);
+	free(msg.data);
 	msg.data = NULL;
 
 	_dm_event_handler_clear_dev_info(dmevh);
@@ -779,7 +779,7 @@ int dm_event_get_registered_device(struct dm_event_handler *dmevh, int next)
 		goto fail;
 	}
 
-	if (!(dmevh->uuid = dm_strdup(reply_uuid))) {
+	if (!(dmevh->uuid = strdup(reply_uuid))) {
 		ret = -ENOMEM;
 		goto fail;
 	}
@@ -792,13 +792,13 @@ int dm_event_get_registered_device(struct dm_event_handler *dmevh, int next)
 	dm_event_handler_set_dso(dmevh, reply_dso);
 	dm_event_handler_set_event_mask(dmevh, reply_mask);
 
-	dm_free(reply_dso);
+	free(reply_dso);
 	reply_dso = NULL;
 
-	dm_free(reply_uuid);
+	free(reply_uuid);
 	reply_uuid = NULL;
 
-	if (!(dmevh->dev_name = dm_strdup(dm_task_get_name(dmt)))) {
+	if (!(dmevh->dev_name = strdup(dm_task_get_name(dmt)))) {
 		ret = -ENOMEM;
 		goto fail;
 	}
@@ -816,9 +816,9 @@ int dm_event_get_registered_device(struct dm_event_handler *dmevh, int next)
 	return ret;
 
  fail:
-	dm_free(msg.data);
-	dm_free(reply_dso);
-	dm_free(reply_uuid);
+	free(msg.data);
+	free(reply_dso);
+	free(reply_uuid);
 	_dm_event_handler_clear_dev_info(dmevh);
 	if (dmt)
 		dm_task_destroy(dmt);
@@ -983,12 +983,12 @@ int dm_event_get_timeout(const char *device_path, uint32_t *timeout)
 		if (!p) {
 			log_error("Malformed reply from dmeventd '%s'.",
 				  msg.data);
-			dm_free(msg.data);
+			free(msg.data);
 			return -EIO;
 		}
 		*timeout = atoi(p);
 	}
-	dm_free(msg.data);
+	free(msg.data);
 
 	return ret;
 }
diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 4e048ff..726ad6e 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -311,7 +311,7 @@ static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
 		return 0;
 	}
 
-	fm->path = dm_strdup(argv[0]);
+	fm->path = strdup(argv[0]);
 	if (!fm->path) {
 		_early_log("Could not allocate memory for path argument.");
 		return 0;
@@ -538,8 +538,8 @@ static void _filemap_monitor_destroy(struct filemap_monitor *fm)
 		_filemap_monitor_end_notify(fm);
 		_filemap_monitor_close_fd(fm);
 	}
-	dm_free((void *) fm->program_id);
-	dm_free(fm->path);
+	free((void *) fm->program_id);
+	free(fm->path);
 }
 
 static int _filemap_monitor_check_same_file(int fd1, int fd2)
@@ -699,7 +699,7 @@ static int _update_regions(struct dm_stats *dms, struct filemap_monitor *fm)
 			 fm->group_id, regions[0]);
 		fm->group_id = regions[0];
 	}
-	dm_free(regions);
+	free(regions);
 	fm->nr_regions = nr_regions;
 	return 1;
 }
@@ -741,7 +741,7 @@ static int _dmfilemapd(struct filemap_monitor *fm)
 	 */
 	program_id = dm_stats_get_region_program_id(dms, fm->group_id);
 	if (program_id)
-		fm->program_id = dm_strdup(program_id);
+		fm->program_id = strdup(program_id);
 	else
 		fm->program_id = NULL;
 	dm_stats_set_program_id(dms, 1, program_id);
@@ -817,7 +817,7 @@ int main(int argc, char **argv)
 	memset(&fm, 0, sizeof(fm));
 
 	if (!_parse_args(argc, argv, &fm)) {
-		dm_free(fm.path);
+		free(fm.path);
 		return 1;
 	}
 
@@ -828,7 +828,7 @@ int main(int argc, char **argv)
 		 _mode_names[fm.mode], fm.path);
 
 	if (!_foreground && !_daemonise(&fm)) {
-		dm_free(fm.path);
+		free(fm.path);
 		return 1;
 	}
 
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 8858e29..cd44be5 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -259,19 +259,19 @@ static void destroy_metadata_hashes(lvmetad_state *s)
 		dm_config_destroy(dm_hash_get_data(s->pvid_to_pvmeta, n));
 
 	dm_hash_iterate(n, s->vgid_to_vgname)
-		dm_free(dm_hash_get_data(s->vgid_to_vgname, n));
+		free(dm_hash_get_data(s->vgid_to_vgname, n));
 
 	dm_hash_iterate(n, s->vgname_to_vgid)
-		dm_free(dm_hash_get_data(s->vgname_to_vgid, n));
+		free(dm_hash_get_data(s->vgname_to_vgid, n));
 
 	dm_hash_iterate(n, s->vgid_to_info)
-		dm_free(dm_hash_get_data(s->vgid_to_info, n));
+		free(dm_hash_get_data(s->vgid_to_info, n));
 
 	dm_hash_iterate(n, s->device_to_pvid)
-		dm_free(dm_hash_get_data(s->device_to_pvid, n));
+		free(dm_hash_get_data(s->device_to_pvid, n));
 
 	dm_hash_iterate(n, s->pvid_to_vgid)
-		dm_free(dm_hash_get_data(s->pvid_to_vgid, n));
+		free(dm_hash_get_data(s->pvid_to_vgid, n));
 
 	dm_hash_destroy(s->pvid_to_pvmeta);
 	dm_hash_destroy(s->vgid_to_metadata);
@@ -818,19 +818,19 @@ static int _update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
 		if (mode == MARK_OUTDATED)
 			mark_outdated_pv(s, vgid, pvid);
 
-		if (!(vgid_dup = dm_strdup(vgid))) {
+		if (!(vgid_dup = strdup(vgid))) {
 			ERROR(s, "update_pvid_to_vgid out of memory for vgid %s", vgid);
 			goto abort_daemon;
 		}
 
 		if (!dm_hash_insert(s->pvid_to_vgid, pvid, vgid_dup)) {
 			ERROR(s, "update_pvid_to_vgid out of memory for hash insert vgid %s", vgid_dup);
-			dm_free(vgid_dup);
+			free(vgid_dup);
 			goto abort_daemon;
 		}
 
 		/* pvid_to_vgid no longer references vgid_old */
-		dm_free(vgid_old);
+		free(vgid_old);
 
 		DEBUGLOG(s, "moving PV %s to VG %s", pvid, vgid);
 	}
@@ -889,9 +889,9 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 		dm_config_destroy(meta_lookup);
 	if (outdated_pvs_lookup)
 		dm_config_destroy(outdated_pvs_lookup);
-	dm_free(info_lookup);
-	dm_free(name_lookup);
-	dm_free(vgid_lookup);
+	free(info_lookup);
+	free(name_lookup);
+	free(vgid_lookup);
 	return 1;
 }
 
@@ -950,7 +950,7 @@ static void _purge_metadata(lvmetad_state *s, const char *arg_name, const char *
 
 	if ((rem_vgid = dm_hash_lookup_with_val(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1))) {
 		dm_hash_remove_with_val(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1);
-		dm_free(rem_vgid);
+		free(rem_vgid);
 	}
 }
 
@@ -978,10 +978,10 @@ static int _update_metadata_new_vgid(lvmetad_state *s,
 	int abort_daemon = 0;
 	int retval = 0;
 
-	if (!(new_vgid_dup = dm_strdup(new_vgid)))
+	if (!(new_vgid_dup = strdup(new_vgid)))
 		goto ret;
 
-	if (!(arg_name_dup = dm_strdup(arg_name)))
+	if (!(arg_name_dup = strdup(arg_name)))
 		goto ret;
 
 	/*
@@ -999,7 +999,7 @@ static int _update_metadata_new_vgid(lvmetad_state *s,
 
 	if ((rem_info = dm_hash_lookup(s->vgid_to_info, old_vgid))) {
 		dm_hash_remove(s->vgid_to_info, old_vgid);
-		dm_free(rem_info);
+		free(rem_info);
 	}
 
 	if ((rem_outdated = dm_hash_lookup(s->vgid_to_outdated_pvs, old_vgid))) {
@@ -1013,7 +1013,7 @@ static int _update_metadata_new_vgid(lvmetad_state *s,
 
 	dm_hash_remove_with_val(s->vgname_to_vgid, arg_name, old_vgid, strlen(old_vgid) + 1);
 	dm_hash_remove(s->vgid_to_vgname, old_vgid);
-	dm_free((char *)old_vgid);
+	free((char *)old_vgid);
 	old_vgid = NULL;
 
 	/*
@@ -1085,10 +1085,10 @@ static int _update_metadata_new_name(lvmetad_state *s,
 	int abort_daemon = 0;
 	int retval = 0;
 
-	if (!(new_name_dup = dm_strdup(new_name)))
+	if (!(new_name_dup = strdup(new_name)))
 		goto ret;
 
-	if (!(arg_vgid_dup = dm_strdup(arg_vgid)))
+	if (!(arg_vgid_dup = strdup(arg_vgid)))
 		goto ret;
 
 	/*
@@ -1106,7 +1106,7 @@ static int _update_metadata_new_name(lvmetad_state *s,
 
 	if ((rem_info = dm_hash_lookup(s->vgid_to_info, arg_vgid))) {
 		dm_hash_remove(s->vgid_to_info, arg_vgid);
-		dm_free(rem_info);
+		free(rem_info);
 	}
 
 	if ((rem_outdated = dm_hash_lookup(s->vgid_to_outdated_pvs, arg_vgid))) {
@@ -1120,7 +1120,7 @@ static int _update_metadata_new_name(lvmetad_state *s,
 
 	dm_hash_remove(s->vgid_to_vgname, arg_vgid);
 	dm_hash_remove_with_val(s->vgname_to_vgid, old_name, arg_vgid, strlen(arg_vgid) + 1);
-	dm_free((char *)old_name);
+	free((char *)old_name);
 	old_name = NULL;
 
 	/*
@@ -1183,10 +1183,10 @@ static int _update_metadata_add_new(lvmetad_state *s, const char *new_name, cons
 
 	DEBUGLOG(s, "update_metadata_add_new for %s %s", new_name, new_vgid);
 
-	if (!(new_name_dup = dm_strdup(new_name)))
+	if (!(new_name_dup = strdup(new_name)))
 		goto out_free;
 
-	if (!(new_vgid_dup = dm_strdup(new_vgid)))
+	if (!(new_vgid_dup = strdup(new_vgid)))
 		goto out_free;
 
 	if (!dm_hash_insert(s->vgid_to_metadata, new_vgid, new_meta)) {
@@ -1218,8 +1218,8 @@ static int _update_metadata_add_new(lvmetad_state *s, const char *new_name, cons
 out:
 out_free:
 	if (!new_name_dup || !new_vgid_dup || abort_daemon) {
-		dm_free(new_name_dup);
-		dm_free(new_vgid_dup);
+		free(new_name_dup);
+		free(new_vgid_dup);
 		ERROR(s, "lvmetad could not be updated and is aborting.");
 		exit(EXIT_FAILURE);
 	}
@@ -1799,17 +1799,17 @@ static response pv_gone(lvmetad_state *s, request r)
 		 * mappings for this vg, which will free the "vgid" string that
 		 * was returned above from the pvid_to_vgid lookup.
 		 */
-		if (!(vgid_dup = dm_strdup(vgid)))
+		if (!(vgid_dup = strdup(vgid)))
 			return reply_fail("out of memory");
 
 		vg_remove_if_missing(s, vgid_dup, 1);
-		dm_free(vgid_dup);
+		free(vgid_dup);
 		vgid_dup = NULL;
 		vgid = NULL;
 	}
 
 	dm_config_destroy(pvmeta);
-	dm_free(old_pvid);
+	free(old_pvid);
 
 	return daemon_reply_simple("OK", NULL );
 }
@@ -2082,7 +2082,7 @@ static response pv_found(lvmetad_state *s, request r)
 		DEBUGLOG(s, "pv_found new entry device_to_pvid %" PRIu64 " to %s",
 			 new_device, new_pvid);
 
-		if (!(new_pvid_dup = dm_strdup(new_pvid)))
+		if (!(new_pvid_dup = strdup(new_pvid)))
 			goto nomem_free1;
 
 		if (!dm_hash_insert_binary(s->device_to_pvid, &new_device, sizeof(new_device), new_pvid_dup))
@@ -2122,7 +2122,7 @@ static response pv_found(lvmetad_state *s, request r)
 				         arg_device, arg_pvid);
 				dm_config_destroy(new_pvmeta);
 				/* device_to_pvid no longer references prev_pvid_lookup */
-				dm_free((void*)prev_pvid_on_dev);
+				free((void*)prev_pvid_on_dev);
 				s->flags |= GLFL_DISABLE;
 				s->flags |= GLFL_DISABLE_REASON_DUPLICATES;
 				return reply_fail("Ignore duplicate PV");
@@ -2130,7 +2130,7 @@ static response pv_found(lvmetad_state *s, request r)
 		}
 
 
-		if (!(new_pvid_dup = dm_strdup(new_pvid)))
+		if (!(new_pvid_dup = strdup(new_pvid)))
 			goto nomem_free1;
 
 		if (!dm_hash_insert_binary(s->device_to_pvid, &arg_device, sizeof(arg_device), new_pvid_dup))
@@ -2218,22 +2218,22 @@ static response pv_found(lvmetad_state *s, request r)
 		char *tmp_vgid;
 
 	       	if (!arg_vgid || strcmp(arg_vgid, prev_vgid_on_dev)) {
-			tmp_vgid = dm_strdup(prev_vgid_on_dev);
+			tmp_vgid = strdup(prev_vgid_on_dev);
 			/* vg_remove_if_missing will clear and free
 			   the string pointed to by prev_vgid_on_dev. */
 			vg_remove_if_missing(s, tmp_vgid, 1);
-			dm_free(tmp_vgid);
+			free(tmp_vgid);
 		}
 
 		/* vg_remove_if_missing may have remapped prev_pvid_on_dev to orphan */
 		if ((tmp_vgid = dm_hash_lookup(s->pvid_to_vgid, prev_pvid_on_dev))) {
 			dm_hash_remove(s->pvid_to_vgid, prev_pvid_on_dev);
-			dm_free(tmp_vgid);
+			free(tmp_vgid);
 		}
 	}
 
 	/* This was unhashed from device_to_pvid above. */
-	dm_free((void *)prev_pvid_on_dev);
+	free((void *)prev_pvid_on_dev);
 
 	return daemon_reply_simple("OK",
 				   "status = %s", vg_status,
@@ -2245,7 +2245,7 @@ static response pv_found(lvmetad_state *s, request r)
 				   NULL);
 
  nomem_free2:
-	dm_free(new_pvid_dup);
+	free(new_pvid_dup);
  nomem_free1:
 	dm_config_destroy(new_pvmeta);
  nomem:
@@ -2525,7 +2525,7 @@ inval:
 
 	info = dm_hash_lookup(s->vgid_to_info, uuid);
 	if (!info) {
-		if (!(info = dm_zalloc(sizeof(struct vg_info))))
+		if (!(info = zalloc(sizeof(struct vg_info))))
 			goto bad;
 		if (!dm_hash_insert(s->vgid_to_info, uuid, (void*)info))
 			goto bad;
@@ -2570,7 +2570,7 @@ static void _dump_pairs(struct buffer *buf, struct dm_hash_table *ht, const char
 			(void) dm_asprintf(&append, "    %s = \"%s\"\n", key, val);
 		if (append)
 			buffer_append(buf, append);
-		dm_free(append);
+		free(append);
 	}
 	buffer_append(buf, "}\n");
 }
@@ -2590,7 +2590,7 @@ static void _dump_info_version(struct buffer *buf, struct dm_hash_table *ht, con
 		(void) dm_asprintf(&append, "    %s = %lld\n", key, (long long)info->external_version);
 		if (append)
 			buffer_append(buf, append);
-		dm_free(append);
+		free(append);
 		n = dm_hash_get_next(ht, n);
 	}
 	buffer_append(buf, "}\n");
@@ -2611,7 +2611,7 @@ static void _dump_info_flags(struct buffer *buf, struct dm_hash_table *ht, const
 		(void) dm_asprintf(&append, "    %s = %llx\n", key, (long long)info->flags);
 		if (append)
 			buffer_append(buf, append);
-		dm_free(append);
+		free(append);
 		n = dm_hash_get_next(ht, n);
 	}
 	buffer_append(buf, "}\n");
diff --git a/daemons/lvmpolld/lvmpolld-cmd-utils.c b/daemons/lvmpolld/lvmpolld-cmd-utils.c
index 601338f..865b47e 100644
--- a/daemons/lvmpolld/lvmpolld-cmd-utils.c
+++ b/daemons/lvmpolld/lvmpolld-cmd-utils.c
@@ -36,7 +36,7 @@ static int add_to_cmd_arr(const char ***cmdargv, const char *str, unsigned *ind)
 	const char **newargv;
 
 	if (*ind && !(*ind % MIN_ARGV_SIZE)) {
-		newargv = dm_realloc(*cmdargv, (*ind / MIN_ARGV_SIZE + 1) * MIN_ARGV_SIZE * sizeof(char *));
+		newargv = realloc(*cmdargv, (*ind / MIN_ARGV_SIZE + 1) * MIN_ARGV_SIZE * sizeof(char *));
 		if (!newargv)
 			return 0;
 		*cmdargv = newargv;
@@ -50,7 +50,7 @@ static int add_to_cmd_arr(const char ***cmdargv, const char *str, unsigned *ind)
 const char **cmdargv_ctr(const struct lvmpolld_lv *pdlv, const char *lvm_binary, unsigned abort_polling, unsigned handle_missing_pvs)
 {
 	unsigned i = 0;
-	const char **cmd_argv = dm_malloc(MIN_ARGV_SIZE * sizeof(char *));
+	const char **cmd_argv = malloc(MIN_ARGV_SIZE * sizeof(char *));
 
 	if (!cmd_argv)
 		return NULL;
@@ -98,7 +98,7 @@ const char **cmdargv_ctr(const struct lvmpolld_lv *pdlv, const char *lvm_binary,
 
 	return cmd_argv;
 err:
-	dm_free(cmd_argv);
+	free(cmd_argv);
 	return NULL;
 }
 
@@ -122,7 +122,7 @@ static int copy_env(const char ***cmd_envp, unsigned *i, const char *exclude)
 const char **cmdenvp_ctr(const struct lvmpolld_lv *pdlv)
 {
 	unsigned i = 0;
-	const char **cmd_envp = dm_malloc(MIN_ARGV_SIZE * sizeof(char *));
+	const char **cmd_envp = malloc(MIN_ARGV_SIZE * sizeof(char *));
 
 	if (!cmd_envp)
 		return NULL;
@@ -141,6 +141,6 @@ const char **cmdenvp_ctr(const struct lvmpolld_lv *pdlv)
 
 	return cmd_envp;
 err:
-	dm_free(cmd_envp);
+	free(cmd_envp);
 	return NULL;
 }
diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index fd73272..3aac65f 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -530,7 +530,7 @@ static response progress_info(client_handle h, struct lvmpolld_state *ls, reques
 
 	pdst_unlock(pdst);
 
-	dm_free(id);
+	free(id);
 
 	if (pdlv) {
 		if (st.error)
@@ -673,7 +673,7 @@ static response poll_init(client_handle h, struct lvmpolld_state *ls, request re
 			      PD_LOG_PREFIX, "poll operation type mismatch on LV identified by",
 			      id,
 			      polling_op(pdlv_get_type(pdlv)), polling_op(type));
-			dm_free(id);
+			free(id);
 			return reply(LVMPD_RESP_EINVAL,
 				     REASON_DIFFERENT_OPERATION_IN_PROGRESS);
 		}
@@ -683,14 +683,14 @@ static response poll_init(client_handle h, struct lvmpolld_state *ls, request re
 				      lvname, sysdir, type, abort_polling, 2 * uinterval);
 		if (!pdlv) {
 			pdst_unlock(pdst);
-			dm_free(id);
+			free(id);
 			return reply(LVMPD_RESP_FAILED, REASON_ENOMEM);
 		}
 		if (!pdst_locked_insert(pdst, id, pdlv)) {
 			pdlv_destroy(pdlv);
 			pdst_unlock(pdst);
 			ERROR(ls, "%s: %s", PD_LOG_PREFIX, "couldn't store internal LV data structure");
-			dm_free(id);
+			free(id);
 			return reply(LVMPD_RESP_FAILED, REASON_ENOMEM);
 		}
 		if (!spawn_detached_thread(pdlv)) {
@@ -698,7 +698,7 @@ static response poll_init(client_handle h, struct lvmpolld_state *ls, request re
 			pdst_locked_remove(pdst, id);
 			pdlv_destroy(pdlv);
 			pdst_unlock(pdst);
-			dm_free(id);
+			free(id);
 			return reply(LVMPD_RESP_FAILED, REASON_ENOMEM);
 		}
 
@@ -709,7 +709,7 @@ static response poll_init(client_handle h, struct lvmpolld_state *ls, request re
 
 	pdst_unlock(pdst);
 
-	dm_free(id);
+	free(id);
 
 	return daemon_reply_simple(LVMPD_RESP_OK, NULL);
 }
@@ -806,7 +806,7 @@ static int printout_raw_response(const char *prefix, const char *msg)
 	char *buf;
 	char *pos;
 
-	buf = dm_strdup(msg);
+	buf = strdup(msg);
 	pos = buf;
 
 	if (!buf)
@@ -819,7 +819,7 @@ static int printout_raw_response(const char *prefix, const char *msg)
 		_log_line(pos, &b);
 		pos = next ? next + 1 : 0;
 	}
-	dm_free(buf);
+	free(buf);
 
 	return 1;
 }
diff --git a/daemons/lvmpolld/lvmpolld-data-utils.c b/daemons/lvmpolld/lvmpolld-data-utils.c
index d5e1139..23e316a 100644
--- a/daemons/lvmpolld/lvmpolld-data-utils.c
+++ b/daemons/lvmpolld/lvmpolld-data-utils.c
@@ -27,12 +27,12 @@ static char *_construct_full_lvname(const char *vgname, const char *lvname)
 	size_t l;
 
 	l = strlen(vgname) + strlen(lvname) + 2; /* vg/lv and \0 */
-	name = (char *) dm_malloc(l * sizeof(char));
+	name = (char *) malloc(l * sizeof(char));
 	if (!name)
 		return NULL;
 
 	if (dm_snprintf(name, l, "%s/%s", vgname, lvname) < 0) {
-		dm_free(name);
+		free(name);
 		name = NULL;
 	}
 
@@ -47,7 +47,7 @@ static char *_construct_lvm_system_dir_env(const char *sysdir)
 	 *  just single char to store NULL byte
 	 */
 	size_t l = sysdir ? strlen(sysdir) + 16 : 1;
-	char *env = (char *) dm_malloc(l * sizeof(char));
+	char *env = (char *) malloc(l * sizeof(char));
 
 	if (!env)
 		return NULL;
@@ -55,7 +55,7 @@ static char *_construct_lvm_system_dir_env(const char *sysdir)
 	*env = '\0';
 
 	if (sysdir && dm_snprintf(env, l, "%s%s", LVM_SYSTEM_DIR, sysdir) < 0) {
-		dm_free(env);
+		free(env);
 		env = NULL;
 	}
 
@@ -74,7 +74,7 @@ char *construct_id(const char *sysdir, const char *uuid)
 	size_t l;
 
 	l = strlen(uuid) + (sysdir ? strlen(sysdir) : 0) + 1;
-	id = (char *) dm_malloc(l * sizeof(char));
+	id = (char *) malloc(l * sizeof(char));
 	if (!id)
 		return NULL;
 
@@ -82,7 +82,7 @@ char *construct_id(const char *sysdir, const char *uuid)
 		     dm_snprintf(id, l, "%s", uuid);
 
 	if (r < 0) {
-		dm_free(id);
+		free(id);
 		id = NULL;
 	}
 
@@ -95,7 +95,7 @@ struct lvmpolld_lv *pdlv_create(struct lvmpolld_state *ls, const char *id,
 			   const char *sinterval, unsigned pdtimeout,
 			   struct lvmpolld_store *pdst)
 {
-	char *lvmpolld_id = dm_strdup(id), /* copy */
+	char *lvmpolld_id = strdup(id), /* copy */
 	     *full_lvname = _construct_full_lvname(vgname, lvname), /* copy */
 	     *lvm_system_dir_env = _construct_lvm_system_dir_env(sysdir); /* copy */
 
@@ -106,12 +106,12 @@ struct lvmpolld_lv *pdlv_create(struct lvmpolld_state *ls, const char *id,
 		.lvid = _get_lvid(lvmpolld_id, sysdir),
 		.lvname = full_lvname,
 		.lvm_system_dir_env = lvm_system_dir_env,
-		.sinterval = dm_strdup(sinterval), /* copy */
+		.sinterval = strdup(sinterval), /* copy */
 		.pdtimeout = pdtimeout < MIN_POLLING_TIMEOUT ? MIN_POLLING_TIMEOUT : pdtimeout,
 		.cmd_state = { .retcode = -1, .signal = 0 },
 		.pdst = pdst,
 		.init_rq_count = 1
-	}, *pdlv = (struct lvmpolld_lv *) dm_malloc(sizeof(struct lvmpolld_lv));
+	}, *pdlv = (struct lvmpolld_lv *) malloc(sizeof(struct lvmpolld_lv));
 
 	if (!pdlv || !tmp.lvid || !tmp.lvname || !tmp.lvm_system_dir_env || !tmp.sinterval)
 		goto err;
@@ -124,27 +124,27 @@ struct lvmpolld_lv *pdlv_create(struct lvmpolld_state *ls, const char *id,
 	return pdlv;
 
 err:
-	dm_free((void *)full_lvname);
-	dm_free((void *)lvmpolld_id);
-	dm_free((void *)lvm_system_dir_env);
-	dm_free((void *)tmp.sinterval);
-	dm_free((void *)pdlv);
+	free((void *)full_lvname);
+	free((void *)lvmpolld_id);
+	free((void *)lvm_system_dir_env);
+	free((void *)tmp.sinterval);
+	free((void *)pdlv);
 
 	return NULL;
 }
 
 void pdlv_destroy(struct lvmpolld_lv *pdlv)
 {
-	dm_free((void *)pdlv->lvmpolld_id);
-	dm_free((void *)pdlv->lvname);
-	dm_free((void *)pdlv->sinterval);
-	dm_free((void *)pdlv->lvm_system_dir_env);
-	dm_free((void *)pdlv->cmdargv);
-	dm_free((void *)pdlv->cmdenvp);
+	free((void *)pdlv->lvmpolld_id);
+	free((void *)pdlv->lvname);
+	free((void *)pdlv->sinterval);
+	free((void *)pdlv->lvm_system_dir_env);
+	free((void *)pdlv->cmdargv);
+	free((void *)pdlv->cmdenvp);
 
 	pthread_mutex_destroy(&pdlv->lock);
 
-	dm_free((void *)pdlv);
+	free((void *)pdlv);
 }
 
 unsigned pdlv_get_polling_finished(struct lvmpolld_lv *pdlv)
@@ -194,7 +194,7 @@ void pdlv_set_polling_finished(struct lvmpolld_lv *pdlv, unsigned finished)
 
 struct lvmpolld_store *pdst_init(const char *name)
 {
-	struct lvmpolld_store *pdst = (struct lvmpolld_store *) dm_malloc(sizeof(struct lvmpolld_store));
+	struct lvmpolld_store *pdst = (struct lvmpolld_store *) malloc(sizeof(struct lvmpolld_store));
 	if (!pdst)
 		return NULL;
 
@@ -212,7 +212,7 @@ struct lvmpolld_store *pdst_init(const char *name)
 err_mutex:
 	dm_hash_destroy(pdst->store);
 err_hash:
-	dm_free(pdst);
+	free(pdst);
 	return NULL;
 }
 
@@ -223,7 +223,7 @@ void pdst_destroy(struct lvmpolld_store *pdst)
 
 	dm_hash_destroy(pdst->store);
 	pthread_mutex_destroy(&pdst->lock);
-	dm_free(pdst);
+	free(pdst);
 }
 
 void pdst_locked_lock_all_pdlvs(const struct lvmpolld_store *pdst)
@@ -321,7 +321,7 @@ void pdst_locked_destroy_all_pdlvs(const struct lvmpolld_store *pdst)
 
 struct lvmpolld_thread_data *lvmpolld_thread_data_constructor(struct lvmpolld_lv *pdlv)
 {
-	struct lvmpolld_thread_data *data = (struct lvmpolld_thread_data *) dm_malloc(sizeof(struct lvmpolld_thread_data));
+	struct lvmpolld_thread_data *data = (struct lvmpolld_thread_data *) malloc(sizeof(struct lvmpolld_thread_data));
 	if (!data)
 		return NULL;
 
@@ -368,7 +368,7 @@ void lvmpolld_thread_data_destroy(void *thread_private)
 		pdst_unlock(data->pdlv->pdst);
 	}
 
-	/* may get reallocated in getline(). dm_free must not be used */
+	/* may get reallocated in getline(). free must not be used */
 	free(data->line);
 
 	if (data->fout && !fclose(data->fout))
@@ -389,5 +389,5 @@ void lvmpolld_thread_data_destroy(void *thread_private)
 	if (data->errpipe[1] >= 0)
 		(void) close(data->errpipe[1]);
 
-	dm_free(data);
+	free(data);
 }
diff --git a/device_mapper/Makefile b/device_mapper/Makefile
index 4036cb4..da97675 100644
--- a/device_mapper/Makefile
+++ b/device_mapper/Makefile
@@ -22,7 +22,6 @@ DEVICE_MAPPER_SOURCE=\
 	device_mapper/libdm-string.c \
 	device_mapper/libdm-targets.c \
 	device_mapper/libdm-timestamp.c \
-	device_mapper/mm/dbg_malloc.c \
 	device_mapper/mm/pool.c \
 	device_mapper/regex/matcher.c \
 	device_mapper/regex/parse_rx.c \
diff --git a/device_mapper/all.h b/device_mapper/all.h
index f7ff4ce..b1d5a8c 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -33,8 +33,6 @@
 
 #include "base/data-struct/list.h"
 
-#include "base/data-struct/list.h"
-
 #ifndef __GNUC__
 # define __typeof__ typeof
 #endif
@@ -826,7 +824,7 @@ int dm_stats_get_region_nr_histogram_bins(const struct dm_stats *dms,
  *
  * On sucess a pointer to the struct dm_histogram representing the
  * bounds values is returned, or NULL in the case of error. The returned
- * pointer should be freed using dm_free() when no longer required.
+ * pointer should be freed using free() when no longer required.
  */
 struct dm_histogram *dm_histogram_bounds_from_string(const char *bounds_str);
 
@@ -1325,7 +1323,7 @@ int dm_stats_get_group_descriptor(const struct dm_stats *dms,
  * On success the function returns a pointer to an array of uint64_t
  * containing the IDs of the newly created regions. The region_id
  * array is terminated by the value DM_STATS_REGION_NOT_PRESENT and
- * should be freed using dm_free() when no longer required.
+ * should be freed using free() when no longer required.
  *
  * On error NULL is returned.
  *
@@ -1357,7 +1355,7 @@ uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
  * regions that were not modified by the call).
  *
  * The region_id array is terminated by the special value
- * DM_STATS_REGION_NOT_PRESENT and should be freed using dm_free()
+ * DM_STATS_REGION_NOT_PRESENT and should be freed using free()
  * when no longer required.
  *
  * On error NULL is returned.
@@ -1478,7 +1476,7 @@ dm_string_mangling_t dm_get_name_mangling_mode(void);
 /*
  * Get mangled/unmangled form of the device-mapper name or uuid
  * irrespective of the global setting (set by dm_set_name_mangling_mode).
- * The name or uuid returned needs to be freed after use by calling dm_free!
+ * The name or uuid returned needs to be freed after use by calling free!
  */
 char *dm_task_get_name_mangled(const struct dm_task *dmt);
 char *dm_task_get_name_unmangled(const struct dm_task *dmt);
@@ -2070,35 +2068,7 @@ uint32_t dm_tree_get_cookie(struct dm_tree_node *node);
  * Library functions
  *****************************************************************************/
 
-/*******************
- * Memory management
- *******************/
-
-/*
- * Never use these functions directly - use the macros following instead.
- */
-void *dm_malloc_wrapper(size_t s, const char *file, int line)
-	__attribute__((__malloc__)) __attribute__((__warn_unused_result__));
-void *dm_malloc_aligned_wrapper(size_t s, size_t a, const char *file, int line)
-	__attribute__((__malloc__)) __attribute__((__warn_unused_result__));
-void *dm_zalloc_wrapper(size_t s, const char *file, int line)
-	__attribute__((__malloc__)) __attribute__((__warn_unused_result__));
-void *dm_realloc_wrapper(void *p, unsigned int s, const char *file, int line)
-	__attribute__((__warn_unused_result__));
-void dm_free_wrapper(void *ptr);
-char *dm_strdup_wrapper(const char *s, const char *file, int line)
-	__attribute__((__warn_unused_result__));
-int dm_dump_memory_wrapper(void);
-void dm_bounds_check_wrapper(void);
-
-#define dm_malloc(s) dm_malloc_wrapper((s), __FILE__, __LINE__)
-#define dm_malloc_aligned(s, a) dm_malloc_aligned_wrapper((s), (a),  __FILE__, __LINE__)
-#define dm_zalloc(s) dm_zalloc_wrapper((s), __FILE__, __LINE__)
-#define dm_strdup(s) dm_strdup_wrapper((s), __FILE__, __LINE__)
-#define dm_free(p) dm_free_wrapper(p)
-#define dm_realloc(p, s) dm_realloc_wrapper((p), (s), __FILE__, __LINE__)
-#define dm_dump_memory() dm_dump_memory_wrapper()
-#define dm_bounds_check() dm_bounds_check_wrapper()
+#define malloc_aligned(s, a) malloc_aligned_wrapper((s), (a),  __FILE__, __LINE__)
 
 /*
  * The pool allocator is useful when you are going to allocate
@@ -2265,7 +2235,7 @@ int dm_bit_get_prev(dm_bitset_t bs, int last_bit);
  * notation used is identical to the kernel bitmap parser (cpuset etc.)
  * and supports both lists ("1,2,3") and ranges ("1-2,5-8"). If the mem
  * parameter is NULL memory for the bitset will be allocated using
- * dm_malloc(). Otherwise the bitset will be allocated using the supplied
+ * malloc(). Otherwise the bitset will be allocated using the supplied
  * dm_pool.
  */
 dm_bitset_t dm_bitset_parse_list(const char *str, struct dm_pool *mem,
@@ -2557,7 +2527,7 @@ int dm_is_empty_dir(const char *dir);
 int dm_fclose(FILE *stream);
 
 /*
- * Returns size of a buffer which is allocated with dm_malloc.
+ * Returns size of a buffer which is allocated with malloc.
  * Pointer to the buffer is stored in *buf.
  * Returns -1 on failure leaving buf undefined.
  */
diff --git a/device_mapper/datastruct/bitset.c b/device_mapper/datastruct/bitset.c
index f093ac0..fc2c3c3 100644
--- a/device_mapper/datastruct/bitset.c
+++ b/device_mapper/datastruct/bitset.c
@@ -14,6 +14,7 @@
  */
 
 #include "device_mapper/misc/dmlib.h"
+#include "base/memory/zalloc.h"
 
 #include <ctype.h>
 
@@ -29,7 +30,7 @@ dm_bitset_t dm_bitset_create(struct dm_pool *mem, unsigned num_bits)
 	if (mem)
 		bs = dm_pool_zalloc(mem, size);
 	else
-		bs = dm_zalloc(size);
+		bs = zalloc(size);
 
 	if (!bs)
 		return NULL;
@@ -41,7 +42,7 @@ dm_bitset_t dm_bitset_create(struct dm_pool *mem, unsigned num_bits)
 
 void dm_bitset_destroy(dm_bitset_t bs)
 {
-	dm_free(bs);
+	free(bs);
 }
 
 int dm_bitset_equal(dm_bitset_t in1, dm_bitset_t in2)
diff --git a/device_mapper/datastruct/hash.c b/device_mapper/datastruct/hash.c
index 59e719b..f16508a 100644
--- a/device_mapper/datastruct/hash.c
+++ b/device_mapper/datastruct/hash.c
@@ -14,6 +14,7 @@
  */
 
 #include "device_mapper/misc/dmlib.h"
+#include "base/memory/zalloc.h"
 
 struct dm_hash_node {
 	struct dm_hash_node *next;
@@ -59,7 +60,7 @@ static unsigned char _nums[] = {
 
 static struct dm_hash_node *_create_node(const char *str, unsigned len)
 {
-	struct dm_hash_node *n = dm_malloc(sizeof(*n) + len);
+	struct dm_hash_node *n = malloc(sizeof(*n) + len);
 
 	if (n) {
 		memcpy(n->key, str, len);
@@ -91,7 +92,7 @@ struct dm_hash_table *dm_hash_create(unsigned size_hint)
 {
 	size_t len;
 	unsigned new_size = 16u;
-	struct dm_hash_table *hc = dm_zalloc(sizeof(*hc));
+	struct dm_hash_table *hc = zalloc(sizeof(*hc));
 
 	if (!hc)
 		return_0;
@@ -102,14 +103,14 @@ struct dm_hash_table *dm_hash_create(unsigned size_hint)
 
 	hc->num_slots = new_size;
 	len = sizeof(*(hc->slots)) * new_size;
-	if (!(hc->slots = dm_zalloc(len)))
+	if (!(hc->slots = zalloc(len)))
 		goto_bad;
 
 	return hc;
 
       bad:
-	dm_free(hc->slots);
-	dm_free(hc);
+	free(hc->slots);
+	free(hc);
 	return 0;
 }
 
@@ -121,15 +122,15 @@ static void _free_nodes(struct dm_hash_table *t)
 	for (i = 0; i < t->num_slots; i++)
 		for (c = t->slots[i]; c; c = n) {
 			n = c->next;
-			dm_free(c);
+			free(c);
 		}
 }
 
 void dm_hash_destroy(struct dm_hash_table *t)
 {
 	_free_nodes(t);
-	dm_free(t->slots);
-	dm_free(t);
+	free(t->slots);
+	free(t);
 }
 
 static struct dm_hash_node **_find(struct dm_hash_table *t, const void *key,
@@ -187,7 +188,7 @@ void dm_hash_remove_binary(struct dm_hash_table *t, const void *key,
 	if (*c) {
 		struct dm_hash_node *old = *c;
 		*c = (*c)->next;
-		dm_free(old);
+		free(old);
 		t->num_nodes--;
 	}
 }
@@ -287,7 +288,7 @@ void dm_hash_remove_with_val(struct dm_hash_table *t, const char *key,
 	if (c && *c) {
 		struct dm_hash_node *old = *c;
 		*c = (*c)->next;
-		dm_free(old);
+		free(old);
 		t->num_nodes--;
 	}
 }
diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 3e1b445..bec7f0f 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "device_mapper/misc/dmlib.h"
 #include "device_mapper/ioctl/libdm-targets.h"
 #include "device_mapper/libdm-common.h"
@@ -467,7 +468,7 @@ static void _dm_zfree_string(char *string)
 {
 	if (string) {
 		memset(string, 0, strlen(string));
-		dm_free(string);
+		free(string);
 	}
 }
 
@@ -475,7 +476,7 @@ static void _dm_zfree_dmi(struct dm_ioctl *dmi)
 {
 	if (dmi) {
 		memset(dmi, 0, dmi->data_size);
-		dm_free(dmi);
+		free(dmi);
 	}
 }
 
@@ -486,8 +487,8 @@ static void _dm_task_free_targets(struct dm_task *dmt)
 	for (t = dmt->head; t; t = n) {
 		n = t->next;
 		_dm_zfree_string(t->params);
-		dm_free(t->type);
-		dm_free(t);
+		free(t->type);
+		free(t);
 	}
 
 	dmt->head = dmt->tail = NULL;
@@ -497,14 +498,14 @@ void dm_task_destroy(struct dm_task *dmt)
 {
 	_dm_task_free_targets(dmt);
 	_dm_zfree_dmi(dmt->dmi.v4);
-	dm_free(dmt->dev_name);
-	dm_free(dmt->mangled_dev_name);
-	dm_free(dmt->newname);
-	dm_free(dmt->message);
-	dm_free(dmt->geometry);
-	dm_free(dmt->uuid);
-	dm_free(dmt->mangled_uuid);
-	dm_free(dmt);
+	free(dmt->dev_name);
+	free(dmt->mangled_dev_name);
+	free(dmt->newname);
+	free(dmt->message);
+	free(dmt->geometry);
+	free(dmt->uuid);
+	free(dmt->mangled_uuid);
+	free(dmt);
 }
 
 /*
@@ -852,8 +853,8 @@ int dm_task_set_newuuid(struct dm_task *dmt, const char *newuuid)
 		newuuid = mangled_uuid;
 	}
 
-	dm_free(dmt->newname);
-	if (!(dmt->newname = dm_strdup(newuuid))) {
+	free(dmt->newname);
+	if (!(dmt->newname = strdup(newuuid))) {
 		log_error("dm_task_set_newuuid: strdup(%s) failed", newuuid);
 		return 0;
 	}
@@ -864,8 +865,8 @@ int dm_task_set_newuuid(struct dm_task *dmt, const char *newuuid)
 
 int dm_task_set_message(struct dm_task *dmt, const char *message)
 {
-	dm_free(dmt->message);
-	if (!(dmt->message = dm_strdup(message))) {
+	free(dmt->message);
+	if (!(dmt->message = strdup(message))) {
 		log_error("dm_task_set_message: strdup failed");
 		return 0;
 	}
@@ -883,7 +884,7 @@ int dm_task_set_sector(struct dm_task *dmt, uint64_t sector)
 int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads,
 			 const char *sectors, const char *start)
 {
-	dm_free(dmt->geometry);
+	free(dmt->geometry);
 	if (dm_asprintf(&(dmt->geometry), "%s %s %s %s",
 			cylinders, heads, sectors, start) < 0) {
 		log_error("dm_task_set_geometry: sprintf failed");
@@ -977,18 +978,18 @@ struct target *create_target(uint64_t start, uint64_t len, const char *type,
 		return NULL;
 	}
 
-	if (!(t = dm_zalloc(sizeof(*t)))) {
+	if (!(t = zalloc(sizeof(*t)))) {
 		log_error("create_target: malloc(%" PRIsize_t ") failed",
 			  sizeof(*t));
 		return NULL;
 	}
 
-	if (!(t->params = dm_strdup(params))) {
+	if (!(t->params = strdup(params))) {
 		log_error("create_target: strdup(params) failed");
 		goto bad;
 	}
 
-	if (!(t->type = dm_strdup(type))) {
+	if (!(t->type = strdup(type))) {
 		log_error("create_target: strdup(type) failed");
 		goto bad;
 	}
@@ -999,8 +1000,8 @@ struct target *create_target(uint64_t start, uint64_t len, const char *type,
 
       bad:
 	_dm_zfree_string(t->params);
-	dm_free(t->type);
-	dm_free(t);
+	free(t->type);
+	free(t);
 	return NULL;
 }
 
@@ -1168,7 +1169,7 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	while (repeat_count--)
 		len *= 2;
 
-	if (!(dmi = dm_zalloc(len)))
+	if (!(dmi = zalloc(len)))
 		return NULL;
 
 	version = &_cmd_data_v4[dmt->type].version;
@@ -1463,9 +1464,9 @@ static int _create_and_load_v4(struct dm_task *dmt)
 
 	/* Use the original structure last so the info will be correct */
 	dmt->type = DM_DEVICE_RESUME;
-	dm_free(dmt->uuid);
+	free(dmt->uuid);
 	dmt->uuid = NULL;
-	dm_free(dmt->mangled_uuid);
+	free(dmt->mangled_uuid);
 	dmt->mangled_uuid = NULL;
 
 	if (dm_task_run(dmt))
@@ -1473,9 +1474,9 @@ static int _create_and_load_v4(struct dm_task *dmt)
 
       revert:
 	dmt->type = DM_DEVICE_REMOVE;
-	dm_free(dmt->uuid);
+	free(dmt->uuid);
 	dmt->uuid = NULL;
-	dm_free(dmt->mangled_uuid);
+	free(dmt->mangled_uuid);
 	dmt->mangled_uuid = NULL;
 
 	/*
@@ -2141,7 +2142,6 @@ void dm_lib_exit(void)
 		dm_bitset_destroy(_dm_bitset);
 	_dm_bitset = NULL;
 	dm_pools_check_leaks();
-	dm_dump_memory();
 	_version_ok = 1;
 	_version_checked = 0;
 }
diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index bcf12cb..d46d4b0 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "device_mapper/misc/dmlib.h"
 #include "ioctl/libdm-targets.h"
 #include "libdm-common.h"
@@ -308,7 +309,7 @@ dm_string_mangling_t dm_get_name_mangling_mode(void)
 
 struct dm_task *dm_task_create(int type)
 {
-	struct dm_task *dmt = dm_zalloc(sizeof(*dmt));
+	struct dm_task *dmt = zalloc(sizeof(*dmt));
 
 	if (!dmt) {
 		log_error("dm_task_create: malloc(%" PRIsize_t ") failed",
@@ -317,7 +318,7 @@ struct dm_task *dm_task_create(int type)
 	}
 
 	if (!dm_check_version()) {
-		dm_free(dmt);
+		free(dmt);
 		return_NULL;
 	}
 
@@ -562,9 +563,9 @@ static int _dm_task_set_name(struct dm_task *dmt, const char *name,
 	char mangled_name[DM_NAME_LEN];
 	int r = 0;
 
-	dm_free(dmt->dev_name);
+	free(dmt->dev_name);
 	dmt->dev_name = NULL;
-	dm_free(dmt->mangled_dev_name);
+	free(dmt->mangled_dev_name);
 	dmt->mangled_dev_name = NULL;
 
 	if (strlen(name) >= DM_NAME_LEN) {
@@ -587,13 +588,13 @@ static int _dm_task_set_name(struct dm_task *dmt, const char *name,
 		log_debug_activation("Device name mangled [%s]: %s --> %s",
 				     mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
 				     name, mangled_name);
-		if (!(dmt->mangled_dev_name = dm_strdup(mangled_name))) {
-			log_error("_dm_task_set_name: dm_strdup(%s) failed", mangled_name);
+		if (!(dmt->mangled_dev_name = strdup(mangled_name))) {
+			log_error("_dm_task_set_name: strdup(%s) failed", mangled_name);
 			return 0;
 		}
 	}
 
-	if (!(dmt->dev_name = dm_strdup(name))) {
+	if (!(dmt->dev_name = strdup(name))) {
 		log_error("_dm_task_set_name: strdup(%s) failed", name);
 		return 0;
 	}
@@ -689,8 +690,8 @@ static char *_task_get_string_mangled(const char *str, const char *str_name,
 	if ((r = mangle_string(str, str_name, strlen(str), buf, buf_size, mode)) < 0)
 		return NULL;
 
-	if (!(rs = r ? dm_strdup(buf) : dm_strdup(str)))
-		log_error("_task_get_string_mangled: dm_strdup failed");
+	if (!(rs = r ? strdup(buf) : strdup(str)))
+		log_error("_task_get_string_mangled: strdup failed");
 
 	return rs;
 }
@@ -710,8 +711,8 @@ static char *_task_get_string_unmangled(const char *str, const char *str_name,
 	    (r = unmangle_string(str, str_name, strlen(str), buf, buf_size, mode)) < 0)
 		return NULL;
 
-	if (!(rs = r ? dm_strdup(buf) : dm_strdup(str)))
-		log_error("_task_get_string_unmangled: dm_strdup failed");
+	if (!(rs = r ? strdup(buf) : strdup(str)))
+		log_error("_task_get_string_unmangled: strdup failed");
 
 	return rs;
 }
@@ -807,8 +808,8 @@ int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 		newname = mangled_name;
 	}
 
-	dm_free(dmt->newname);
-	if (!(dmt->newname = dm_strdup(newname))) {
+	free(dmt->newname);
+	if (!(dmt->newname = strdup(newname))) {
 		log_error("dm_task_set_newname: strdup(%s) failed", newname);
 		return 0;
 	}
@@ -824,9 +825,9 @@ int dm_task_set_uuid(struct dm_task *dmt, const char *uuid)
 	dm_string_mangling_t mangling_mode = dm_get_name_mangling_mode();
 	int r = 0;
 
-	dm_free(dmt->uuid);
+	free(dmt->uuid);
 	dmt->uuid = NULL;
-	dm_free(dmt->mangled_uuid);
+	free(dmt->mangled_uuid);
 	dmt->mangled_uuid = NULL;
 
 	if (!check_multiple_mangled_string_allowed(uuid, "UUID", mangling_mode))
@@ -844,13 +845,13 @@ int dm_task_set_uuid(struct dm_task *dmt, const char *uuid)
 				     mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
 				     uuid, mangled_uuid);
 
-		if (!(dmt->mangled_uuid = dm_strdup(mangled_uuid))) {
-			log_error("dm_task_set_uuid: dm_strdup(%s) failed", mangled_uuid);
+		if (!(dmt->mangled_uuid = strdup(mangled_uuid))) {
+			log_error("dm_task_set_uuid: strdup(%s) failed", mangled_uuid);
 			return 0;
 		}
 	}
 
-	if (!(dmt->uuid = dm_strdup(uuid))) {
+	if (!(dmt->uuid = strdup(uuid))) {
 		log_error("dm_task_set_uuid: strdup(%s) failed", uuid);
 		return 0;
 	}
@@ -1458,7 +1459,7 @@ static void _del_node_op(struct node_op_parms *nop)
 {
 	_count_node_ops[nop->type]--;
 	dm_list_del(&nop->list);
-	dm_free(nop);
+	free(nop);
 
 }
 
@@ -1562,7 +1563,7 @@ static int _stack_node_op(node_op_t type, const char *dev_name, uint32_t major,
 		warn_if_udev_failed = 0;
 	}
 
-	if (!(nop = dm_malloc(sizeof(*nop) + len))) {
+	if (!(nop = malloc(sizeof(*nop) + len))) {
 		log_error("Insufficient memory to stack mknod operation");
 		return 0;
 	}
@@ -1828,8 +1829,8 @@ static int _sysfs_get_dm_name(uint32_t major, uint32_t minor, char *buf, size_t
 	int r = 0;
 	size_t len;
 
-	if (!(sysfs_path = dm_malloc(PATH_MAX)) ||
-	    !(temp_buf = dm_malloc(PATH_MAX))) {
+	if (!(sysfs_path = malloc(PATH_MAX)) ||
+	    !(temp_buf = malloc(PATH_MAX))) {
 		log_error("_sysfs_get_dm_name: failed to allocate temporary buffers");
 		goto bad;
 	}
@@ -1867,8 +1868,8 @@ bad:
 	if (fp && fclose(fp))
 		log_sys_error("fclose", sysfs_path);
 
-	dm_free(temp_buf);
-	dm_free(sysfs_path);
+	free(temp_buf);
+	free(sysfs_path);
 
 	return r;
 }
@@ -1880,8 +1881,8 @@ static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, siz
 	size_t len;
 	int r = 0;
 
-	if (!(sysfs_path = dm_malloc(PATH_MAX)) ||
-	    !(temp_buf = dm_malloc(PATH_MAX))) {
+	if (!(sysfs_path = malloc(PATH_MAX)) ||
+	    !(temp_buf = malloc(PATH_MAX))) {
 		log_error("_sysfs_get_kernel_name: failed to allocate temporary buffers");
 		goto bad;
 	}
@@ -1916,8 +1917,8 @@ static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, siz
 	strcpy(buf, name);
 	r = 1;
 bad:
-	dm_free(temp_buf);
-	dm_free(sysfs_path);
+	free(temp_buf);
+	free(sysfs_path);
 
 	return r;
 }
diff --git a/device_mapper/libdm-config.c b/device_mapper/libdm-config.c
index fd4d929..0928843 100644
--- a/device_mapper/libdm-config.c
+++ b/device_mapper/libdm-config.c
@@ -269,11 +269,11 @@ static int _line_append(struct config_output *out, const char *fmt, ...)
 
 	if (!dm_pool_grow_object(out->mem, dyn_buf ? : buf, 0)) {
 		log_error("dm_pool_grow_object failed for config line");
-		dm_free(dyn_buf);
+		free(dyn_buf);
 		return 0;
 	}
 
-	dm_free(dyn_buf);
+	free(dyn_buf);
 
 	return 1;
 }
@@ -1441,12 +1441,12 @@ static int _enumerate(const char *path, struct dm_config_node *cn, int (*cb)(con
 		} else
 			if (!cb(sub, cn, baton))
 				goto_bad;
-		dm_free(sub);
+		free(sub);
 		cn = cn->sib;
 	}
 	return 1;
 bad:
-	dm_free(sub);
+	free(sub);
 	return 0;
 }
 
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index fab3e06..d177374 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -19,6 +19,7 @@
 #include "misc/dm-ioctl.h"
 
 #include <stdarg.h>
+#include <string.h>
 #include <sys/param.h>
 #include <sys/utsname.h>
 
@@ -2660,7 +2661,7 @@ static int _emit_segment(struct dm_task *dmt, uint32_t major, uint32_t minor,
 	int ret;
 
 	do {
-		if (!(params = dm_malloc(paramsize))) {
+		if (!(params = malloc(paramsize))) {
 			log_error("Insufficient space for target parameters.");
 			return 0;
 		}
@@ -2668,7 +2669,7 @@ static int _emit_segment(struct dm_task *dmt, uint32_t major, uint32_t minor,
 		params[0] = '\0';
 		ret = _emit_segment_line(dmt, major, minor, seg, seg_start,
 					 params, paramsize);
-		dm_free(params);
+		free(params);
 
 		if (!ret)
 			stack;
diff --git a/device_mapper/libdm-file.c b/device_mapper/libdm-file.c
index 5c6d223..096c796 100644
--- a/device_mapper/libdm-file.c
+++ b/device_mapper/libdm-file.c
@@ -45,7 +45,7 @@ static int _create_dir_recursive(const char *dir)
 
 	log_verbose("Creating directory \"%s\"", dir);
 	/* Create parent directories */
-	orig = s = dm_strdup(dir);
+	orig = s = strdup(dir);
 	if (!s) {
 		log_error("Failed to duplicate directory name.");
 		return 0;
@@ -84,7 +84,7 @@ static int _create_dir_recursive(const char *dir)
 
 	r = 1;
 out:
-	dm_free(orig);
+	free(orig);
 	return r;
 }
 
diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index 3a48c3f..e437e4c 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "misc/dmlib.h"
 
 #include <ctype.h>
@@ -477,8 +478,8 @@ static int _report_field_string_list(struct dm_report *rh,
 	}
 
 	/* more than one item - sort the list */
-	if (!(arr = dm_malloc(sizeof(struct str_list_sort_item) * list_size))) {
-		log_error("dm_report_field_string_list: dm_malloc failed");
+	if (!(arr = malloc(sizeof(struct str_list_sort_item) * list_size))) {
+		log_error("dm_report_field_string_list: malloc failed");
 		goto out;
 	}
 
@@ -547,7 +548,7 @@ static int _report_field_string_list(struct dm_report *rh,
 out:
 	if (!r && sort_value)
 		dm_pool_free(rh->mem, sort_value);
-	dm_free(arr);
+	free(arr);
 
 	return r;
 }
@@ -1257,8 +1258,8 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 	if (_contains_reserved_report_type(types))
 		return_NULL;
 
-	if (!(rh = dm_zalloc(sizeof(*rh)))) {
-		log_error("dm_report_init: dm_malloc failed");
+	if (!(rh = zalloc(sizeof(*rh)))) {
+		log_error("dm_report_init: malloc failed");
 		return NULL;
 	}
 
@@ -1300,7 +1301,7 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 
 	if (!(rh->mem = dm_pool_create("report", 10 * 1024))) {
 		log_error("dm_report_init: allocation of memory pool failed");
-		dm_free(rh);
+		free(rh);
 		return NULL;
 	}
 
@@ -1348,7 +1349,7 @@ void dm_report_free(struct dm_report *rh)
 	if (rh->value_cache)
 		dm_hash_destroy(rh->value_cache);
 	dm_pool_destroy(rh->mem);
-	dm_free(rh);
+	free(rh);
 }
 
 static char *_toupperstr(char *str)
@@ -2732,7 +2733,7 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 		goto bad;
 	} else if (list_size == 1)
 		goto out;
-	if (!(arr = dm_malloc(sizeof(item) * list_size))) {
+	if (!(arr = malloc(sizeof(item) * list_size))) {
 		log_error("_tok_value_string_list: memory allocation failed for sort array");
 		goto bad;
 	}
@@ -2745,7 +2746,7 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 	for (i = 0; i < list_size; i++)
 		dm_list_add(&ssl->str_list.list, &arr[i]->list);
 
-	dm_free(arr);
+	free(arr);
 out:
 	*end = s;
         if (sel_str_list)
@@ -3514,8 +3515,8 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 	/* store comparison operand */
 	if (flags & FLD_CMP_REGEX) {
 		/* REGEX */
-		if (!(s = dm_malloc(len + 1))) {
-			log_error("dm_report: dm_malloc failed to store "
+		if (!(s = malloc(len + 1))) {
+			log_error("dm_report: malloc failed to store "
 				  "regex value for selection field %s", field_id);
 			goto error;
 		}
@@ -3523,7 +3524,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 		s[len] = '\0';
 
 		fs->value->v.r = dm_regex_create(rh->selection->mem, (const char * const *) &s, 1);
-		dm_free(s);
+		free(s);
 		if (!fs->value->v.r) {
 			log_error("dm_report: failed to create regex "
 				  "matcher for selection field %s", field_id);
@@ -4175,7 +4176,7 @@ static int _report_headings(struct dm_report *rh)
 	/* Including trailing '\0'! */
 	buf_size++;
 
-	if (!(buf = dm_malloc(buf_size))) {
+	if (!(buf = malloc(buf_size))) {
 		log_error("dm_report: Could not allocate memory for heading buffer.");
 		goto bad;
 	}
@@ -4219,12 +4220,12 @@ static int _report_headings(struct dm_report *rh)
 	log_print("%s", heading);
 
 	dm_pool_free(rh->mem, (void *)heading);
-	dm_free(buf);
+	free(buf);
 
 	return 1;
 
       bad:
-	dm_free(buf);
+	free(buf);
 	dm_pool_abandon_object(rh->mem);
 	return 0;
 }
@@ -4398,24 +4399,24 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 			return 0;
 		}
 	} else if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
-		if (!(field_id = dm_strdup(fields[field->props->field_num].id))) {
+		if (!(field_id = strdup(fields[field->props->field_num].id))) {
 			log_error("dm_report: Failed to copy field name");
 			return 0;
 		}
 
 		if (!dm_pool_grow_object(rh->mem, rh->output_field_name_prefix, 0)) {
 			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-			dm_free(field_id);
+			free(field_id);
 			return 0;
 		}
 
 		if (!dm_pool_grow_object(rh->mem, _toupperstr(field_id), 0)) {
 			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-			dm_free(field_id);
+			free(field_id);
 			return 0;
 		}
 
-		dm_free(field_id);
+		free(field_id);
 
 		if (!dm_pool_grow_object(rh->mem, STANDARD_PAIR, 1)) {
 			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
@@ -4468,7 +4469,7 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 
 		/* Including trailing '\0'! */
 		buf_size = width + 1;
-		if (!(buf = dm_malloc(buf_size))) {
+		if (!(buf = malloc(buf_size))) {
 			log_error("dm_report: Could not allocate memory for output line buffer.");
 			return 0;
 		}
@@ -4510,11 +4511,11 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 		}
 	}
 
-	dm_free(buf);
+	free(buf);
 	return 1;
 
 bad:
-	dm_free(buf);
+	free(buf);
 	return 0;
 }
 
diff --git a/device_mapper/libdm-stats.c b/device_mapper/libdm-stats.c
index 6cd08a7..219d393 100644
--- a/device_mapper/libdm-stats.c
+++ b/device_mapper/libdm-stats.c
@@ -15,6 +15,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "misc/dmlib.h"
 #include "misc/kdev_t.h"
 
@@ -156,7 +157,7 @@ static char *_program_id_from_proc(void)
 	if (fclose(comm))
 		stack;
 
-	return dm_strdup(buf);
+	return strdup(buf);
 }
 
 static uint64_t _nr_areas(uint64_t len, uint64_t step)
@@ -184,12 +185,12 @@ struct dm_stats *dm_stats_create(const char *program_id)
 	size_t group_hint = sizeof(struct dm_stats_group);
 	struct dm_stats *dms = NULL;
 
-	if (!(dms = dm_zalloc(sizeof(*dms))))
+	if (!(dms = zalloc(sizeof(*dms))))
 		return_NULL;
 
 	/* FIXME: better hint. */
 	if (!(dms->mem = dm_pool_create("stats_pool", 4096))) {
-		dm_free(dms);
+		free(dms);
 		return_NULL;
 	}
 
@@ -202,7 +203,7 @@ struct dm_stats *dm_stats_create(const char *program_id)
 	if (!program_id || !strlen(program_id))
 		dms->program_id = _program_id_from_proc();
 	else
-		dms->program_id = dm_strdup(program_id);
+		dms->program_id = strdup(program_id);
 
 	if (!dms->program_id) {
 		log_error("Could not allocate memory for program_id");
@@ -235,7 +236,7 @@ bad:
 		dm_pool_destroy(dms->hist_mem);
 	if (dms->group_mem)
 		dm_pool_destroy(dms->group_mem);
-	dm_free(dms);
+	free(dms);
 	return NULL;
 }
 
@@ -325,15 +326,15 @@ static void _stats_region_destroy(struct dm_stats_region *region)
 	 * dropped from the pool along with the corresponding
 	 * regions table.
 	 *
-	 * The following objects are all allocated with dm_malloc.
+	 * The following objects are all allocated with malloc.
 	 */
 
 	region->counters = NULL;
 	region->bounds = NULL;
 
-	dm_free(region->program_id);
+	free(region->program_id);
 	region->program_id = NULL;
-	dm_free(region->aux_data);
+	free(region->aux_data);
 	region->aux_data = NULL;
 	region->region_id = DM_STATS_REGION_NOT_PRESENT;
 }
@@ -364,7 +365,7 @@ static void _stats_group_destroy(struct dm_stats_group *group)
 	group->histogram = NULL;
 
 	if (group->alias) {
-		dm_free((char *) group->alias);
+		free((char *) group->alias);
 		group->alias = NULL;
 	}
 	if (group->regions) {
@@ -414,7 +415,7 @@ static void _stats_clear_binding(struct dm_stats *dms)
 		dm_pool_free(dms->mem, dms->bind_name);
 	if (dms->bind_uuid)
 		dm_pool_free(dms->mem, dms->bind_uuid);
-	dm_free((char *) dms->name);
+	free((char *) dms->name);
 
 	dms->bind_name = dms->bind_uuid = NULL;
 	dms->bind_major = dms->bind_minor = -1;
@@ -534,7 +535,7 @@ static void *_get_hist_arg(struct dm_histogram *bounds, uint64_t scale,
 
 	*len = hist_len;
 
-	return dm_zalloc(hist_len);
+	return zalloc(hist_len);
 }
 
 static char *_build_histogram_arg(struct dm_histogram *bounds, int *precise)
@@ -587,7 +588,7 @@ static char *_build_histogram_arg(struct dm_histogram *bounds, int *precise)
 
 bad:
 	log_error("Could not build histogram arguments.");
-	dm_free(hist_arg);
+	free(hist_arg);
 
 	return NULL;
 }
@@ -634,7 +635,7 @@ static int _stats_set_name_cache(struct dm_stats *dms)
 	if (!dm_task_run(dmt))
 		goto_bad;
 
-	if (!(dms->name = dm_strdup(dm_task_get_name(dmt))))
+	if (!(dms->name = strdup(dm_task_get_name(dmt))))
 		goto_bad;
 
 	dm_task_destroy(dmt);
@@ -759,7 +760,7 @@ static int _parse_aux_data_group(struct dm_stats *dms,
 	group->regions = regions;
 	group->alias = NULL;
 	if (strlen(alias)) {
-		group->alias = dm_strdup(alias);
+		group->alias = strdup(alias);
 		if (!group->alias) {
 			log_error("Could not allocate memory for group alias");
 			goto bad;
@@ -768,16 +769,16 @@ static int _parse_aux_data_group(struct dm_stats *dms,
 
 	/* separate group tag from user aux_data */
 	if ((strlen(end) > 1) || strncmp(end, "-", 1))
-		c = dm_strdup(end);
+		c = strdup(end);
 	else
-		c = dm_strdup("");
+		c = strdup("");
 
 	if (!c) {
 		log_error("Could not allocate memory for user aux_data");
 		goto bad_alias;
 	}
 
-	dm_free(region->aux_data);
+	free(region->aux_data);
 	region->aux_data = c;
 
 	log_debug("Found group_id " FMTu64 ": alias=\"%s\"", group->group_id,
@@ -786,7 +787,7 @@ static int _parse_aux_data_group(struct dm_stats *dms,
 	return 1;
 
 bad_alias:
-	dm_free((char *) group->alias);
+	free((char *) group->alias);
 bad:
 	dm_bitset_destroy(regions);
 	return 0;
@@ -971,10 +972,10 @@ static int _stats_parse_list_region(struct dm_stats *dms,
 
 	region->group_id = DM_STATS_GROUP_NOT_PRESENT;
 
-	if (!(region->program_id = dm_strdup(program_id)))
+	if (!(region->program_id = strdup(program_id)))
 		return_0;
-	if (!(region->aux_data = dm_strdup(aux_data))) {
-		dm_free(region->program_id);
+	if (!(region->aux_data = strdup(aux_data))) {
+		free(region->program_id);
 		return_0;
 	}
 
@@ -1843,7 +1844,7 @@ static char *_build_group_tag(struct dm_stats *dms, uint64_t group_id)
 	buflen += DMS_GROUP_TAG_LEN;
 	buflen += 1 + (alias ? strlen(alias) : 0); /* 'alias:' */
 
-	buf = aux_string = dm_malloc(buflen);
+	buf = aux_string = malloc(buflen);
 	if (!buf) {
 		log_error("Could not allocate memory for aux_data string.");
 		return NULL;
@@ -1869,7 +1870,7 @@ static char *_build_group_tag(struct dm_stats *dms, uint64_t group_id)
 	return aux_string;
 bad:
 	log_error("Could not format group aux_data.");
-	dm_free(aux_string);
+	free(aux_string);
 	return NULL;
 }
 
@@ -1906,14 +1907,14 @@ static int _stats_set_aux(struct dm_stats *dms,
 	if (!(dmt = _stats_send_message(dms, msg)))
 		goto_bad;
 
-	dm_free((char *) group_tag);
+	free((char *) group_tag);
 
 	/* no response to a @stats_set_aux message */
 	dm_task_destroy(dmt);
 
 	return 1;
 bad:
-	dm_free((char *) group_tag);
+	free((char *) group_tag);
 	return 0;
 }
 
@@ -1970,7 +1971,7 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 			return 0;
 		}
 	} else
-		opt_args = dm_strdup("");
+		opt_args = strdup("");
 
 	if (dm_snprintf(msg, sizeof(msg), "@stats_create %s %s" FMTu64
 			" %s %s %s", (start || len) ? range : "-",
@@ -1978,7 +1979,7 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 			(uint64_t)llabs(step),
 			opt_args, program_id, aux_data) < 0) {
 		log_error(err_fmt, "message");
-		dm_free((void *) opt_args);
+		free((void *) opt_args);
 		return 0;
 	}
 
@@ -2003,7 +2004,7 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 out:
 	if (dmt)
 		dm_task_destroy(dmt);
-	dm_free((void *) opt_args);
+	free((void *) opt_args);
 
 	return r;
 }
@@ -2028,7 +2029,7 @@ int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 
 	r = _stats_create_region(dms, region_id, start, len, step,
 				 precise, hist_arg, program_id, user_data);
-	dm_free(hist_arg);
+	free(hist_arg);
 
 out:
 	return r;
@@ -2398,9 +2399,9 @@ void dm_stats_destroy(struct dm_stats *dms)
 	dm_pool_destroy(dms->mem);
 	dm_pool_destroy(dms->hist_mem);
 	dm_pool_destroy(dms->group_mem);
-	dm_free(dms->program_id);
-	dm_free((char *) dms->name);
-	dm_free(dms);
+	free(dms->program_id);
+	free((char *) dms->name);
+	free(dms);
 }
 
 /*
@@ -2995,9 +2996,9 @@ int dm_stats_set_program_id(struct dm_stats *dms, int allow_empty,
 	if (!program_id)
 		program_id = "";
 
-	dm_free(dms->program_id);
+	free(dms->program_id);
 
-	if (!(dms->program_id = dm_strdup(program_id)))
+	if (!(dms->program_id = strdup(program_id)))
 		return_0;
 
 	return 1;
@@ -3215,7 +3216,7 @@ int dm_stats_set_alias(struct dm_stats *dms, uint64_t group_id, const char *alia
 	group = &dms->groups[group_id];
 	old_alias = group->alias;
 
-	group->alias = dm_strdup(alias);
+	group->alias = strdup(alias);
 	if (!group->alias) {
 		log_error("Could not allocate memory for alias.");
 		goto bad;
@@ -3226,12 +3227,12 @@ int dm_stats_set_alias(struct dm_stats *dms, uint64_t group_id, const char *alia
 		goto bad;
 	}
 
-	dm_free((char *) old_alias);
+	free((char *) old_alias);
 
 	return 1;
 
 bad:
-	dm_free((char *) group->alias);
+	free((char *) group->alias);
 	group->alias = old_alias;
 	return 0;
 }
@@ -3492,7 +3493,7 @@ static struct dm_histogram *_alloc_dm_histogram(int nr_bins)
 	/* Allocate space for dm_histogram + nr_entries. */
 	size_t size = sizeof(struct dm_histogram) +
 		(unsigned) nr_bins * sizeof(struct dm_histogram_bin);
-	return dm_zalloc(size);
+	return zalloc(size);
 }
 
 /*
@@ -3595,7 +3596,7 @@ struct dm_histogram *dm_histogram_bounds_from_string(const char *bounds_str)
 badchar:
 	log_error("Invalid character in histogram: %c", *c);
 bad:
-	dm_free(dmh);
+	free(dmh);
 	return NULL;
 }
 
@@ -3646,8 +3647,8 @@ void dm_histogram_bounds_destroy(struct dm_histogram *bounds)
 			  (void *) bounds);
 		stack;
 	}
-	/* dm_free() expects a (void *). */
-	dm_free((void *) bounds);
+	/* free() expects a (void *). */
+	free((void *) bounds);
 }
 
 /*
@@ -3897,7 +3898,7 @@ static int _stats_create_group(struct dm_stats *dms, dm_bitset_t regions,
 	group->regions = regions;
 
 	if (alias)
-		group->alias = dm_strdup(alias);
+		group->alias = strdup(alias);
 	else
 		group->alias = NULL;
 
@@ -4231,7 +4232,7 @@ static int _stats_group_file_regions(struct dm_stats *dms, uint64_t *region_ids,
 		dm_bit_set(regions, region_ids[i]);
 
 	buflen = _stats_group_tag_len(dms, regions);
-	members = dm_malloc(buflen);
+	members = malloc(buflen);
 
 	if (!members) {
 		log_error("Cannot map file: failed to allocate group "
@@ -4253,11 +4254,11 @@ static int _stats_group_file_regions(struct dm_stats *dms, uint64_t *region_ids,
 	if (!_stats_create_group(dms, regions, alias, &group_id))
 		goto bad;
 
-	dm_free(members);
+	free(members);
 	return 1;
 bad:
 	dm_bitset_destroy(regions);
-	dm_free(members);
+	free(members);
 	return 0;
 }
 
@@ -4408,7 +4409,7 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 	if (!dm_pool_begin_object(mem, sizeof(*extents)))
 		return NULL;
 
-	buf = dm_zalloc(STATS_FIE_BUF_LEN);
+	buf = zalloc(STATS_FIE_BUF_LEN);
 	if (!buf) {
 		log_error("Could not allocate memory for FIEMAP buffer.");
 		goto bad;
@@ -4462,14 +4463,14 @@ static struct _extent *_stats_get_extents_for_file(struct dm_pool *mem, int fd,
 	extents = dm_pool_end_object(mem);
 
 	/* free FIEMAP buffer. */
-	dm_free(buf);
+	free(buf);
 
 	return extents;
 
 bad:
 	*count = 0;
 	dm_pool_abandon_object(mem);
-	dm_free(buf);
+	free(buf);
 	return NULL;
 }
 
@@ -4677,7 +4678,7 @@ static uint64_t *_stats_map_file_regions(struct dm_stats *dms, int fd,
                         goto_out;
 
 	/* make space for end-of-table marker */
-	if (!(regions = dm_malloc((1 + *count) * sizeof(*regions)))) {
+	if (!(regions = malloc((1 + *count) * sizeof(*regions)))) {
 		log_error("Could not allocate memory for region IDs.");
 		goto_out;
 	}
@@ -4736,7 +4737,7 @@ static uint64_t *_stats_map_file_regions(struct dm_stats *dms, int fd,
 			log_error("Failed to update group aux_data.");
 
 	if (bounds)
-		dm_free(hist_arg);
+		free(hist_arg);
 
 	/* the extent table will be empty if the file has been truncated. */
 	if (extents)
@@ -4763,8 +4764,8 @@ out_remove:
 
 out:
 	dm_pool_destroy(extent_mem);
-	dm_free(hist_arg);
-	dm_free(regions);
+	free(hist_arg);
+	free(regions);
 	return NULL;
 }
 
@@ -4799,7 +4800,7 @@ uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
 	return regions;
 out:
 	_stats_cleanup_region_ids(dms, regions, count);
-	dm_free(regions);
+	free(regions);
 	return NULL;
 }
 
@@ -4836,7 +4837,7 @@ uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
 	 * A copy of the alias is needed to re-create the group when regroup=1.
 	 */
 	if (dms->groups[group_id].alias) {
-		alias = dm_strdup(dms->groups[group_id].alias);
+		alias = strdup(dms->groups[group_id].alias);
 		if (!alias) {
 			log_error("Failed to allocate group alias string.");
 			return NULL;
@@ -4878,15 +4879,15 @@ uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
 		if (!_stats_group_file_regions(dms, regions, count, alias))
 			goto bad;
 
-	dm_free(bounds);
-	dm_free((char *) alias);
+	free(bounds);
+	free((char *) alias);
 	return regions;
 bad:
 	_stats_cleanup_region_ids(dms, regions, count);
-	dm_free(bounds);
-	dm_free(regions);
+	free(bounds);
+	free(regions);
 out:
-	dm_free((char *) alias);
+	free((char *) alias);
 	return NULL;
 }
 #else /* !HAVE_LINUX_FIEMAP */
diff --git a/device_mapper/libdm-string.c b/device_mapper/libdm-string.c
index 8bd6c2d..62629c7 100644
--- a/device_mapper/libdm-string.c
+++ b/device_mapper/libdm-string.c
@@ -146,7 +146,7 @@ int dm_vasprintf(char **result, const char *format, va_list aq)
 {
 	int i, n, size = 16;
 	va_list ap;
-	char *buf = dm_malloc(size);
+	char *buf = malloc(size);
 
 	*result = 0;
 
@@ -161,20 +161,20 @@ int dm_vasprintf(char **result, const char *format, va_list aq)
 		if (0 <= n && n < size)
 			break;
 
-		dm_free(buf);
+		free(buf);
 		/* Up to glibc 2.0.6 returns -1 */
 		size = (n < 0) ? size * 2 : n + 1;
-		if (!(buf = dm_malloc(size)))
+		if (!(buf = malloc(size)))
 			return -1;
 	}
 
 	if (i > 1) {
 		/* Reallocating more then once? */
-		if (!(*result = dm_strdup(buf))) {
-			dm_free(buf);
+		if (!(*result = strdup(buf))) {
+			free(buf);
 			return -1;
 		}
-		dm_free(buf);
+		free(buf);
 	} else
 		*result = buf;
 
diff --git a/device_mapper/libdm-timestamp.c b/device_mapper/libdm-timestamp.c
index c2d0ad8..236cf1a 100644
--- a/device_mapper/libdm-timestamp.c
+++ b/device_mapper/libdm-timestamp.c
@@ -18,6 +18,7 @@
  * the results of these routines should stay in-core.  
  */
 
+#include "base/memory/zalloc.h"
 #include "misc/dmlib.h"
 
 #include <stdlib.h>
@@ -53,7 +54,7 @@ struct dm_timestamp *dm_timestamp_alloc(void)
 {
 	struct dm_timestamp *ts = NULL;
 
-	if (!(ts = dm_zalloc(sizeof(*ts))))
+	if (!(ts = zalloc(sizeof(*ts))))
 		stack;
 
 	return ts;
@@ -101,7 +102,7 @@ struct dm_timestamp *dm_timestamp_alloc(void)
 {
 	struct dm_timestamp *ts;
 
-	if (!(ts = dm_malloc(sizeof(*ts))))
+	if (!(ts = malloc(sizeof(*ts))))
 		stack;
 
 	return ts;
@@ -174,5 +175,5 @@ void dm_timestamp_copy(struct dm_timestamp *ts_new, struct dm_timestamp *ts_old)
 
 void dm_timestamp_destroy(struct dm_timestamp *ts)
 {
-	dm_free(ts);
+	free(ts);
 }
diff --git a/device_mapper/mm/dbg_malloc.c b/device_mapper/mm/dbg_malloc.c
deleted file mode 100644
index b169f8b..0000000
--- a/device_mapper/mm/dbg_malloc.c
+++ /dev/null
@@ -1,413 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
- *
- * This file is part of the device-mapper userspace tools.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "device_mapper/misc/dmlib.h"
-
-#ifdef VALGRIND_POOL
-#include "memcheck.h"
-#endif
-#include <assert.h>
-#include <stdarg.h>
-#include <unistd.h>
-
-void *dm_malloc_aux(size_t s, const char *file, int line)
-        __attribute__((__malloc__)) __attribute__((__warn_unused_result__));
-void *dm_malloc_aux_debug(size_t s, const char *file, int line)
-        __attribute__((__malloc__)) __attribute__((__warn_unused_result__));
-static void *_dm_malloc_aligned_aux(size_t s, size_t a, const char *file, int line)
-        __attribute__((__malloc__)) __attribute__((__warn_unused_result__));
-void *dm_zalloc_aux(size_t s, const char *file, int line)
-        __attribute__((__malloc__)) __attribute__((__warn_unused_result__));
-void *dm_zalloc_aux_debug(size_t s, const char *file, int line)
-        __attribute__((__malloc__)) __attribute__((__warn_unused_result__));
-void *dm_realloc_aux(void *p, unsigned int s, const char *file, int line)
-        __attribute__((__warn_unused_result__));
-void dm_free_aux(void *p);
-char *dm_strdup_aux(const char *str, const char *file, int line)
-        __attribute__((__warn_unused_result__));
-int dm_dump_memory_debug(void);
-void dm_bounds_check_debug(void);
-
-char *dm_strdup_aux(const char *str, const char *file, int line)
-{
-	char *ret;
-
-	if (!str) {
-		log_error(INTERNAL_ERROR "dm_strdup called with NULL pointer");
-		return NULL;
-	}
-
-	if ((ret = dm_malloc_aux_debug(strlen(str) + 1, file, line)))
-		strcpy(ret, str);
-
-	return ret;
-}
-
-struct memblock {
-	struct memblock *prev, *next;	/* All allocated blocks are linked */
-	size_t length;		/* Size of the requested block */
-	int id;			/* Index of the block */
-	const char *file;	/* File that allocated */
-	int line;		/* Line that allocated */
-	void *magic;		/* Address of this block */
-} __attribute__((aligned(8)));
-
-static struct {
-	unsigned block_serialno;/* Non-decreasing serialno of block */
-	unsigned blocks_allocated; /* Current number of blocks allocated */
-	unsigned blocks_max;	/* Max no of concurrently-allocated blocks */
-	unsigned int bytes, mbytes;
-
-} _mem_stats = {
-0, 0, 0, 0, 0};
-
-static struct memblock *_head = 0;
-static struct memblock *_tail = 0;
-
-void *dm_malloc_aux_debug(size_t s, const char *file, int line)
-{
-	struct memblock *nb;
-	size_t tsize = s + sizeof(*nb) + sizeof(unsigned long);
-
-	if (s > 50000000) {
-		log_error("Huge memory allocation (size %" PRIsize_t
-			  ") rejected - metadata corruption?", s);
-		return 0;
-	}
-
-	if (!(nb = malloc(tsize))) {
-		log_error("couldn't allocate any memory, size = %" PRIsize_t,
-			  s);
-		return 0;
-	}
-
-	/* set up the file and line info */
-	nb->file = file;
-	nb->line = line;
-
-	dm_bounds_check();
-
-	/* setup fields */
-	nb->magic = nb + 1;
-	nb->length = s;
-	nb->id = ++_mem_stats.block_serialno;
-	nb->next = 0;
-
-	/* stomp a pretty pattern across the new memory
-	   and fill in the boundary bytes */
-	{
-		char *ptr = (char *) (nb + 1);
-		size_t i;
-		for (i = 0; i < s; i++)
-			*ptr++ = i & 0x1 ? (char) 0xba : (char) 0xbe;
-
-		for (i = 0; i < sizeof(unsigned long); i++)
-			*ptr++ = (char) nb->id;
-	}
-
-	nb->prev = _tail;
-
-	/* link to tail of the list */
-	if (!_head)
-		_head = _tail = nb;
-	else {
-		_tail->next = nb;
-		_tail = nb;
-	}
-
-	_mem_stats.blocks_allocated++;
-	if (_mem_stats.blocks_allocated > _mem_stats.blocks_max)
-		_mem_stats.blocks_max = _mem_stats.blocks_allocated;
-
-	_mem_stats.bytes += s;
-	if (_mem_stats.bytes > _mem_stats.mbytes)
-		_mem_stats.mbytes = _mem_stats.bytes;
-
-	/* log_debug_mem("Allocated: %u %u %u", nb->id, _mem_stats.blocks_allocated,
-		  _mem_stats.bytes); */
-#ifdef VALGRIND_POOL
-	VALGRIND_MAKE_MEM_UNDEFINED(nb + 1, s);
-#endif
-	return nb + 1;
-}
-
-void *dm_zalloc_aux_debug(size_t s, const char *file, int line)
-{
-	void *ptr = dm_malloc_aux_debug(s, file, line);
-
-	if (ptr)
-		memset(ptr, 0, s);
-
-	return ptr;
-}
-
-void dm_free_aux(void *p)
-{
-	char *ptr;
-	size_t i;
-	struct memblock *mb = ((struct memblock *) p) - 1;
-	if (!p)
-		return;
-
-	dm_bounds_check();
-
-	/* sanity check */
-	assert(mb->magic == p);
-#ifdef VALGRIND_POOL
-	VALGRIND_MAKE_MEM_DEFINED(p, mb->length);
-#endif
-	/* check data at the far boundary */
-	ptr = (char *) p + mb->length;
-	for (i = 0; i < sizeof(unsigned long); i++)
-		if (ptr[i] != (char) mb->id)
-			assert(!"Damage at far end of block");
-
-	/* have we freed this before ? */
-	assert(mb->id != 0);
-
-	/* unlink */
-	if (mb->prev)
-		mb->prev->next = mb->next;
-	else
-		_head = mb->next;
-
-	if (mb->next)
-		mb->next->prev = mb->prev;
-	else
-		_tail = mb->prev;
-
-	mb->id = 0;
-
-	/* stomp a different pattern across the memory */
-	ptr = p;
-	for (i = 0; i < mb->length; i++)
-		ptr[i] = i & 1 ? (char) 0xde : (char) 0xad;
-
-	assert(_mem_stats.blocks_allocated);
-	_mem_stats.blocks_allocated--;
-	_mem_stats.bytes -= mb->length;
-
-	/* free the memory */
-	free(mb);
-}
-
-void *dm_realloc_aux(void *p, unsigned int s, const char *file, int line)
-{
-	void *r;
-	struct memblock *mb = ((struct memblock *) p) - 1;
-
-	r = dm_malloc_aux_debug(s, file, line);
-
-	if (r && p) {
-		memcpy(r, p, mb->length);
-		dm_free_aux(p);
-	}
-
-	return r;
-}
-
-int dm_dump_memory_debug(void)
-{
-	unsigned long tot = 0;
-	struct memblock *mb;
-	char str[32];
-
-	if (_head)
-		log_very_verbose("You have a memory leak:");
-
-	for (mb = _head; mb; mb = mb->next) {
-#ifdef VALGRIND_POOL
-		/*
-		 * We can't look at the memory in case it has had
-		 * VALGRIND_MAKE_MEM_NOACCESS called on it.
-		 */
-		str[0] = '\0';
-#else
-		size_t c;
-
-		for (c = 0; c < sizeof(str) - 1; c++) {
-			if (c >= mb->length)
-				str[c] = ' ';
-			else if (((char *)mb->magic)[c] == '\0')
-				str[c] = '\0';
-			else if (((char *)mb->magic)[c] < ' ')
-				str[c] = '?';
-			else
-				str[c] = ((char *)mb->magic)[c];
-		}
-		str[sizeof(str) - 1] = '\0';
-#endif
-
-		LOG_MESG(_LOG_INFO, mb->file, mb->line, 0,
-			 "block %d at %p, size %" PRIsize_t "\t [%s]",
-			 mb->id, mb->magic, mb->length, str);
-		tot += mb->length;
-	}
-
-	if (_head)
-		log_very_verbose("%ld bytes leaked in total", tot);
-
-	return 1;
-}
-
-void dm_bounds_check_debug(void)
-{
-	struct memblock *mb = _head;
-	while (mb) {
-		size_t i;
-		char *ptr = ((char *) (mb + 1)) + mb->length;
-		for (i = 0; i < sizeof(unsigned long); i++)
-			if (*ptr++ != (char) mb->id)
-				assert(!"Memory smash");
-
-		mb = mb->next;
-	}
-}
-
-void *dm_malloc_aux(size_t s, const char *file __attribute__((unused)),
-		    int line __attribute__((unused)))
-{
-	if (s > 50000000) {
-		log_error("Huge memory allocation (size %" PRIsize_t
-			  ") rejected - metadata corruption?", s);
-		return 0;
-	}
-
-	return malloc(s);
-}
-
-/* Allocate size s with alignment a (or page size if 0) */
-static void *_dm_malloc_aligned_aux(size_t s, size_t a, const char *file __attribute__((unused)),
-				    int line __attribute__((unused)))
-{
-	void *memptr;
-	int r;
-
-	if (!a)
-		a = getpagesize();
-
-	if (s > 50000000) {
-		log_error("Huge memory allocation (size %" PRIsize_t
-			  ") rejected - metadata corruption?", s);
-		return 0;
-	}
-
-	if ((r = posix_memalign(&memptr, a, s))) {
-		log_error("Failed to allocate %" PRIsize_t " bytes aligned to %" PRIsize_t ": %s", s, a, strerror(r));
-		return 0;
-	}
-
-	return memptr;
-}
-
-void *dm_zalloc_aux(size_t s, const char *file, int line)
-{
-	void *ptr = dm_malloc_aux(s, file, line);
-
-	if (ptr)
-		memset(ptr, 0, s);
-
-	return ptr;
-}
-
-#ifdef DEBUG_MEM
-
-void *dm_malloc_wrapper(size_t s, const char *file, int line)
-{
-	return dm_malloc_aux_debug(s, file, line);
-}
-
-void *dm_malloc_aligned_wrapper(size_t s, size_t a, const char *file, int line)
-{
-	/* FIXME Implement alignment when debugging - currently just ignored */
-	return _dm_malloc_aux_debug(s, file, line);
-}
-
-void *dm_zalloc_wrapper(size_t s, const char *file, int line)
-{
-	return dm_zalloc_aux_debug(s, file, line);
-}
-
-char *dm_strdup_wrapper(const char *str, const char *file, int line)
-{
-	return dm_strdup_aux(str, file, line);
-}
-
-void dm_free_wrapper(void *ptr)
-{
-	dm_free_aux(ptr);
-}
-
-void *dm_realloc_wrapper(void *p, unsigned int s, const char *file, int line)
-{
-	return dm_realloc_aux(p, s, file, line);
-}
-
-int dm_dump_memory_wrapper(void)
-{
-	return dm_dump_memory_debug();
-}
-
-void dm_bounds_check_wrapper(void)
-{
-	dm_bounds_check_debug();
-}
-
-#else /* !DEBUG_MEM */
-
-void *dm_malloc_wrapper(size_t s, const char *file, int line)
-{
-	return dm_malloc_aux(s, file, line);
-}
-
-void *dm_malloc_aligned_wrapper(size_t s, size_t a, const char *file, int line)
-{
-	return _dm_malloc_aligned_aux(s, a, file, line);
-}
-
-void *dm_zalloc_wrapper(size_t s, const char *file, int line)
-{
-	return dm_zalloc_aux(s, file, line);
-}
-
-char *dm_strdup_wrapper(const char *str,
-			const char *file __attribute__((unused)),
-			int line __attribute__((unused)))
-{
-	return strdup(str);
-}
-
-void dm_free_wrapper(void *ptr)
-{
-	free(ptr);
-}
-
-void *dm_realloc_wrapper(void *p, unsigned int s, 
-			 const char *file __attribute__((unused)),
-			 int line __attribute__((unused)))
-{
-	return realloc(p, s);
-}
-
-int dm_dump_memory_wrapper(void)
-{
-	return 1;
-}
-
-void dm_bounds_check_wrapper(void)
-{
-}
-
-#endif /* DEBUG_MEM */
diff --git a/device_mapper/mm/pool-debug.c b/device_mapper/mm/pool-debug.c
index c523238..c9484b7 100644
--- a/device_mapper/mm/pool-debug.c
+++ b/device_mapper/mm/pool-debug.c
@@ -50,7 +50,7 @@ struct dm_pool {
 
 struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
 {
-	struct dm_pool *mem = dm_zalloc(sizeof(*mem));
+	struct dm_pool *mem = zalloc(sizeof(*mem));
 
 	if (!mem) {
 		log_error("Couldn't create memory pool %s (size %"
@@ -82,8 +82,8 @@ static void _free_blocks(struct dm_pool *p, struct block *b)
 		p->stats.blocks_allocated--;
 
 		n = b->next;
-		dm_free(b->data);
-		dm_free(b);
+		free(b->data);
+		free(b);
 		b = n;
 	}
 }
@@ -105,7 +105,7 @@ void dm_pool_destroy(struct dm_pool *p)
 	_pool_stats(p, "Destroying");
 	_free_blocks(p, p->blocks);
 	dm_list_del(&p->list);
-	dm_free(p);
+	free(p);
 }
 
 void *dm_pool_alloc(struct dm_pool *p, size_t s)
@@ -139,7 +139,7 @@ static struct block *_new_block(size_t s, unsigned alignment)
 {
 	/* FIXME: I'm currently ignoring the alignment arg. */
 	size_t len = sizeof(struct block) + s;
-	struct block *b = dm_malloc(len);
+	struct block *b = malloc(len);
 
 	/*
 	 * Too lazy to implement alignment for debug version, and
@@ -153,9 +153,9 @@ static struct block *_new_block(size_t s, unsigned alignment)
 		return NULL;
 	}
 
-	if (!(b->data = dm_malloc(s))) {
+	if (!(b->data = malloc(s))) {
 		log_error("Out of memory");
-		dm_free(b);
+		free(b);
 		return NULL;
 	}
 
@@ -247,8 +247,8 @@ int dm_pool_grow_object(struct dm_pool *p, const void *extra, size_t delta)
 
 	if (p->object) {
 		memcpy(new->data, p->object->data, p->object->size);
-		dm_free(p->object->data);
-		dm_free(p->object);
+		free(p->object->data);
+		free(p->object);
 	}
 	p->object = new;
 
@@ -270,7 +270,7 @@ void *dm_pool_end_object(struct dm_pool *p)
 void dm_pool_abandon_object(struct dm_pool *p)
 {
 	assert(p->begun);
-	dm_free(p->object);
+	free(p->object);
 	p->begun = 0;
 	p->object = NULL;
 }
diff --git a/device_mapper/mm/pool-fast.c b/device_mapper/mm/pool-fast.c
index b83c693..29bbc10 100644
--- a/device_mapper/mm/pool-fast.c
+++ b/device_mapper/mm/pool-fast.c
@@ -17,6 +17,7 @@
 #include "memcheck.h"
 #endif
 
+#include "base/memory/zalloc.h"
 #include "device_mapper/misc/dmlib.h"
 #include <stddef.h>	/* For musl libc */
 #include <malloc.h>
@@ -48,7 +49,7 @@ static void _free_chunk(struct chunk *c);
 struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
 {
 	size_t new_size = 1024;
-	struct dm_pool *p = dm_zalloc(sizeof(*p));
+	struct dm_pool *p = zalloc(sizeof(*p));
 
 	if (!p) {
 		log_error("Couldn't create memory pool %s (size %"
@@ -82,7 +83,7 @@ void dm_pool_destroy(struct dm_pool *p)
 	pthread_mutex_lock(&_dm_pools_mutex);
 	dm_list_del(&p->list);
 	pthread_mutex_unlock(&_dm_pools_mutex);
-	dm_free(p);
+	free(p);
 }
 
 void *dm_pool_alloc(struct dm_pool *p, size_t s)
@@ -281,7 +282,7 @@ static struct chunk *_new_chunk(struct dm_pool *p, size_t s)
 #  define aligned_malloc(s)	(posix_memalign((void**)&c, _pagesize, \
 						ALIGN_ON_PAGE(s)) == 0)
 #else
-#  define aligned_malloc(s)	(c = dm_malloc(s))
+#  define aligned_malloc(s)	(c = malloc(s))
 #endif /* DEBUG_ENFORCE_POOL_LOCKING */
 		if (!aligned_malloc(s)) {
 #undef aligned_malloc
@@ -315,7 +316,7 @@ static void _free_chunk(struct chunk *c)
 	/* since DEBUG_MEM is using own memory list */
 	free(c); /* for posix_memalign() */
 #else
-	dm_free(c);
+	free(c);
 #endif
 }
 
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index a7e5fe3..ce67ec8 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1514,7 +1514,7 @@ char *get_monitor_dso_path(struct cmd_context *cmd, int id)
 
 	get_shared_library_path(cmd, libpath, path, sizeof(path));
 
-	return dm_strdup(path);
+	return strdup(path);
 }
 
 static char *_build_target_uuid(struct cmd_context *cmd, const struct logical_volume *lv)
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 5dd0e6f..d0e1dac 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -627,7 +627,7 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 			goto out;
 		}
 
-		if (!(vgname = dm_strdup(name)) ||
+		if (!(vgname = strdup(name)) ||
 		    !dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer))
 			goto_out;
 
@@ -735,7 +735,7 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 	r = 1;
 
       out:
-	dm_free(vgname);
+	free(vgname);
 	dm_task_destroy(dmt);
 	return r;
 }
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 6e07eda..87bc724 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -327,7 +327,7 @@ static void _del_fs_op(struct fs_op_parms *fsp)
 {
 	_count_fs_ops[fsp->type]--;
 	dm_list_del(&fsp->list);
-	dm_free(fsp);
+	free(fsp);
 }
 
 /* Check if there is other the type of fs operation stacked */
@@ -401,7 +401,7 @@ static int _stack_fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
 				_del_fs_op(fsp);
 		}
 
-	if (!(fsp = dm_malloc(sizeof(*fsp) + len))) {
+	if (!(fsp = malloc(sizeof(*fsp) + len))) {
 		log_error("No space to stack fs operation");
 		return 0;
 	}
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 774d687..86c8775 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/cache/lvmcache.h"
 #include "lib/commands/toolcontext.h"
@@ -253,7 +254,7 @@ static void _destroy_duplicate_device_list(struct dm_list *head)
 
 	dm_list_iterate_items_safe(devl, devl2, head) {
 		dm_list_del(&devl->list);
-		dm_free(devl);
+		free(devl);
 	}
 	dm_list_init(head);
 }
@@ -348,7 +349,7 @@ const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
  	 */
 	dm_list_init(&devs);
 	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!(devl = dm_malloc(sizeof(*devl)))) {
+		if (!(devl = malloc(sizeof(*devl)))) {
 			log_error("device_list element allocation failed");
 			return NULL;
 		}
@@ -362,7 +363,7 @@ const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
 		devl = dm_list_item(devh, struct device_list);
 		label_read(devl->dev);
 		dm_list_del(&devl->list);
-		dm_free(devl);
+		free(devl);
 	}
 
 	/* If vginfo changed, caller needs to rescan */
@@ -566,7 +567,7 @@ static void _filter_duplicate_devs(struct cmd_context *cmd)
 		if (MAJOR(info->dev->dev) == dt->md_major) {
 			log_debug_devs("Ignoring md component duplicate %s", dev_name(devl->dev));
 			dm_list_del(&devl->list);
-			dm_free(devl);
+			free(devl);
 		}
 	}
 
@@ -836,7 +837,7 @@ next:
 
 		dm_list_move(add_cache_devs, &alt->list);
 
-		if ((del = dm_zalloc(sizeof(*del)))) {
+		if ((del = zalloc(sizeof(*del)))) {
 			del->dev = info->dev;
 			dm_list_add(del_cache_devs, &del->list);
 		}
@@ -922,7 +923,7 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 		return 1;
 
 	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!(devl = dm_malloc(sizeof(*devl)))) {
+		if (!(devl = malloc(sizeof(*devl)))) {
 			log_error("device_list element allocation failed");
 			return 0;
 		}
@@ -945,7 +946,7 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 
 	dm_list_iterate_items_safe(devl, devl2, &devs) {
 		dm_list_del(&devl->list);
-		dm_free(devl);
+		free(devl);
 	}
 
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
@@ -1361,9 +1362,9 @@ static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 			vginfo2 = vginfo2->next;
 		}
 
-	dm_free(vginfo->system_id);
-	dm_free(vginfo->vgname);
-	dm_free(vginfo->creation_host);
+	free(vginfo->system_id);
+	free(vginfo->vgname);
+	free(vginfo->creation_host);
 
 	if (*vginfo->vgid && _vgid_hash &&
 	    lvmcache_vginfo_from_vgid(vginfo->vgid) == vginfo)
@@ -1371,7 +1372,7 @@ static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 
 	dm_list_del(&vginfo->list);
 
-	dm_free(vginfo);
+	free(vginfo);
 
 	return r;
 }
@@ -1405,7 +1406,7 @@ void lvmcache_del(struct lvmcache_info *info)
 	info->label->labeller->ops->destroy_label(info->label->labeller,
 						  info->label);
 	label_destroy(info->label);
-	dm_free(info);
+	free(info);
 }
 
 void lvmcache_del_dev(struct device *dev)
@@ -1568,12 +1569,12 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 	 	 * into the hash table.
 	 	 */
 
-		if (!(vginfo = dm_zalloc(sizeof(*vginfo)))) {
+		if (!(vginfo = zalloc(sizeof(*vginfo)))) {
 			log_error("lvmcache_update_vgname: list alloc failed");
 			return 0;
 		}
-		if (!(vginfo->vgname = dm_strdup(vgname))) {
-			dm_free(vginfo);
+		if (!(vginfo->vgname = strdup(vgname))) {
+			free(vginfo);
 			log_error("cache vgname alloc failed for %s", vgname);
 			return 0;
 		}
@@ -1588,8 +1589,8 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 		primary_vginfo = lvmcache_vginfo_from_vgname(vgname, NULL);
 
 		if (!_insert_vginfo(vginfo, vgid, vgstatus, creation_host, primary_vginfo)) {
-			dm_free(vginfo->vgname);
-			dm_free(vginfo);
+			free(vginfo->vgname);
+			free(vginfo);
 			return 0;
 		}
 
@@ -1647,9 +1648,9 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 						   info->vginfo->creation_host))
 		goto set_lock_type;
 
-	dm_free(info->vginfo->creation_host);
+	free(info->vginfo->creation_host);
 
-	if (!(info->vginfo->creation_host = dm_strdup(creation_host))) {
+	if (!(info->vginfo->creation_host = strdup(creation_host))) {
 		log_error("cache creation host alloc failed for %s.",
 			  creation_host);
 		return 0;
@@ -1666,9 +1667,9 @@ set_lock_type:
 	if (info->vginfo->lock_type && !strcmp(lock_type, info->vginfo->lock_type))
 		goto set_system_id;
 
-	dm_free(info->vginfo->lock_type);
+	free(info->vginfo->lock_type);
 
-	if (!(info->vginfo->lock_type = dm_strdup(lock_type))) {
+	if (!(info->vginfo->lock_type = strdup(lock_type))) {
 		log_error("cache lock_type alloc failed for %s", lock_type);
 		return 0;
 	}
@@ -1684,9 +1685,9 @@ set_system_id:
 	if (info->vginfo->system_id && !strcmp(system_id, info->vginfo->system_id))
 		goto out;
 
-	dm_free(info->vginfo->system_id);
+	free(info->vginfo->system_id);
 
-	if (!(info->vginfo->system_id = dm_strdup(system_id))) {
+	if (!(info->vginfo->system_id = strdup(system_id))) {
 		log_error("cache system_id alloc failed for %s", system_id);
 		return 0;
 	}
@@ -1889,7 +1890,7 @@ static struct lvmcache_info * _create_info(struct labeller *labeller, struct dev
 
 	if (!(label = label_create(labeller)))
 		return_NULL;
-	if (!(info = dm_zalloc(sizeof(*info)))) {
+	if (!(info = zalloc(sizeof(*info)))) {
 		log_error("lvmcache_info allocation failed");
 		label_destroy(label);
 		return NULL;
@@ -1965,7 +1966,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 			 * use it.
 			 */
 
-			if (!(devl = dm_zalloc(sizeof(*devl))))
+			if (!(devl = zalloc(sizeof(*devl))))
 				return_NULL;
 			devl->dev = dev;
 
@@ -2020,8 +2021,8 @@ update_vginfo:
 		if (created) {
 			dm_hash_remove(_pvid_hash, pvid_s);
 			strcpy(info->dev->pvid, "");
-			dm_free(info->label);
-			dm_free(info);
+			free(info->label);
+			free(info);
 		}
 		return NULL;
 	}
@@ -2034,7 +2035,7 @@ static void _lvmcache_destroy_entry(struct lvmcache_info *info)
 	_vginfo_detach_info(info);
 	info->dev->pvid[0] = 0;
 	label_destroy(info->label);
-	dm_free(info);
+	free(info);
 }
 
 static void _lvmcache_destroy_vgnamelist(struct lvmcache_vginfo *vginfo)
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index fc46c07..238a7f1 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -196,7 +196,7 @@ void lvmetad_set_token(const struct dm_config_value *filter)
 {
 	int ft = 0;
 
-	dm_free(_lvmetad_token);
+	free(_lvmetad_token);
 
 	while (filter && filter->type == DM_CFG_STRING) {
 		ft = calc_crc(ft, (const uint8_t *) filter->v.str, strlen(filter->v.str));
@@ -209,7 +209,7 @@ void lvmetad_set_token(const struct dm_config_value *filter)
 
 void lvmetad_release_token(void)
 {
-	dm_free(_lvmetad_token);
+	free(_lvmetad_token);
 	_lvmetad_token = NULL;
 }
 
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index b7119d2..ab9f942 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -12,6 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/commands/toolcontext.h"
 #include "lib/metadata/segtype.h"
@@ -261,7 +262,7 @@ static int _cache_pool_text_export(const struct lv_segment *seg,
 
 static void _destroy(struct segment_type *segtype)
 {
-	dm_free((void *) segtype);
+	free((void *) segtype);
 }
 
 #ifdef DEVMAPPER_SUPPORT
@@ -611,7 +612,7 @@ int init_cache_segtypes(struct cmd_context *cmd,
 			struct segtype_library *seglib)
 #endif
 {
-	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
+	struct segment_type *segtype = zalloc(sizeof(*segtype));
 
 	if (!segtype) {
 		log_error("Failed to allocate memory for cache_pool segtype");
@@ -626,7 +627,7 @@ int init_cache_segtypes(struct cmd_context *cmd,
 		return_0;
 	log_very_verbose("Initialised segtype: %s", segtype->name);
 
-	segtype = dm_zalloc(sizeof(*segtype));
+	segtype = zalloc(sizeof(*segtype));
 	if (!segtype) {
 		log_error("Failed to allocate memory for cache segtype");
 		return 0;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 8eaece6..20a73b7 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/commands/toolcontext.h"
 #include "lib/metadata/metadata.h"
@@ -1758,7 +1759,7 @@ void destroy_config_context(struct cmd_context *cmd)
 	if (cmd->libmem)
 		dm_pool_destroy(cmd->libmem);
 
-	dm_free(cmd);
+	free(cmd);
 }
 
 /*
@@ -1771,7 +1772,7 @@ struct cmd_context *create_config_context(void)
 {
 	struct cmd_context *cmd;
 
-	if (!(cmd = dm_zalloc(sizeof(*cmd))))
+	if (!(cmd = zalloc(sizeof(*cmd))))
 		goto_out;
 
 	strcpy(cmd->system_dir, DEFAULT_SYS_DIR);
@@ -1838,7 +1839,7 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 
 	init_syslog(DEFAULT_LOG_FACILITY);
 
-	if (!(cmd = dm_zalloc(sizeof(*cmd)))) {
+	if (!(cmd = zalloc(sizeof(*cmd)))) {
 		log_error("Failed to allocate command context");
 		return NULL;
 	}
@@ -1870,7 +1871,7 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 #endif
 	   ) {
 		/* Allocate 2 buffers */
-		if (!(cmd->linebuffer = dm_malloc(2 * _linebuffer_size))) {
+		if (!(cmd->linebuffer = malloc(2 * _linebuffer_size))) {
 			log_error("Failed to allocate line buffer.");
 			goto out;
 		}
@@ -2062,7 +2063,7 @@ static void _destroy_dev_types(struct cmd_context *cmd)
 	if (!cmd->dev_types)
 		return;
 
-	dm_free(cmd->dev_types);
+	free(cmd->dev_types);
 	cmd->dev_types = NULL;
 }
 
@@ -2275,10 +2276,10 @@ void destroy_toolcontext(struct cmd_context *cmd)
 				cmd->linebuffer = NULL;	/* Leave buffer in place (deliberate leak) */
 		}
 
-		dm_free(cmd->linebuffer);
+		free(cmd->linebuffer);
 	}
 #endif
-	dm_free(cmd);
+	free(cmd);
 
 	lvmetad_release_token();
 	lvmetad_disconnect();
diff --git a/lib/config/config.c b/lib/config/config.c
index c638d75..2e7e9b6 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -529,7 +529,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 		}
 		fb = fb + mmap_offset;
 	} else {
-		if (!(buf = dm_malloc(size + size2))) {
+		if (!(buf = malloc(size + size2))) {
 			log_error("Failed to allocate circular buffer.");
 			return 0;
 		}
@@ -573,7 +573,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 
       out:
 	if (!use_mmap)
-		dm_free(buf);
+		free(buf);
 	else {
 		/* unmap the file */
 		if (munmap(fb - mmap_offset, size + mmap_offset)) {
@@ -715,8 +715,8 @@ static struct dm_config_value *_get_def_array_values(struct cmd_context *cmd,
 		return array;
 	}
 
-	if (!(p = token = enc_value = dm_strdup(def_enc_value))) {
-		log_error("_get_def_array_values: dm_strdup failed");
+	if (!(p = token = enc_value = strdup(def_enc_value))) {
+		log_error("_get_def_array_values: strdup failed");
 		return NULL;
 	}
 	/* Proper value always starts with '#'. */
@@ -741,7 +741,7 @@ static struct dm_config_value *_get_def_array_values(struct cmd_context *cmd,
 
 		if (!(v = dm_config_create_value(cft))) {
 			log_error("Failed to create default config array value for %s.", def->name);
-			dm_free(enc_value);
+			free(enc_value);
 			return NULL;
 		}
 
@@ -770,7 +770,7 @@ static struct dm_config_value *_get_def_array_values(struct cmd_context *cmd,
 				break;
 			case 'S':
 				if (!(r = dm_pool_strdup(cft->mem, token + 1))) {
-					dm_free(enc_value);
+					free(enc_value);
 					log_error("Failed to duplicate token for default "
 						  "array value of %s.", def->name);
 					return NULL;
@@ -786,13 +786,13 @@ static struct dm_config_value *_get_def_array_values(struct cmd_context *cmd,
 		token = p;
 	}
 
-	dm_free(enc_value);
+	free(enc_value);
 	return array;
 bad:
 	log_error(INTERNAL_ERROR "Default array value malformed for \"%s\", "
 		  "value: \"%s\", token: \"%s\".", def->name,
 		  def->default_value.v_CFG_TYPE_STRING, token);
-	dm_free(enc_value);
+	free(enc_value);
 	return NULL;
 }
 
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 561f68e..f4c0712 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -70,14 +70,14 @@ struct cb_set {
 static struct cb_set *_cb_set_create(unsigned nr)
 {
 	int i;
-	struct cb_set *cbs = dm_malloc(sizeof(*cbs));
+	struct cb_set *cbs = malloc(sizeof(*cbs));
 
 	if (!cbs)
 		return NULL;
 
-	cbs->vec = dm_malloc(nr * sizeof(*cbs->vec));
+	cbs->vec = malloc(nr * sizeof(*cbs->vec));
 	if (!cbs->vec) {
-		dm_free(cbs);
+		free(cbs);
 		return NULL;
 	}
 
@@ -100,8 +100,8 @@ static void _cb_set_destroy(struct cb_set *cbs)
 		return;
 	}
 
-	dm_free(cbs->vec);
-	dm_free(cbs);
+	free(cbs->vec);
+	free(cbs);
 }
 
 static struct control_block *_cb_alloc(struct cb_set *cbs, void *context)
@@ -155,7 +155,7 @@ static void _async_destroy(struct io_engine *ioe)
 	if (r)
 		log_sys_warn("io_destroy");
 
-	dm_free(e);
+	free(e);
 }
 
 static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
@@ -253,7 +253,7 @@ static unsigned _async_max_io(struct io_engine *e)
 struct io_engine *create_async_io_engine(void)
 {
 	int r;
-	struct async_engine *e = dm_malloc(sizeof(*e));
+	struct async_engine *e = malloc(sizeof(*e));
 
 	if (!e)
 		return NULL;
@@ -267,14 +267,14 @@ struct io_engine *create_async_io_engine(void)
 	r = io_setup(MAX_IO, &e->aio_context);
 	if (r < 0) {
 		log_warn("io_setup failed");
-		dm_free(e);
+		free(e);
 		return NULL;
 	}
 
 	e->cbs = _cb_set_create(MAX_IO);
 	if (!e->cbs) {
 		log_warn("couldn't create control block set");
-		dm_free(e);
+		free(e);
 		return NULL;
 	}
 
@@ -303,7 +303,7 @@ static struct sync_engine *_to_sync(struct io_engine *e)
 static void _sync_destroy(struct io_engine *ioe)
 {
         struct sync_engine *e = _to_sync(ioe);
-        dm_free(e);
+        free(e);
 }
 
 static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
@@ -362,7 +362,7 @@ static bool _sync_wait(struct io_engine *ioe, io_complete_fn fn)
 	dm_list_iterate_items_safe(io, tmp, &e->complete) {
 		fn(io->context, 0);
 		dm_list_del(&io->list);
-		dm_free(io);
+		free(io);
 	}
 
 	return true;
@@ -375,7 +375,7 @@ static unsigned _sync_max_io(struct io_engine *e)
 
 struct io_engine *create_sync_io_engine(void)
 {
-	struct sync_engine *e = dm_malloc(sizeof(*e));
+	struct sync_engine *e = malloc(sizeof(*e));
 
 	if (!e)
         	return NULL;
@@ -530,10 +530,10 @@ static bool _init_free_list(struct bcache *cache, unsigned count, unsigned pgsiz
 		return false;
 
 	cache->raw_data = data;
-	cache->raw_blocks = dm_malloc(count * sizeof(*cache->raw_blocks));
+	cache->raw_blocks = malloc(count * sizeof(*cache->raw_blocks));
 
 	if (!cache->raw_blocks)
-		dm_free(cache->raw_data);
+		free(cache->raw_data);
 
 	for (i = 0; i < count; i++) {
 		struct block *b = cache->raw_blocks + i;
@@ -547,8 +547,8 @@ static bool _init_free_list(struct bcache *cache, unsigned count, unsigned pgsiz
 
 static void _exit_free_list(struct bcache *cache)
 {
-	dm_free(cache->raw_data);
-	dm_free(cache->raw_blocks);
+	free(cache->raw_data);
+	free(cache->raw_blocks);
 }
 
 static struct block *_alloc_block(struct bcache *cache)
@@ -885,7 +885,7 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 		return NULL;
 	}
 
-	cache = dm_malloc(sizeof(*cache));
+	cache = malloc(sizeof(*cache));
 	if (!cache)
 		return NULL;
 
@@ -906,7 +906,7 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
         cache->rtree = radix_tree_create(NULL, NULL);
 	if (!cache->rtree) {
 		cache->engine->destroy(cache->engine);
-		dm_free(cache);
+		free(cache);
 		return NULL;
 	}
 
@@ -920,7 +920,7 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 	if (!_init_free_list(cache, nr_cache_blocks, pgsize)) {
 		cache->engine->destroy(cache->engine);
 		radix_tree_destroy(cache->rtree);
-		dm_free(cache);
+		free(cache);
 		return NULL;
 	}
 
@@ -937,7 +937,7 @@ void bcache_destroy(struct bcache *cache)
 	_exit_free_list(cache);
 	radix_tree_destroy(cache->rtree);
 	cache->engine->destroy(cache->engine);
-	dm_free(cache);
+	free(cache);
 }
 
 sector_t bcache_block_sectors(struct bcache *cache)
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 4f7a7a0..d60454a 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/datastruct/btree.h"
 #include "lib/config/config.h"
@@ -80,9 +81,9 @@ void dev_destroy_file(struct device *dev)
 	if (!(dev->flags & DEV_ALLOCED))
 		return;
 
-	dm_free((void *) dm_list_item(dev->aliases.n, struct dm_str_list)->str);
-	dm_free(dev->aliases.n);
-	dm_free(dev);
+	free((void *) dm_list_item(dev->aliases.n, struct dm_str_list)->str);
+	free(dev->aliases.n);
+	free(dev);
 }
 
 struct device *dev_create_file(const char *filename, struct device *dev,
@@ -92,19 +93,19 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 
 	if (allocate) {
 		if (use_malloc) {
-			if (!(dev = dm_zalloc(sizeof(*dev)))) {
+			if (!(dev = zalloc(sizeof(*dev)))) {
 				log_error("struct device allocation failed");
 				return NULL;
 			}
-			if (!(alias = dm_zalloc(sizeof(*alias)))) {
+			if (!(alias = zalloc(sizeof(*alias)))) {
 				log_error("struct dm_str_list allocation failed");
-				dm_free(dev);
+				free(dev);
 				return NULL;
 			}
-			if (!(alias->str = dm_strdup(filename))) {
+			if (!(alias->str = strdup(filename))) {
 				log_error("filename strdup failed");
-				dm_free(dev);
-				dm_free(alias);
+				free(dev);
+				free(alias);
 				return NULL;
 			}
 		} else {
@@ -123,7 +124,7 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 				return NULL;
 			}
 		}
-	} else if (!(alias->str = dm_strdup(filename))) {
+	} else if (!(alias->str = strdup(filename))) {
 		log_error("filename strdup failed");
 		return NULL;
 	}
@@ -861,7 +862,7 @@ static int _insert_dev(const char *path, dev_t d)
 static char *_join(const char *dir, const char *name)
 {
 	size_t len = strlen(dir) + strlen(name) + 2;
-	char *r = dm_malloc(len);
+	char *r = malloc(len);
 	if (r)
 		snprintf(r, len, "%s/%s", dir, name);
 
@@ -909,7 +910,7 @@ static int _insert_dir(const char *dir)
 
 			_collapse_slashes(path);
 			r &= _insert(path, NULL, 1, 0);
-			dm_free(path);
+			free(path);
 
 			free(dirent[n]);
 		}
@@ -1632,7 +1633,7 @@ struct device *dev_cache_get_by_devt(dev_t dev, struct dev_filter *f)
 
 struct dev_iter *dev_iter_create(struct dev_filter *f, int unused)
 {
-	struct dev_iter *di = dm_malloc(sizeof(*di));
+	struct dev_iter *di = malloc(sizeof(*di));
 
 	if (!di) {
 		log_error("dev_iter allocation failed");
@@ -1651,7 +1652,7 @@ void dev_iter_destroy(struct dev_iter *iter)
 {
 	if (iter->filter)
 		iter->filter->use_count--;
-	dm_free(iter);
+	free(iter);
 }
 
 static struct device *_iter_next(struct dev_iter *iter)
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 65b3db4..ffdf75e 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -256,7 +256,7 @@ static int _aligned_io(struct device_area *where, char *buffer,
 		return _io(where, buffer, should_write, reason);
 
 	/* Allocate a bounce buffer with an extra block */
-	if (!(bounce_buf = bounce = dm_malloc((size_t) widened.size + block_size))) {
+	if (!(bounce_buf = bounce = malloc((size_t) widened.size + block_size))) {
 		log_error("Bounce buffer malloc failed");
 		return 0;
 	}
@@ -294,7 +294,7 @@ static int _aligned_io(struct device_area *where, char *buffer,
 	r = 1;
 
 out:
-	dm_free(bounce_buf);
+	free(bounce_buf);
 	return r;
 }
 
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 718038c..0b7af1b 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -12,6 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/device/dev-type.h"
 #include "lib/mm/xlate.h"
@@ -49,7 +50,7 @@ struct dev_types *create_dev_types(const char *proc_dir,
 	const char *name;
 	char *nl;
 
-	if (!(dt = dm_zalloc(sizeof(struct dev_types)))) {
+	if (!(dt = zalloc(sizeof(struct dev_types)))) {
 		log_error("Failed to allocate device type register.");
 		return NULL;
 	}
@@ -204,7 +205,7 @@ struct dev_types *create_dev_types(const char *proc_dir,
 
 	return dt;
 bad:
-	dm_free(dt);
+	free(dt);
 	return NULL;
 }
 
diff --git a/lib/device/device.h b/lib/device/device.h
index b9aec70..8f9ed55 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -22,7 +22,7 @@
 
 #define DEV_ACCESSED_W		0x00000001	/* Device written to? */
 #define DEV_REGULAR		0x00000002	/* Regular file? */
-#define DEV_ALLOCED		0x00000004	/* dm_malloc used */
+#define DEV_ALLOCED		0x00000004	/* malloc used */
 #define DEV_OPENED_RW		0x00000008	/* Opened RW */
 #define DEV_OPENED_EXCL		0x00000010	/* Opened EXCL */
 #define DEV_O_DIRECT		0x00000020	/* Use O_DIRECT */
diff --git a/lib/error/errseg.c b/lib/error/errseg.c
index 9f0262a..bbdf235 100644
--- a/lib/error/errseg.c
+++ b/lib/error/errseg.c
@@ -12,6 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/commands/toolcontext.h"
 #include "lib/metadata/segtype.h"
@@ -77,7 +78,7 @@ static int _errseg_modules_needed(struct dm_pool *mem,
 
 static void _errseg_destroy(struct segment_type *segtype)
 {
-	dm_free(segtype);
+	free(segtype);
 }
 
 static struct segtype_handler _error_ops = {
@@ -92,7 +93,7 @@ static struct segtype_handler _error_ops = {
 
 struct segment_type *init_error_segtype(struct cmd_context *cmd)
 {
-	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
+	struct segment_type *segtype = zalloc(sizeof(*segtype));
 
 	if (!segtype)
 		return_NULL;
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index 8d9e061..8691aeb 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 #include "lib/device/device.h"
@@ -53,8 +54,8 @@ static void _composite_destroy(struct dev_filter *f)
 	for (filters = (struct dev_filter **) f->private; *filters; ++filters)
 		(*filters)->destroy(*filters);
 
-	dm_free(f->private);
-	dm_free(f);
+	free(f->private);
+	free(f);
 }
 
 static int _dump(struct dev_filter *f, int merge_existing)
@@ -85,7 +86,7 @@ struct dev_filter *composite_filter_create(int n, int use_dev_ext_info, struct d
 	if (!filters)
 		return_NULL;
 
-	if (!(filters_copy = dm_malloc(sizeof(*filters) * (n + 1)))) {
+	if (!(filters_copy = malloc(sizeof(*filters) * (n + 1)))) {
 		log_error("Composite filters allocation failed.");
 		return NULL;
 	}
@@ -93,9 +94,9 @@ struct dev_filter *composite_filter_create(int n, int use_dev_ext_info, struct d
 	memcpy(filters_copy, filters, sizeof(*filters) * n);
 	filters_copy[n] = NULL;
 
-	if (!(cft = dm_zalloc(sizeof(*cft)))) {
+	if (!(cft = zalloc(sizeof(*cft)))) {
 		log_error("Composite filters allocation failed.");
-		dm_free(filters_copy);
+		free(filters_copy);
 		return NULL;
 	}
 
diff --git a/lib/filters/filter-fwraid.c b/lib/filters/filter-fwraid.c
index 62022b3..03c63b3 100644
--- a/lib/filters/filter-fwraid.c
+++ b/lib/filters/filter-fwraid.c
@@ -12,6 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 
@@ -96,14 +97,14 @@ static void _destroy(struct dev_filter *f)
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying firmware RAID filter while in use %u times.", f->use_count);
 
-	dm_free(f);
+	free(f);
 }
 
 struct dev_filter *fwraid_filter_create(struct dev_types *dt __attribute__((unused)))
 {
 	struct dev_filter *f;
 
-	if (!(f = dm_zalloc(sizeof(*f)))) {
+	if (!(f = zalloc(sizeof(*f)))) {
 		log_error("Firmware RAID filter allocation failed");
 		return NULL;
 	}
diff --git a/lib/filters/filter-internal.c b/lib/filters/filter-internal.c
index ebbee7e..85e04d4 100644
--- a/lib/filters/filter-internal.c
+++ b/lib/filters/filter-internal.c
@@ -12,6 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 
@@ -58,14 +59,14 @@ static void _destroy(struct dev_filter *f)
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying internal filter while in use %u times.", f->use_count);
 
-	dm_free(f);
+	free(f);
 }
 
 struct dev_filter *internal_filter_create(void)
 {
 	struct dev_filter *f;
 
-	if (!(f = dm_zalloc(sizeof(*f)))) {
+	if (!(f = zalloc(sizeof(*f)))) {
 		log_error("md filter allocation failed");
 		return NULL;
 	}
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index b9d3bc8..4fcbca9 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 
@@ -138,14 +139,14 @@ static void _destroy(struct dev_filter *f)
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying md filter while in use %u times.", f->use_count);
 
-	dm_free(f);
+	free(f);
 }
 
 struct dev_filter *md_filter_create(struct cmd_context *cmd, struct dev_types *dt)
 {
 	struct dev_filter *f;
 
-	if (!(f = dm_zalloc(sizeof(*f)))) {
+	if (!(f = zalloc(sizeof(*f)))) {
 		log_error("md filter allocation failed");
 		return NULL;
 	}
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index a7dc12e..785b518 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -12,6 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 #include "lib/activate/activate.h"
@@ -265,7 +266,7 @@ static void _destroy(struct dev_filter *f)
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying mpath filter while in use %u times.", f->use_count);
 
-	dm_free(f);
+	free(f);
 }
 
 struct dev_filter *mpath_filter_create(struct dev_types *dt)
@@ -278,7 +279,7 @@ struct dev_filter *mpath_filter_create(struct dev_types *dt)
 		return NULL;
 	}
 
-	if (!(f = dm_zalloc(sizeof(*f)))) {
+	if (!(f = zalloc(sizeof(*f)))) {
 		log_error("mpath filter allocation failed");
 		return NULL;
 	}
diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index a85e182..34151fd 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 
@@ -49,14 +50,14 @@ static void _partitioned_filter_destroy(struct dev_filter *f)
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying partitioned filter while in use %u times.", f->use_count);
 
-	dm_free(f);
+	free(f);
 }
 
 struct dev_filter *partitioned_filter_create(struct dev_types *dt)
 {
 	struct dev_filter *f;
 
-	if (!(f = dm_zalloc(sizeof(struct dev_filter)))) {
+	if (!(f = zalloc(sizeof(struct dev_filter)))) {
 		log_error("Partitioned filter allocation failed");
 		return NULL;
 	}
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 8f6d584..643c349 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 #include "lib/config/config.h"
@@ -360,10 +361,10 @@ static void _persistent_destroy(struct dev_filter *f)
 		log_error(INTERNAL_ERROR "Destroying persistent filter while in use %u times.", f->use_count);
 
 	dm_hash_destroy(pf->devices);
-	dm_free(pf->file);
+	free(pf->file);
 	pf->real->destroy(pf->real);
-	dm_free(pf);
-	dm_free(f);
+	free(pf);
+	free(f);
 }
 
 struct dev_filter *persistent_filter_create(struct dev_types *dt,
@@ -374,14 +375,14 @@ struct dev_filter *persistent_filter_create(struct dev_types *dt,
 	struct dev_filter *f = NULL;
 	struct stat info;
 
-	if (!(pf = dm_zalloc(sizeof(*pf)))) {
+	if (!(pf = zalloc(sizeof(*pf)))) {
 		log_error("Allocation of persistent filter failed.");
 		return NULL;
 	}
 
 	pf->dt = dt;
 
-	if (!(pf->file = dm_strdup(file))) {
+	if (!(pf->file = strdup(file))) {
 		log_error("Filename duplication for persistent filter failed.");
 		goto bad;
 	}
@@ -393,7 +394,7 @@ struct dev_filter *persistent_filter_create(struct dev_types *dt,
 		goto bad;
 	}
 
-	if (!(f = dm_zalloc(sizeof(*f)))) {
+	if (!(f = zalloc(sizeof(*f)))) {
 		log_error("Allocation of device filter for persistent filter failed.");
 		goto bad;
 	}
@@ -414,10 +415,10 @@ struct dev_filter *persistent_filter_create(struct dev_types *dt,
 	return f;
 
       bad:
-	dm_free(pf->file);
+	free(pf->file);
 	if (pf->devices)
 		dm_hash_destroy(pf->devices);
-	dm_free(pf);
-	dm_free(f);
+	free(pf);
+	free(f);
 	return NULL;
 }
diff --git a/lib/filters/filter-signature.c b/lib/filters/filter-signature.c
index 3aa6284..d4b6ea3 100644
--- a/lib/filters/filter-signature.c
+++ b/lib/filters/filter-signature.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 
@@ -64,14 +65,14 @@ static void _destroy(struct dev_filter *f)
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying signature filter while in use %u times.", f->use_count);
 
-	dm_free(f);
+	free(f);
 }
 
 struct dev_filter *signature_filter_create(struct dev_types *dt)
 {
 	struct dev_filter *f;
 
-	if (!(f = dm_zalloc(sizeof(*f)))) {
+	if (!(f = zalloc(sizeof(*f)))) {
 		log_error("md filter allocation failed");
 		return NULL;
 	}
diff --git a/lib/filters/filter-type.c b/lib/filters/filter-type.c
index 8ec3025..63d7c70 100644
--- a/lib/filters/filter-type.c
+++ b/lib/filters/filter-type.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 
@@ -36,14 +37,14 @@ static void _lvm_type_filter_destroy(struct dev_filter *f)
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying lvm_type filter while in use %u times.", f->use_count);
 
-	dm_free(f);
+	free(f);
 }
 
 struct dev_filter *lvm_type_filter_create(struct dev_types *dt)
 {
 	struct dev_filter *f;
 
-	if (!(f = dm_zalloc(sizeof(struct dev_filter)))) {
+	if (!(f = zalloc(sizeof(struct dev_filter)))) {
 		log_error("LVM type filter allocation failed");
 		return NULL;
 	}
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index 45c7832..498b90c 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -12,6 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 #include "lib/activate/activate.h"
@@ -157,15 +158,15 @@ static void _usable_filter_destroy(struct dev_filter *f)
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying usable device filter while in use %u times.", f->use_count);
 
-	dm_free(f->private);
-	dm_free(f);
+	free(f->private);
+	free(f);
 }
 
 struct dev_filter *usable_filter_create(struct dev_types *dt __attribute__((unused)), filter_mode_t mode)
 {
 	struct dev_filter *f;
 
-	if (!(f = dm_zalloc(sizeof(struct dev_filter)))) {
+	if (!(f = zalloc(sizeof(struct dev_filter)))) {
 		log_error("Usable device filter allocation failed");
 		return NULL;
 	}
@@ -173,9 +174,9 @@ struct dev_filter *usable_filter_create(struct dev_types *dt __attribute__((unus
 	f->passes_filter = _passes_usable_filter;
 	f->destroy = _usable_filter_destroy;
 	f->use_count = 0;
-	if (!(f->private = dm_zalloc(sizeof(filter_mode_t)))) {
+	if (!(f->private = zalloc(sizeof(filter_mode_t)))) {
 		log_error("Usable device filter mode allocation failed");
-		dm_free(f);
+		free(f);
 		return NULL;
 	}
 	*((filter_mode_t *) f->private) = mode;
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index ab80117..5cdbf6d 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -55,7 +55,7 @@ int archive_init(struct cmd_context *cmd, const char *dir,
 	if (!*dir)
 		return 1;
 
-	if (!(cmd->archive_params->dir = dm_strdup(dir))) {
+	if (!(cmd->archive_params->dir = strdup(dir))) {
 		log_error("Couldn't copy archive directory name.");
 		return 0;
 	}
@@ -71,7 +71,7 @@ void archive_exit(struct cmd_context *cmd)
 {
 	if (!cmd->archive_params)
 		return;
-	dm_free(cmd->archive_params->dir);
+	free(cmd->archive_params->dir);
 	memset(cmd->archive_params, 0, sizeof(*cmd->archive_params));
 }
 
@@ -193,7 +193,7 @@ int backup_init(struct cmd_context *cmd, const char *dir,
 	if (!*dir)
 		return 1;
 
-	if (!(cmd->backup_params->dir = dm_strdup(dir))) {
+	if (!(cmd->backup_params->dir = strdup(dir))) {
 		log_error("Couldn't copy backup directory name.");
 		return 0;
 	}
@@ -206,7 +206,7 @@ void backup_exit(struct cmd_context *cmd)
 {
 	if (!cmd->backup_params)
 		return;
-	dm_free(cmd->backup_params->dir);
+	free(cmd->backup_params->dir);
 	memset(cmd->backup_params, 0, sizeof(*cmd->backup_params));
 }
 
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 2924aea..a9a7e15 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "import-export.h"
 #include "lib/metadata/metadata.h"
@@ -123,7 +124,7 @@ static int _extend_buffer(struct formatter *f)
 
 	log_debug_metadata("Doubling metadata output buffer to " FMTu32,
 			   f->data.buf.size * 2);
-	if (!(newbuf = dm_realloc(f->data.buf.start,
+	if (!(newbuf = realloc(f->data.buf.start,
 				   f->data.buf.size * 2))) {
 		log_error("Buffer reallocation failed.");
 		return 0;
@@ -383,7 +384,7 @@ static char *_alloc_printed_str_list(struct dm_list *list)
 	/* '[' + ']' + '\0' */
 	size += 3;
 
-	if (!(buffer = buf = dm_malloc(size))) {
+	if (!(buffer = buf = malloc(size))) {
 		log_error("Could not allocate memory for string list buffer.");
 		return NULL;
 	}
@@ -408,7 +409,7 @@ static char *_alloc_printed_str_list(struct dm_list *list)
 	return buffer;
 
 bad:
-	dm_free(buffer);
+	free(buffer);
 	return_NULL;
 }
 
@@ -421,10 +422,10 @@ static int _out_list(struct formatter *f, struct dm_list *list,
 		if (!(buffer = _alloc_printed_str_list(list)))
 			return_0;
 		if (!out_text(f, "%s = %s", list_name, buffer)) {
-			dm_free(buffer);
+			free(buffer);
 			return_0;
 		}
-		dm_free(buffer);
+		free(buffer);
 	}
 
 	return 1;
@@ -835,7 +836,7 @@ static int _alloc_printed_indirect_descendants(struct dm_list *indirect_glvs, ch
 	/* '[' + ']' + '\0' */
 	buf_size += 3;
 
-	if (!(*buffer = dm_malloc(buf_size))) {
+	if (!(*buffer = malloc(buf_size))) {
 		log_error("Could not allocate memory for ancestor list buffer.");
 		return 0;
 	}
@@ -863,7 +864,7 @@ static int _alloc_printed_indirect_descendants(struct dm_list *indirect_glvs, ch
 	return 1;
 bad:
 	if (*buffer) {
-		dm_free(*buffer);
+		free(*buffer);
 		*buffer = NULL;
 	}
 	return 0;
@@ -908,7 +909,7 @@ static int _print_historical_lv(struct formatter *f, struct historical_logical_v
 
 	r = 1;
 out:
-	dm_free(descendants_buffer);
+	free(descendants_buffer);
 
 	return r;
 }
@@ -1034,7 +1035,7 @@ int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp)
 
 	_init();
 
-	if (!(f = dm_zalloc(sizeof(*f))))
+	if (!(f = zalloc(sizeof(*f))))
 		return_0;
 
 	f->data.fp = fp;
@@ -1046,7 +1047,7 @@ int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp)
 	r = _text_vg_export(f, vg, desc);
 	if (r)
 		r = !ferror(f->data.fp);
-	dm_free(f);
+	free(f);
 	return r;
 }
 
@@ -1058,11 +1059,11 @@ size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 
 	_init();
 
-	if (!(f = dm_zalloc(sizeof(*f))))
+	if (!(f = zalloc(sizeof(*f))))
 		return_0;
 
 	f->data.buf.size = 65536;	/* Initial metadata limit */
-	if (!(f->data.buf.start = dm_malloc(f->data.buf.size))) {
+	if (!(f->data.buf.start = malloc(f->data.buf.size))) {
 		log_error("text_export buffer allocation failed");
 		goto out;
 	}
@@ -1073,7 +1074,7 @@ size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 	f->nl = &_nl_raw;
 
 	if (!_text_vg_export(f, vg, desc)) {
-		dm_free(f->data.buf.start);
+		free(f->data.buf.start);
 		goto_out;
 	}
 
@@ -1081,7 +1082,7 @@ size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 	*buf = f->data.buf.start;
 
       out:
-	dm_free(f);
+	free(f);
 	return r;
 }
 
@@ -1102,11 +1103,11 @@ struct dm_config_tree *export_vg_to_config_tree(struct volume_group *vg)
 
 	if (!(vg_cft = config_tree_from_string_without_dup_node_check(buf))) {
 		log_error("Error parsing metadata for VG %s.", vg->name);
-		dm_free(buf);
+		free(buf);
 		return_NULL;
 	}
 
-	dm_free(buf);
+	free(buf);
 	return vg_cft;
 }
 
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 69d8afc..98894e7 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -235,7 +235,7 @@ int read_segtype_lvflags(uint64_t *status, char *segtype_str)
 	if (!(str = strchr(segtype_str, '+')))
 		return 1; /* No flags */
 
-	if (!(buffer = dm_strdup(str + 1))) {
+	if (!(buffer = strdup(str + 1))) {
 		log_error("Cannot duplicate segment string.");
 		return 0;
 	}
@@ -263,7 +263,7 @@ int read_segtype_lvflags(uint64_t *status, char *segtype_str)
 	else
 		*str = '\0'; /* Cut away 1st. '+' */
 
-	dm_free(buffer);
+	free(buffer);
 
 	return 1;
 }
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c834335..907944a 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -224,7 +224,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 		 * "dm_config_maybe_section" returning true when there's no valid
 		 * metadata in a sector (sectors with all nulls).
 		 */
-		if (!(buf = dm_malloc(size + size2)))
+		if (!(buf = malloc(size + size2)))
 			goto_out;
 
 		if (!dev_read_bytes(area->dev, offset, size, buf)) {
@@ -273,13 +273,13 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 				size += SECTOR_SIZE;
 			}
 		}
-		dm_free(buf);
+		free(buf);
 		buf = NULL;
 	}
 
 	r = 1;
  out:
-	dm_free(buf);
+	free(buf);
 	return r;
 }
 
@@ -294,7 +294,7 @@ static int _text_lv_setup(struct format_instance *fid __attribute__((unused)),
 	if (lv->size > max_size) {
 		char *dummy = display_size(max_size);
 		log_error("logical volumes cannot be larger than %s", dummy);
-		dm_free(dummy);
+		free(dummy);
 		return 0;
 	}
 */
@@ -711,7 +711,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
       out:
 	if (!r) {
-		dm_free(fidtc->raw_metadata_buf);
+		free(fidtc->raw_metadata_buf);
 		fidtc->raw_metadata_buf = NULL;
 	}
 
@@ -807,7 +807,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 
       out:
 	if (!precommit) {
-		dm_free(fidtc->raw_metadata_buf);
+		free(fidtc->raw_metadata_buf);
 		fidtc->raw_metadata_buf = NULL;
 	}
 
@@ -1547,7 +1547,7 @@ static int _add_raw(struct dm_list *raw_list, struct device_area *dev_area)
 			return 1;
 	}
 
-	if (!(rl = dm_malloc(sizeof(struct raw_list)))) {
+	if (!(rl = malloc(sizeof(struct raw_list)))) {
 		log_error("_add_raw allocation failed");
 		return 0;
 	}
@@ -1715,7 +1715,7 @@ static void _free_dirs(struct dm_list *dir_list)
 
 	dm_list_iterate_safe(dl, tmp, dir_list) {
 		dm_list_del(dl);
-		dm_free(dl);
+		free(dl);
 	}
 }
 
@@ -1725,7 +1725,7 @@ static void _free_raws(struct dm_list *raw_list)
 
 	dm_list_iterate_safe(rl, tmp, raw_list) {
 		dm_list_del(rl);
-		dm_free(rl);
+		free(rl);
 	}
 }
 
@@ -1737,10 +1737,10 @@ static void _text_destroy(struct format_type *fmt)
 	if (fmt->private) {
 		_free_dirs(&((struct mda_lists *) fmt->private)->dirs);
 		_free_raws(&((struct mda_lists *) fmt->private)->raws);
-		dm_free(fmt->private);
+		free(fmt->private);
 	}
 
-	dm_free(fmt);
+	free(fmt);
 }
 
 static struct metadata_area_ops _metadata_text_file_ops = {
@@ -2079,7 +2079,7 @@ static int _add_metadata_area_to_pv(struct physical_volume *pv,
 
 	if (!(mdac = dm_pool_zalloc(pv->fid->mem, sizeof(struct mda_context)))) {
 		log_error("struct mda_context allocation failed");
-		dm_free(mda);
+		free(mda);
 		return 0;
 	}
 
@@ -2460,7 +2460,7 @@ static int _add_dir(const char *dir, struct dm_list *dir_list)
 	struct dir_list *dl;
 
 	if (dm_create_dir(dir)) {
-		if (!(dl = dm_malloc(sizeof(struct dm_list) + strlen(dir) + 1))) {
+		if (!(dl = malloc(sizeof(struct dm_list) + strlen(dir) + 1))) {
 			log_error("_add_dir allocation failed");
 			return 0;
 		}
@@ -2535,7 +2535,7 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 	const struct dm_config_value *cv;
 	struct mda_lists *mda_lists;
 
-	if (!(fmt = dm_malloc(sizeof(*fmt)))) {
+	if (!(fmt = malloc(sizeof(*fmt)))) {
 		log_error("Failed to allocate text format type structure.");
 		return NULL;
 	}
@@ -2550,9 +2550,9 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 			FMT_UNLIMITED_STRIPESIZE | FMT_CONFIG_PROFILE |
 			FMT_NON_POWER2_EXTENTS | FMT_PV_FLAGS;
 
-	if (!(mda_lists = dm_malloc(sizeof(struct mda_lists)))) {
+	if (!(mda_lists = malloc(sizeof(struct mda_lists)))) {
 		log_error("Failed to allocate dir_list");
-		dm_free(fmt);
+		free(fmt);
 		return NULL;
 	}
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index a7eaa6e..1157b98 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/format_text/format-text.h"
 #include "layout.h"
@@ -198,7 +199,7 @@ int add_da(struct dm_pool *mem, struct dm_list *das,
 	struct data_area_list *dal;
 
 	if (!mem) {
-		if (!(dal = dm_malloc(sizeof(*dal)))) {
+		if (!(dal = malloc(sizeof(*dal)))) {
 			log_error("struct data_area_list allocation failed");
 			return 0;
 		}
@@ -225,7 +226,7 @@ void del_das(struct dm_list *das)
 	dm_list_iterate_safe(dah, tmp, das) {
 		da = dm_list_item(dah, struct data_area_list);
 		dm_list_del(&da->list);
-		dm_free(da);
+		free(da);
 	}
 }
 
@@ -250,14 +251,14 @@ int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *
 	struct mda_context *mdac, *mdac2;
 
 	if (!mem) {
-		if (!(mdal = dm_malloc(sizeof(struct metadata_area)))) {
+		if (!(mdal = malloc(sizeof(struct metadata_area)))) {
 			log_error("struct mda_list allocation failed");
 			return 0;
 		}
 
-		if (!(mdac = dm_malloc(sizeof(struct mda_context)))) {
+		if (!(mdac = malloc(sizeof(struct mda_context)))) {
 			log_error("struct mda_context allocation failed");
-			dm_free(mdal);
+			free(mdal);
 			return 0;
 		}
 	} else {
@@ -304,9 +305,9 @@ void del_mdas(struct dm_list *mdas)
 
 	dm_list_iterate_safe(mdah, tmp, mdas) {
 		mda = dm_list_item(mdah, struct metadata_area);
-		dm_free(mda->metadata_locn);
+		free(mda->metadata_locn);
 		dm_list_del(&mda->list);
-		dm_free(mda);
+		free(mda);
 	}
 }
 
@@ -465,7 +466,7 @@ static void _text_destroy_label(struct labeller *l __attribute__((unused)),
 
 static void _fmt_text_destroy(struct labeller *l)
 {
-	dm_free(l);
+	free(l);
 }
 
 struct label_ops _text_ops = {
@@ -481,7 +482,7 @@ struct labeller *text_labeller_create(const struct format_type *fmt)
 {
 	struct labeller *l;
 
-	if (!(l = dm_zalloc(sizeof(*l)))) {
+	if (!(l = zalloc(sizeof(*l)))) {
 		log_error("Couldn't allocate labeller object.");
 		return NULL;
 	}
diff --git a/lib/freeseg/freeseg.c b/lib/freeseg/freeseg.c
index 90e9cd3..fa73e22 100644
--- a/lib/freeseg/freeseg.c
+++ b/lib/freeseg/freeseg.c
@@ -12,13 +12,14 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/commands/toolcontext.h"
 #include "lib/metadata/segtype.h"
 
 static void _freeseg_destroy(struct segment_type *segtype)
 {
-	dm_free(segtype);
+	free(segtype);
 }
 
 static struct segtype_handler _freeseg_ops = {
@@ -27,7 +28,7 @@ static struct segtype_handler _freeseg_ops = {
 
 struct segment_type *init_free_segtype(struct cmd_context *cmd)
 {
-	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
+	struct segment_type *segtype = zalloc(sizeof(*segtype));
 
 	if (!segtype)
 		return_NULL;
diff --git a/lib/label/label.c b/lib/label/label.c
index ce995d6..373df29 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -13,6 +13,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#define _GNU_SOURCE
+
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/label/label.h"
 #include "lib/misc/crc.h"
@@ -26,7 +29,7 @@
 #include <fcntl.h>
 #include <unistd.h>
 #include <sys/time.h>
-
+#include <sys/types.h>
 
 /* FIXME Allow for larger labels?  Restricted to single sector currently */
 
@@ -49,7 +52,7 @@ static struct labeller_i *_alloc_li(const char *name, struct labeller *l)
 
 	len = sizeof(*li) + strlen(name) + 1;
 
-	if (!(li = dm_malloc(len))) {
+	if (!(li = malloc(len))) {
 		log_error("Couldn't allocate memory for labeller list object.");
 		return NULL;
 	}
@@ -73,7 +76,7 @@ void label_exit(void)
 	dm_list_iterate_items_safe(li, tli, &_labellers) {
 		dm_list_del(&li->list);
 		li->l->ops->destroy(li->l);
-		dm_free(li);
+		free(li);
 	}
 
 	dm_list_init(&_labellers);
@@ -217,14 +220,14 @@ int label_write(struct device *dev, struct label *label)
 void label_destroy(struct label *label)
 {
 	label->labeller->ops->destroy_label(label->labeller, label);
-	dm_free(label);
+	free(label);
 }
 
 struct label *label_create(struct labeller *labeller)
 {
 	struct label *label;
 
-	if (!(label = dm_zalloc(sizeof(*label)))) {
+	if (!(label = zalloc(sizeof(*label)))) {
 		log_error("label allocaction failed");
 		return NULL;
 	}
@@ -831,7 +834,7 @@ int label_scan(struct cmd_context *cmd)
 	}
 
 	while ((dev = dev_iter_get(iter))) {
-		if (!(devl = dm_zalloc(sizeof(*devl))))
+		if (!(devl = zalloc(sizeof(*devl))))
 			continue;
 		devl->dev = dev;
 		dm_list_add(&all_devs, &devl->list);
@@ -858,7 +861,7 @@ int label_scan(struct cmd_context *cmd)
 
 	dm_list_iterate_items_safe(devl, devl2, &all_devs) {
 		dm_list_del(&devl->list);
-		dm_free(devl);
+		free(devl);
 	}
 
 	return 1;
@@ -997,7 +1000,7 @@ int label_read(struct device *dev)
 	int failed = 0;
 
 	/* scanning is done by list, so make a single item list for this dev */
-	if (!(devl = dm_zalloc(sizeof(*devl))))
+	if (!(devl = zalloc(sizeof(*devl))))
 		return 0;
 	devl->dev = dev;
 	dm_list_init(&one_dev);
@@ -1010,7 +1013,7 @@ int label_read(struct device *dev)
 
 	_scan_list(NULL, NULL, &one_dev, &failed);
 
-	dm_free(devl);
+	free(devl);
 
 	if (failed)
 		return 0;
diff --git a/lib/log/log.c b/lib/log/log.c
index a040ca5..fd056b1 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -123,13 +123,13 @@ static int _set_custom_log_stream(struct log_stream_item *stream_item, int custo
 		goto out;
 	}
 
-	if (!(stream_item->buffer = dm_malloc(LOG_STREAM_BUFFER_SIZE))) {
+	if (!(stream_item->buffer = malloc(LOG_STREAM_BUFFER_SIZE))) {
 		log_error("Failed to allocate buffer for stream on file "
 			  "descriptor %d.", (int) custom_fd);
 	} else {
 		if (setvbuf(final_stream, stream_item->buffer, _IOLBF, LOG_STREAM_BUFFER_SIZE)) {
 			log_sys_error("setvbuf", "");
-			dm_free(stream_item->buffer);
+			free(stream_item->buffer);
 			stream_item->buffer = NULL;
 		}
 	}
@@ -342,7 +342,7 @@ void release_log_memory(void)
 	if (!_log_direct)
 		return;
 
-	dm_free((char *) _log_dev_alias.str);
+	free((char *) _log_dev_alias.str);
 	_log_dev_alias.str = "activate_log file";
 }
 
@@ -396,7 +396,7 @@ void reset_lvm_errno(int store_errmsg)
 	_lvm_errno = 0;
 
 	if (_lvm_errmsg) {
-		dm_free(_lvm_errmsg);
+		free(_lvm_errmsg);
 		_lvm_errmsg = NULL;
 		_lvm_errmsg_size = _lvm_errmsg_len = 0;
 	}
@@ -542,7 +542,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 		msglen = strlen(message);
 		if ((_lvm_errmsg_len + msglen + 1) >= _lvm_errmsg_size) {
 			_lvm_errmsg_size = 2 * (_lvm_errmsg_len + msglen + 1);
-			if ((newbuf = dm_realloc(_lvm_errmsg,
+			if ((newbuf = realloc(_lvm_errmsg,
 						 _lvm_errmsg_size)))
 				_lvm_errmsg = newbuf;
 			else
diff --git a/lib/lvmpolld/lvmpolld-client.c b/lib/lvmpolld/lvmpolld-client.c
index 78cf813..1a76485 100644
--- a/lib/lvmpolld/lvmpolld-client.c
+++ b/lib/lvmpolld/lvmpolld-client.c
@@ -207,7 +207,7 @@ static int _process_poll_init(const struct cmd_context *cmd, const char *poll_ty
 	const char *e = getenv("LVM_SYSTEM_DIR");
 	int r = 0; 
 
-	str = dm_malloc(INTERV_SIZE * sizeof(char));
+	str = malloc(INTERV_SIZE * sizeof(char));
 	if (!str)
 		return r;
 
@@ -266,7 +266,7 @@ out_rep:
 	daemon_reply_destroy(rep);
 out_req:
 	daemon_request_destroy(req);
-	dm_free(str);
+	free(str);
 
 	return r;
 }
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index dad5953..b2eba30 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2384,7 +2384,7 @@ static int _reserve_required_area(struct alloc_handle *ah, struct alloc_state *a
 	/* Expand areas array if needed after an area was split. */
 	if (ix_pva >= alloc_state->areas_size) {
 		alloc_state->areas_size *= 2;
-		if (!(alloc_state->areas = dm_realloc(alloc_state->areas, sizeof(*alloc_state->areas) * (alloc_state->areas_size)))) {
+		if (!(alloc_state->areas = realloc(alloc_state->areas, sizeof(*alloc_state->areas) * (alloc_state->areas_size)))) {
 			log_error("Memory reallocation for parallel areas failed.");
 			return 0;
 		}
@@ -3170,7 +3170,7 @@ static int _allocate(struct alloc_handle *ah,
 		alloc_state.areas_size += _stripes_per_mimage(prev_lvseg) * prev_lvseg->area_count;
 
 	/* Allocate an array of pv_areas to hold the largest space on each PV */
-	if (!(alloc_state.areas = dm_malloc(sizeof(*alloc_state.areas) * alloc_state.areas_size))) {
+	if (!(alloc_state.areas = malloc(sizeof(*alloc_state.areas) * alloc_state.areas_size))) {
 		log_error("Couldn't allocate areas array.");
 		return 0;
 	}
@@ -3251,7 +3251,7 @@ static int _allocate(struct alloc_handle *ah,
 	r = 1;
 
       out:
-	dm_free(alloc_state.areas);
+	free(alloc_state.areas);
 	return r;
 }
 
diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
index 53934d2..ccea2e4 100644
--- a/lib/metadata/metadata-liblvm.c
+++ b/lib/metadata/metadata-liblvm.c
@@ -452,7 +452,7 @@ int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
-		if (!(pv_name = dm_strdup(pv_names[i]))) {
+		if (!(pv_name = strdup(pv_names[i]))) {
 			log_error("Failed to duplicate pv name %s.", pv_names[i]);
 			return 0;
 		}
@@ -460,10 +460,10 @@ int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names
 		if (!_vg_extend_single_pv(vg, pv_name, pp, &max_phys_block_size)) {
 			log_error("Unable to add physical volume '%s' to "
 				  "volume group '%s'.", pv_name, vg->name);
-			dm_free(pv_name);
+			free(pv_name);
 			return 0;
 		}
-		dm_free(pv_name);
+		free(pv_name);
 	}
 
 	(void) check_pv_dev_sizes(vg);
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 4110dec..1ca4037 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/commands/toolcontext.h"
 #include "lib/metadata/metadata.h"
@@ -525,8 +526,8 @@ static int _mirrored_modules_needed(struct dm_pool *mem,
 
 static void _mirrored_destroy(struct segment_type *segtype)
 {
-	dm_free((void *) segtype->dso);
-	dm_free(segtype);
+	free((void *) segtype->dso);
+	free(segtype);
 }
 
 static struct segtype_handler _mirrored_ops = {
@@ -556,7 +557,7 @@ struct segment_type *init_segtype(struct cmd_context *cmd);
 struct segment_type *init_segtype(struct cmd_context *cmd)
 #endif
 {
-	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
+	struct segment_type *segtype = zalloc(sizeof(*segtype));
 
 	if (!segtype)
 		return_NULL;
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index 0d61f34..f7baf9d 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -81,6 +81,7 @@
 #include "lib/misc/intl.h"
 #include "device_mapper/all.h"
 #include "lib/misc/util.h"
+#include "base/memory/zalloc.h"
 
 #ifdef DM
 #  include "libdm/misc/dm-logging.h"
diff --git a/lib/misc/lvm-file.c b/lib/misc/lvm-file.c
index 5c23b0a..883b22d 100644
--- a/lib/misc/lvm-file.c
+++ b/lib/misc/lvm-file.c
@@ -166,7 +166,7 @@ void sync_dir(const char *file)
 	int fd;
 	char *dir, *c;
 
-	if (!(dir = dm_strdup(file))) {
+	if (!(dir = strdup(file))) {
 		log_error("sync_dir failed in strdup");
 		return;
 	}
@@ -194,7 +194,7 @@ void sync_dir(const char *file)
 		log_sys_error("close", dir);
 
       out:
-	dm_free(dir);
+	free(dir);
 }
 
 /*
@@ -210,7 +210,7 @@ int fcntl_lock_file(const char *file, short lock_type, int warn_if_read_only)
 	char *dir;
 	char *c;
 
-	if (!(dir = dm_strdup(file))) {
+	if (!(dir = strdup(file))) {
 		log_error("fcntl_lock_file failed in strdup.");
 		return -1;
 	}
@@ -219,11 +219,11 @@ int fcntl_lock_file(const char *file, short lock_type, int warn_if_read_only)
 		*c = '\0';
 
 	if (!dm_create_dir(dir)) {
-		dm_free(dir);
+		free(dir);
 		return -1;
 	}
 
-	dm_free(dir);
+	free(dir);
 
 	log_very_verbose("Locking %s (%s, %hd)", file,
 			 (lock_type == F_WRLCK) ? "F_WRLCK" : "F_RDLCK",
diff --git a/lib/misc/lvm-flock.c b/lib/misc/lvm-flock.c
index 00d74de..88ea6c2 100644
--- a/lib/misc/lvm-flock.c
+++ b/lib/misc/lvm-flock.c
@@ -74,8 +74,8 @@ static int _release_lock(const char *file, int unlock)
 			} else
 				_drop_shared_flock(ll->res, ll->lf);
 
-			dm_free(ll->res);
-			dm_free(llh);
+			free(ll->res);
+			free(llh);
 
 			if (file)
 				return 1;
@@ -188,11 +188,11 @@ int lock_file(const char *file, uint32_t flags)
 		return 0;
 	}
 
-	if (!(ll = dm_malloc(sizeof(struct lock_list))))
+	if (!(ll = malloc(sizeof(struct lock_list))))
 		return_0;
 
-	if (!(ll->res = dm_strdup(file))) {
-		dm_free(ll);
+	if (!(ll->res = strdup(file))) {
+		free(ll);
 		return_0;
 	}
 
@@ -211,8 +211,8 @@ int lock_file(const char *file, uint32_t flags)
 	if (r)
 		dm_list_add(&_lock_list, &ll->list);
 	else {
-		dm_free(ll->res);
-		dm_free(ll);
+		free(ll->res);
+		free(ll);
 		stack;
 	}
 
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 571caab..65f13c4 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -339,7 +339,7 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 		if (!_maps_buffer || len >= _maps_len) {
 			if (_maps_buffer)
 				_maps_len *= 2;
-			if (!(line = dm_realloc(_maps_buffer, _maps_len))) {
+			if (!(line = realloc(_maps_buffer, _maps_len))) {
 				log_error("Allocation of maps buffer failed.");
 				return 0;
 			}
@@ -551,7 +551,7 @@ static void _unlock_mem(struct cmd_context *cmd)
 		_restore_mmap();
 		if (close(_maps_fd))
 			log_sys_error("close", _procselfmaps);
-		dm_free(_maps_buffer);
+		free(_maps_buffer);
 		_maps_buffer = NULL;
 		if (_mstats < unlock_mstats) {
 			if ((_mstats + lvm_getpagesize()) < unlock_mstats)
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 2efaf19..e88a154 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -12,6 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/metadata/segtype.h"
 #include "lib/display/display.h"
@@ -363,8 +364,8 @@ static int _raid_target_status_compatible(const char *type)
 
 static void _raid_destroy(struct segment_type *segtype)
 {
-	dm_free((void *) segtype->dso);
-	dm_free(segtype);
+	free((void *) segtype->dso);
+	free(segtype);
 }
 
 #ifdef DEVMAPPER_SUPPORT
@@ -617,7 +618,7 @@ static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
 					       const char *dso,
 					       uint64_t monitored)
 {
-	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
+	struct segment_type *segtype = zalloc(sizeof(*segtype));
 
 	if (!segtype) {
 		log_error("Failed to allocate memory for %s segtype",
@@ -631,7 +632,7 @@ static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
 
 	/* Never monitor raid0 or raid0_meta LVs */
 	if (!segtype_is_any_raid0(segtype) &&
-	    dso && (dso = dm_strdup(dso))) {
+	    dso && (dso = strdup(dso))) {
 		segtype->dso = dso;
 		segtype->flags |= monitored;
 	}
@@ -675,7 +676,7 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 			break;
 		}
 
-	dm_free(dso);
+	free(dso);
 
 	return r;
 }
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 4d9cd7e..3c30b35 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/metadata/metadata.h"
 #include "lib/metadata/segtype.h"
@@ -224,8 +225,8 @@ static int _snap_modules_needed(struct dm_pool *mem,
 
 static void _snap_destroy(struct segment_type *segtype)
 {
-	dm_free((void *) segtype->dso);
-	dm_free(segtype);
+	free((void *) segtype->dso);
+	free(segtype);
 }
 
 static struct segtype_handler _snapshot_ops = {
@@ -253,7 +254,7 @@ struct segment_type *init_segtype(struct cmd_context *cmd);
 struct segment_type *init_segtype(struct cmd_context *cmd)
 #endif
 {
-	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
+	struct segment_type *segtype = zalloc(sizeof(*segtype));
 
 	if (!segtype)
 		return_NULL;
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index a9854a2..efed169 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/commands/toolcontext.h"
 #include "lib/metadata/segtype.h"
@@ -212,7 +213,7 @@ static int _striped_target_present(struct cmd_context *cmd,
 
 static void _striped_destroy(struct segment_type *segtype)
 {
-	dm_free(segtype);
+	free(segtype);
 }
 
 static struct segtype_handler _striped_ops = {
@@ -232,7 +233,7 @@ static struct segtype_handler _striped_ops = {
 
 static struct segment_type *_init_segtype(struct cmd_context *cmd, const char *name, uint64_t target)
 {
-	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
+	struct segment_type *segtype = zalloc(sizeof(*segtype));
 
 	if (!segtype)
 		return_NULL;
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 3c62008..d759b76 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -12,6 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/display/display.h"
 #include "lib/metadata/metadata.h"
@@ -745,8 +746,8 @@ static int _thin_target_present(struct cmd_context *cmd,
 
 static void _thin_destroy(struct segment_type *segtype)
 {
-	dm_free((void *) segtype->dso);
-	dm_free(segtype);
+	free((void *) segtype->dso);
+	free(segtype);
 }
 
 static struct segtype_handler _thin_pool_ops = {
@@ -803,7 +804,7 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 	unsigned i;
 
 	for (i = 0; i < DM_ARRAY_SIZE(reg_segtypes); ++i) {
-		segtype = dm_zalloc(sizeof(*segtype));
+		segtype = zalloc(sizeof(*segtype));
 
 		if (!segtype) {
 			log_error("Failed to allocate memory for %s segtype",
diff --git a/lib/unknown/unknown.c b/lib/unknown/unknown.c
index 7c2a54c..b7c06ac 100644
--- a/lib/unknown/unknown.c
+++ b/lib/unknown/unknown.c
@@ -12,6 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/commands/toolcontext.h"
 #include "lib/metadata/segtype.h"
@@ -49,8 +50,8 @@ static int _unknown_text_export(const struct lv_segment *seg, struct formatter *
 
 static void _unknown_destroy(struct segment_type *segtype)
 {
-	dm_free((void *) segtype->name);
-	dm_free(segtype);
+	free((void *) segtype->name);
+	free(segtype);
 }
 
 static struct segtype_handler _unknown_ops = {
@@ -61,7 +62,7 @@ static struct segtype_handler _unknown_ops = {
 
 struct segment_type *init_unknown_segtype(struct cmd_context *cmd, const char *name)
 {
-	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
+	struct segment_type *segtype = zalloc(sizeof(*segtype));
 
 	if (!segtype) {
 		log_error("Failed to allocate memory for unknown segtype");
@@ -69,9 +70,9 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd, const char *n
 	}
 
 	segtype->ops = &_unknown_ops;
-	if (!(segtype->name = dm_strdup(name))) {
+	if (!(segtype->name = strdup(name))) {
 		log_error("Failed to allocate name.");
-		dm_free(segtype);
+		free(segtype);
 		return NULL;
 	}
 
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index f1e4831..cb204fc 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -12,6 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/metadata/segtype.h"
 #include "lib/datastruct/str_list.h"
@@ -71,7 +72,7 @@ static int _zero_modules_needed(struct dm_pool *mem,
 
 static void _zero_destroy(struct segment_type *segtype)
 {
-	dm_free(segtype);
+	free(segtype);
 }
 
 static struct segtype_handler _zero_ops = {
@@ -86,7 +87,7 @@ static struct segtype_handler _zero_ops = {
 
 struct segment_type *init_zero_segtype(struct cmd_context *cmd)
 {
-	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
+	struct segment_type *segtype = zalloc(sizeof(*segtype));
 
 	if (!segtype)
 		return_NULL;
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index f8526d7..bdbdd3a 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -63,12 +63,12 @@ int buffer_append_vf(struct buffer *buf, va_list ap)
 		    !buffer_append(buf, append))
 			goto fail;
 
-		dm_free(append);
+		free(append);
 	}
 
 	return 1;
 fail:
-	dm_free(append);
+	free(append);
 	return 0;
 }
 
@@ -365,11 +365,11 @@ int buffer_realloc(struct buffer *buf, int needed)
 		alloc = needed;
 
 	buf->allocated += alloc;
-	new = dm_realloc(buf->mem, buf->allocated);
+	new = realloc(buf->mem, buf->allocated);
 	if (new)
 		buf->mem = new;
 	else { /* utter failure */
-		dm_free(buf->mem);
+		free(buf->mem);
 		buf->mem = 0;
 		buf->allocated = buf->used = 0;
 		return 0;
@@ -402,7 +402,7 @@ int buffer_line(const char *line, void *baton)
 
 void buffer_destroy(struct buffer *buf)
 {
-	dm_free(buf->mem);
+	free(buf->mem);
 	buffer_init(buf);
 }
 
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 28d7c04..53f4495 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -60,7 +60,7 @@ daemon_handle daemon_open(daemon_info i)
 	/* Check protocol and version matches */
 	h.protocol = daemon_reply_str(r, "protocol", NULL);
 	if (h.protocol)
-		h.protocol = dm_strdup(h.protocol); /* keep around */
+		h.protocol = strdup(h.protocol); /* keep around */
 	h.protocol_version = daemon_reply_int(r, "version", 0);
 
 	if (i.protocol && (!h.protocol || strcmp(h.protocol, i.protocol))) {
@@ -85,7 +85,7 @@ error:
 	if (r.cft)
 		daemon_reply_destroy(r);
 
-	dm_free((char *)h.protocol);
+	free((char *)h.protocol);
 	h.protocol = NULL;
 
 	return h;
@@ -181,7 +181,7 @@ void daemon_close(daemon_handle h)
 			log_sys_error("close", "daemon_close");
 	}
 
-	dm_free((char *)h.protocol);
+	free((char *)h.protocol);
 }
 
 daemon_request daemon_request_make(const char *id)
diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index 8c2a208..864f504 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -91,7 +91,7 @@ void daemon_logf(log_state *s, int type, const char *fmt, ...) {
 	va_start(ap, fmt);
 	if (dm_vasprintf(&buf, fmt, ap) >= 0) {
 		daemon_log(s, type, buf);
-		dm_free(buf);
+		free(buf);
 	} /* else return_0 */
 	va_end(ap);
 }
@@ -127,7 +127,7 @@ void daemon_log_multi(log_state *s, int type, const char *prefix, const char *ms
 	if (!_type_interesting(s, type))
 		return;
 
-	buf = dm_strdup(msg);
+	buf = strdup(msg);
 	pos = buf;
 
 	if (!buf)
@@ -140,7 +140,7 @@ void daemon_log_multi(log_state *s, int type, const char *prefix, const char *ms
 		_log_line(pos, &b);
 		pos = next ? next + 1 : 0;
 	}
-	dm_free(buf);
+	free(buf);
 }
 
 void daemon_log_enable(log_state *s, int outlet, int type, int enable)
@@ -184,7 +184,7 @@ int daemon_log_parse(log_state *s, int outlet, const char *types, int enable)
 	if (!types || !types[0])
 		return 1;
 
-	if (!(buf = dm_strdup(types)))
+	if (!(buf = strdup(types)))
 		return 0;
 
 	pos = buf;
@@ -193,13 +193,13 @@ int daemon_log_parse(log_state *s, int outlet, const char *types, int enable)
 		if (next)
 			*next = 0;
 		if (!_parse_one(s, outlet, pos, enable)) {
-			dm_free(buf);
+			free(buf);
 			return 0;
 		}
 		pos = next ? next + 1 : 0;
 	}
 
-	dm_free(buf);
+	free(buf);
 
 	return 1;
 }
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 4acb00e..78c8221 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -515,7 +515,7 @@ static int _handle_connect(daemon_state s)
 	 if (fcntl(client.socket_fd, F_SETFD, FD_CLOEXEC))
 		WARN(&s, "setting CLOEXEC on client socket fd %d failed", client.socket_fd);
 
-	if (!(ts = dm_malloc(sizeof(thread_state)))) {
+	if (!(ts = malloc(sizeof(thread_state)))) {
 		if (close(client.socket_fd))
 			perror("close");
 		ERROR(&s, "Failed to allocate thread state");
@@ -547,7 +547,7 @@ static void _reap(daemon_state s, int waiting)
 			if ((errno = pthread_join(ts->client.thread_id, &rv)))
 				ERROR(&s, "pthread_join failed: %s", strerror(errno));
 			last->next = ts->next;
-			dm_free(ts);
+			free(ts);
 		} else
 			last = ts;
 		ts = last->next;
diff --git a/tools/command.c b/tools/command.c
index 377d03f..e1391a1 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -51,9 +51,9 @@ do { \
 	printf(fmt "\n", ##args); \
 } while (0)
 
-#define dm_malloc malloc
-#define dm_strdup strdup
-#define dm_free free
+#define malloc malloc
+#define strdup strdup
+#define free free
 #define dm_snprintf snprintf
 
 static int dm_strncpy(char *dest, const char *src, size_t n)
@@ -746,7 +746,7 @@ static void _add_oo_definition_line(const char *name, const char *line)
 
 	oo = &_oo_lines[_oo_line_count++];
 
-	if (!(oo->name = dm_strdup(name))) {
+	if (!(oo->name = strdup(name))) {
 		log_error("Failer to duplicate name %s.", name);
 		return; /* FIXME: return code */
 	}
@@ -759,7 +759,7 @@ static void _add_oo_definition_line(const char *name, const char *line)
 	}
 
 	start = strchr(line, ':') + 2;
-	if (!(oo->line = dm_strdup(start))) {
+	if (!(oo->line = strdup(start))) {
 		log_error("Failer to duplicate line %s.", start);
 		return;
 	}
@@ -780,14 +780,14 @@ static void _append_oo_definition_line(const char *new_line)
 
 	/* +2 = 1 space between old and new + 1 terminating \0 */
 	len = strlen(old_line) + strlen(new_line) + 2;
-	line = dm_malloc(len);
+	line = malloc(len);
 	if (!line) {
 		log_error("Parsing command defs: no memory.");
 		return;
 	}
 
 	(void) dm_snprintf(line, len, "%s %s", old_line, new_line);
-	dm_free(oo->line);
+	free(oo->line);
 	oo->line = line;
 }
 
@@ -834,14 +834,14 @@ static void _include_optional_opt_args(struct cmd_context *cmdtool, struct comma
 		return;
 	}
 
-	if (!(line = dm_strdup(oo_line))) {
+	if (!(line = strdup(oo_line))) {
 		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 		return;
 	}
 
 	_split_line(line, &line_argc, line_argv, ' ');
 	__add_optional_opt_line(cmdtool, cmd, line_argc, line_argv);
-	dm_free(line);
+	free(line);
 }
 
 /*
@@ -1090,14 +1090,14 @@ static void _include_required_opt_args(struct cmd_context *cmdtool, struct comma
 		return;
 	}
 
-	if (!(line = dm_strdup(oo_line))) {
+	if (!(line = strdup(oo_line))) {
 		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 		return;
 	}
 
 	_split_line(line, &line_argc, line_argv, ' ');
 	_add_required_opt_line(cmdtool, cmd, line_argc, line_argv);
-	dm_free(line);
+	free(line);
 }
 
 /* Process what follows command_name, which are required opt/pos args. */
@@ -1568,8 +1568,8 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 
 	for (i = 0; i < _oo_line_count; i++) {
 		struct oo_line *oo = &_oo_lines[i];
-		dm_free(oo->name);
-		dm_free(oo->line);
+		free(oo->name);
+		free(oo->line);
 	}
 	memset(&_oo_lines, 0, sizeof(_oo_lines));
 	_oo_line_count = 0;
@@ -2298,7 +2298,7 @@ static void _print_val_man(struct command_name *cname, int opt_enum, int val_enu
 	}
 
 	if (strchr(str, '|')) {
-		line = dm_strdup(str);
+		line = strdup(str);
 		_split_line(line, &line_argc, line_argv, '|');
 		for (i = 0; i < line_argc; i++) {
 			if (i)
@@ -2308,7 +2308,7 @@ static void _print_val_man(struct command_name *cname, int opt_enum, int val_enu
 			else
 				printf("\\fB%s\\fP", line_argv[i]);
 		}
-		dm_free(line);
+		free(line);
 		return;
 	}
 
@@ -3318,7 +3318,7 @@ static int _include_description_file(char *name, char *des_file)
 		goto out_close;
 	}
 
-	if (!(buf = dm_malloc(statbuf.st_size + 1))) {
+	if (!(buf = malloc(statbuf.st_size + 1))) {
 		log_error("Failed to allocate buffer for description file %s.", des_file);
 		goto out_close;
 	}
@@ -3333,7 +3333,7 @@ static int _include_description_file(char *name, char *des_file)
 	r = 1;
 
 out_free:
-	dm_free(buf);
+	free(buf);
 out_close:
 	(void) close(fd);
 
@@ -3520,7 +3520,7 @@ int main(int argc, char *argv[])
 
 	memset(&commands, 0, sizeof(commands));
 
-	if (!(stdout_buf = dm_malloc(sz)))
+	if (!(stdout_buf = malloc(sz)))
 		log_error("Failed to allocate stdout buffer; carrying on with default buffering.");
 	else
 		setbuffer(stdout, stdout_buf, sz);
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 5486ed3..7c5a2b3 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -17,6 +17,7 @@
  */
 #include "tools/tool.h"
 
+#include "base/memory/zalloc.h"
 #include "device_mapper/misc/dm-logging.h"
 
 #include <ctype.h>
@@ -398,7 +399,7 @@ static int _parse_file(struct dm_task *dmt, const char *file)
 
 #ifndef HAVE_GETLINE
 	buffer_size = LINE_SIZE;
-	if (!(buffer = dm_malloc(buffer_size))) {
+	if (!(buffer = malloc(buffer_size))) {
 		log_error("Failed to malloc line buffer.");
 		return 0;
 	}
@@ -415,7 +416,7 @@ static int _parse_file(struct dm_task *dmt, const char *file)
 out:
 	memset(buffer, 0, buffer_size);
 #ifndef HAVE_GETLINE
-	dm_free(buffer);
+	free(buffer);
 #else
 	free(buffer);
 #endif
@@ -509,7 +510,7 @@ static char *_extract_uuid_prefix(const char *uuid, const int separator)
 		ptr = strchr(uuid, separator);
 
 	len = ptr ? ptr - uuid : 0;
-	if (!(uuid_prefix = dm_malloc(len + 1))) {
+	if (!(uuid_prefix = malloc(len + 1))) {
 		log_error("Failed to allocate memory to extract uuid prefix.");
 		return NULL;
 	}
@@ -527,14 +528,14 @@ static struct dm_split_name *_get_split_name(const char *uuid, const char *name,
 {
 	struct dm_split_name *split_name;
 
-	if (!(split_name = dm_malloc(sizeof(*split_name)))) {
+	if (!(split_name = malloc(sizeof(*split_name)))) {
 		log_error("Failed to allocate memory to split device name "
 			  "into components.");
 		return NULL;
 	}
 
 	if (!(split_name->subsystem = _extract_uuid_prefix(uuid, separator))) {
-		dm_free(split_name);
+		free(split_name);
 		return_NULL;
 	}
 
@@ -542,7 +543,7 @@ static struct dm_split_name *_get_split_name(const char *uuid, const char *name,
 	    split_name->lv_layer = (char *) "";
 
 	if (!strcmp(split_name->subsystem, "LVM") &&
-	    (!(split_name->vg_name = dm_strdup(name)) ||
+	    (!(split_name->vg_name = strdup(name)) ||
 	     !dm_split_lvm_name(NULL, NULL, &split_name->vg_name,
 				&split_name->lv_name, &split_name->lv_layer)))
 		log_error("Failed to allocate memory to split LVM name "
@@ -558,10 +559,10 @@ static void _destroy_split_name(struct dm_split_name *split_name)
 	 * of memory as vg_name so don't need to be freed separately.
 	 */
 	if (!strcmp(split_name->subsystem, "LVM"))
-		dm_free(split_name->vg_name);
+		free(split_name->vg_name);
 
-	dm_free(split_name->subsystem);
-	dm_free(split_name);
+	free(split_name->subsystem);
+	free(split_name);
 }
 
 /*
@@ -1220,7 +1221,7 @@ static char *_slurp_stdin(void)
 	size_t total = 0;
 	ssize_t n = 0;
 
-	if (!(buf = dm_malloc(bufsize))) {
+	if (!(buf = malloc(bufsize))) {
 		log_error("Buffer memory allocation failed.");
 		return NULL;
 	}
@@ -1233,7 +1234,7 @@ static char *_slurp_stdin(void)
 
 		if (n < 0) {
 			log_error("Read from stdin aborted: %s", strerror(errno));
-			dm_free(buf);
+			free(buf);
 			return NULL;
 		}
 
@@ -1244,7 +1245,7 @@ static char *_slurp_stdin(void)
 		pos += n;
 		if (total == bufsize - 1) {
 			bufsize *= 2;
-			if (!(buf = dm_realloc(buf, bufsize))) {
+			if (!(buf = realloc(buf, bufsize))) {
 				log_error("Buffer memory extension to %" PRIsize_t " bytes failed.", bufsize);
 				return NULL;
 			}
@@ -1396,7 +1397,7 @@ static int _create_concise(const struct command *cmd, int argc, char **argv)
 
 out:
 	if (!argc)
-		dm_free(concise_format);
+		free(concise_format);
 
 	return 0;
 }
@@ -1529,7 +1530,7 @@ static int _message(CMD_ARGS)
 	for (i = 0; i < argc; i++)
 		sz += strlen(argv[i]) + 1;
 
-	if (!(str = dm_zalloc(sz))) {
+	if (!(str = zalloc(sz))) {
 		log_error("Message string allocation failed.");
 		goto out;
 	}
@@ -1542,7 +1543,7 @@ static int _message(CMD_ARGS)
 
 	i = dm_task_set_message(dmt, str);
 
-	dm_free(str);
+	free(str);
 
 	if (!i)
 		goto_out;
@@ -3141,7 +3142,7 @@ static int _dm_mangled_name_disp(struct dm_report *rh,
 
 	if ((name = dm_task_get_name_mangled((const struct dm_task *) data))) {
 		r = dm_report_field_string(rh, field, (const char * const *) &name);
-		dm_free(name);
+		free(name);
 	}
 
 	return r;
@@ -3157,7 +3158,7 @@ static int _dm_unmangled_name_disp(struct dm_report *rh,
 
 	if ((name = dm_task_get_name_unmangled((const struct dm_task *) data))) {
 		r = dm_report_field_string(rh, field, (const char * const *) &name);
-		dm_free(name);
+		free(name);
 	}
 
 	return r;
@@ -3186,7 +3187,7 @@ static int _dm_mangled_uuid_disp(struct dm_report *rh,
 
 	if ((uuid = dm_task_get_uuid_mangled((const struct dm_task *) data))) {
 		r = dm_report_field_string(rh, field, (const char * const *) &uuid);
-		dm_free(uuid);
+		free(uuid);
 	}
 
 	return r;
@@ -3202,7 +3203,7 @@ static int _dm_unmangled_uuid_disp(struct dm_report *rh,
 
 	if ((uuid = dm_task_get_uuid_unmangled((const struct dm_task *) data))) {
 		r = dm_report_field_string(rh, field, (const char * const *) &uuid);
-		dm_free(uuid);
+		free(uuid);
 	}
 
 	return r;
@@ -4772,13 +4773,13 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 			char *tmpopts;
 			opt_fields = _string_args[OPTIONS_ARG] + 1;
 			len = strlen(options) + strlen(opt_fields) + 2;
-			if (!(tmpopts = dm_malloc(len))) {
+			if (!(tmpopts = malloc(len))) {
 				log_error("Failed to allocate option string.");
 				return 0;
 			}
 			if (dm_snprintf(tmpopts, len, "%s,%s",
 					options, opt_fields) < 0) {
-				dm_free(tmpopts);
+				free(tmpopts);
 				return 0;
 			}
 			options = tmpopts;
@@ -4845,7 +4846,7 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 
 out:
 	if (len)
-		dm_free(options);
+		free(options);
 
 	return r;
 }
@@ -4950,8 +4951,8 @@ static int _mangle(CMD_ARGS)
 	r = _do_rename(name, new_name, NULL);
 
 out:
-	dm_free(new_name);
-	dm_free(new_uuid);
+	free(new_name);
+	free(new_uuid);
 	dm_task_destroy(dmt);
 	return r;
 }
@@ -5120,7 +5121,7 @@ static int _stats_group_segments(struct dm_stats *dms, uint64_t *region_ids,
 	uint64_t group_id;
 	int r, i;
 
-	this_region = regions = dm_malloc(bufsize);
+	this_region = regions = malloc(bufsize);
 
 	if (!regions) {
 		log_error("Could not allocate memory for region_id table.");
@@ -5154,7 +5155,7 @@ static int _stats_group_segments(struct dm_stats *dms, uint64_t *region_ids,
 		log_error("Failed to create group for regions %s.", regions);
 
 bad:
-	dm_free(regions);
+	free(regions);
 	return r;
 }
 
@@ -5218,7 +5219,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 	if (!segments || (info.target_count == 1))
 		region_ids = &region_id;
 	else
-		region_ids = dm_malloc(info.target_count * sizeof(*region_ids));
+		region_ids = malloc(info.target_count * sizeof(*region_ids));
 
 	do {
 		uint64_t segment_start, segment_len;
@@ -5262,7 +5263,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 
 out:
 	if (region_ids != &region_id)
-		dm_free(region_ids);
+		free(region_ids);
 
 	dm_task_destroy(dmt);
 	dm_stats_destroy(dms);
@@ -5384,7 +5385,7 @@ static int _stats_create_file(CMD_ARGS)
 
 	if (bounds_str
 	    && !(bounds = dm_histogram_bounds_from_string(bounds_str))) {
-		dm_free(abspath);
+		free(abspath);
 		return_0;
 	}
 
@@ -5461,15 +5462,15 @@ static int _stats_create_file(CMD_ARGS)
 		while (*(++region) != DM_STATS_REGIONS_ALL);
 	}
 
-	dm_free(regions);
-	dm_free(abspath);
-	dm_free(bounds);
+	free(regions);
+	free(abspath);
+	free(bounds);
 	dm_stats_destroy(dms);
 	return 1;
 
 bad:
-	dm_free(abspath);
-	dm_free(bounds);
+	free(abspath);
+	free(bounds);
 
 	if ((fd > -1) && close(fd))
 		log_sys_debug("close", path);
@@ -6073,13 +6074,13 @@ out:
 	if (close(fd))
 		log_sys_debug("close", abspath);
 
-	dm_free(regions);
-	dm_free(abspath);
+	free(regions);
+	free(abspath);
 	dm_stats_destroy(dms);
 	return 1;
 
 bad:
-	dm_free(abspath);
+	free(abspath);
 
 	if ((fd > -1) && close(fd))
 		log_sys_debug("close", path);
@@ -6524,7 +6525,7 @@ static char *_parse_loop_device_name(const char *dev, const char *dev_dir)
 	char *buf;
 	char *device = NULL;
 
-	if (!(buf = dm_malloc(PATH_MAX)))
+	if (!(buf = malloc(PATH_MAX)))
 		return_NULL;
 
 	if (dev[0] == '/') {
@@ -6542,7 +6543,7 @@ static char *_parse_loop_device_name(const char *dev, const char *dev_dir)
 
 		if (!dm_strncpy(buf, strrchr(device, '/') + 1, PATH_MAX))
 			goto_bad;
-		dm_free(device);
+		free(device);
 	} else {
 		/* check for device number */
 		if (strncmp(dev, "loop", sizeof("loop") - 1))
@@ -6554,8 +6555,8 @@ static char *_parse_loop_device_name(const char *dev, const char *dev_dir)
 
 	return buf;
 bad:
-	dm_free(device);
-	dm_free(buf);
+	free(device);
+	free(buf);
 
 	return NULL;
 }
@@ -6704,7 +6705,7 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 	if (*argcp != 2) {
 		log_error("%s: Too few arguments.", base);
 		_usage(stderr);
-		dm_free(device_name);
+		free(device_name);
 		return 0;
 	}
 
@@ -6713,15 +6714,15 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 		log_error("%s: Could not parse loop file name %s.",
 			  base, (*argvp)[1]);
 		_usage(stderr);
-		dm_free(device_name);
+		free(device_name);
 		return 0;
 	}
 
-	_table = dm_malloc(LOOP_TABLE_SIZE);
+	_table = malloc(LOOP_TABLE_SIZE);
 	if (!_table ||
 	    !_loop_table(_table, (size_t) LOOP_TABLE_SIZE, loop_file, device_name, offset)) {
 		log_error("Could not build device-mapper table for %s.", (*argvp)[0]);
-		dm_free(device_name);
+		free(device_name);
 		return 0;
 	}
 	_switches[TABLE_ARG]++;
@@ -7186,7 +7187,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[SHOWKEYS_ARG]++;
 		if (ind == TABLE_ARG) {
 			_switches[TABLE_ARG]++;
-			if (!(_table = dm_strdup(optarg))) {
+			if (!(_table = strdup(optarg))) {
 				log_error("Could not allocate memory for table string.");
 				return 0;
 			}
@@ -7450,7 +7451,7 @@ out:
 	if (_dtree)
 		dm_tree_free(_dtree);
 
-	dm_free(_table);
+	free(_table);
 
 	if (_initial_timestamp)
 		dm_timestamp_destroy(_initial_timestamp);
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 9f94b5c..b787d09 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -60,7 +60,7 @@ int lvm2_run(void *handle, const char *cmdline)
 
 	cmd->argv = argv;
 
-	if (!(cmdcopy = dm_strdup(cmdline))) {
+	if (!(cmdcopy = strdup(cmdline))) {
 		log_error("Cmdline copy failed.");
 		ret = ECMD_FAILED;
 		goto out;
@@ -91,7 +91,7 @@ int lvm2_run(void *handle, const char *cmdline)
 		ret = lvm_run_command(cmd, argc, argv);
 
       out:
-	dm_free(cmdcopy);
+	free(cmdcopy);
 
 	if (oneoff)
 		lvm2_exit(handle);
diff --git a/tools/pvck.c b/tools/pvck.c
index 9030496..027df6d 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -13,6 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "tools.h"
 
 int pvck(struct cmd_context *cmd, int argc, char **argv)
@@ -41,7 +42,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 			continue;
 		}
 
-		if (!(devl = dm_zalloc(sizeof(*devl))))
+		if (!(devl = zalloc(sizeof(*devl))))
 			continue;
 
 		devl->dev = dev;
diff --git a/tools/toollib.c b/tools/toollib.c
index a4dddd3..7da1703 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1482,7 +1482,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 					log_error("No physical volume label read from %s.", argv[opt]);
 					ret_max = ECMD_FAILED;
 				} else {
-					if (!(devl = dm_malloc(sizeof(*devl))))
+					if (!(devl = malloc(sizeof(*devl))))
 						return_0;
 					devl->dev = dev;
 					dm_list_add(&process_duplicates, &devl->list);
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 814ed1d..7d061d5 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -21,14 +21,14 @@ static char *_expand_filename(const char *template, const char *vg_name,
 	char *filename;
 
 	if (security_level()) {
-		if (!(filename = dm_strdup(template))) {
+		if (!(filename = strdup(template))) {
 			log_error("Failed to allocate filename.");
 			return NULL;
 		}
 		goto out;
 	}
 
-	if (!(filename = dm_malloc(PATH_MAX))) {
+	if (!(filename = malloc(PATH_MAX))) {
 		log_error("Failed to allocate filename.");
 		return NULL;
 	}
@@ -36,17 +36,17 @@ static char *_expand_filename(const char *template, const char *vg_name,
 	if (dm_snprintf(filename, PATH_MAX, template, vg_name) < 0) {
 		log_error("Error processing filename template %s",
 			   template);
-		dm_free(filename);
+		free(filename);
 		return NULL;
 	}
 	if (*last_filename && !strncmp(*last_filename, filename, PATH_MAX)) {
 		log_error("VGs must be backed up into different files. "
 			  "Use %%s in filename for VG name.");
-		dm_free(filename);
+		free(filename);
 		return NULL;
 	}
 out:
-	dm_free(*last_filename);
+	free(*last_filename);
 	*last_filename = filename;
 
 	return filename;
@@ -102,7 +102,7 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 	ret = process_each_vg(cmd, argc, argv, NULL, NULL, READ_ALLOW_INCONSISTENT, 0,
 			      handle, &_vg_backup_single);
 
-	dm_free(last_filename);
+	free(last_filename);
 
 	init_pvmove(0);
 


