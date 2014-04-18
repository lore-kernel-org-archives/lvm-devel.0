From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:27 +0000 (UTC)
Subject: master - cleanup: add some comment indents...
Message-ID: <20140418145527.5846860F48@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6448428d05f53a478a892b9792d22407d10c1464
Commit:        6448428d05f53a478a892b9792d22407d10c1464
Parent:        91eb8927fd83a8ddff7c4007c2421386946437e0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 18 11:27:07 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:51 2014 +0200

cleanup: add some comment indents...

Just cleanup things
---
 daemons/dmeventd/dmeventd.c           |   20 ++++++++++----------
 daemons/dmeventd/libdevmapper-event.c |   13 ++++++-------
 2 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index e1235dd..4f059b9 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -607,6 +607,7 @@ static void _unregister_for_timeout(struct thread_status *thread)
 		dm_list_del(&thread->timeout_list);
 		dm_list_init(&thread->timeout_list);
 		if (dm_list_empty(&_timeout_registry))
+			/* No more work -> wakeup to finish quickly */
 			pthread_cond_signal(&_timeout_cond);
 	}
 	pthread_mutex_unlock(&_timeout_mutex);
@@ -912,11 +913,11 @@ static struct dso_data *_lookup_dso(struct message_data *data)
 	struct dso_data *dso_data, *ret = NULL;
 
 	dm_list_iterate_items(dso_data, &_dso_registry)
-	    if (!strcmp(data->dso_name, dso_data->dso_name)) {
-		_lib_get(dso_data);
-		ret = dso_data;
-		break;
-	}
+		if (!strcmp(data->dso_name, dso_data->dso_name)) {
+			_lib_get(dso_data);
+			ret = dso_data;
+			break;
+		}
 
 	return ret;
 }
@@ -944,7 +945,7 @@ static int lookup_symbols(void *dl, struct dso_data *data)
 static struct dso_data *_load_dso(struct message_data *data)
 {
 	void *dl;
-	struct dso_data *ret = NULL;
+	struct dso_data *ret;
 
 	if (!(dl = dlopen(data->dso_name, RTLD_NOW))) {
 		const char *dlerr = dlerror();
@@ -1251,9 +1252,8 @@ static int _get_timeout(struct message_data *message_data)
 
 	_lock_mutex();
 	if ((thread = _lookup_thread_status(message_data))) {
-		msg->size =
-		    dm_asprintf(&(msg->data), "%s %" PRIu32, message_data->id,
-				thread->timeout);
+		msg->size = dm_asprintf(&(msg->data), "%s %" PRIu32,
+					message_data->id, thread->timeout);
 	} else {
 		msg->data = NULL;
 		msg->size = 0;
@@ -1971,7 +1971,7 @@ static void restart(void)
 		}
 		message += strlen(message) + 1;
 	}
-	_initial_registrations[count] = 0;
+	_initial_registrations[count] = NULL;
 
 	if (version >= 2) {
 		if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_GET_PARAMETERS, "-", "-", 0, 0)) {
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index b8a0b90..51c925f 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -283,10 +283,9 @@ static int _daemon_read(struct dm_event_fifos *fifos,
 static int _daemon_write(struct dm_event_fifos *fifos,
 			 struct dm_event_daemon_message *msg)
 {
-	unsigned bytes = 0;
-	int ret = 0;
+	int ret;
 	fd_set fds;
-
+	size_t bytes = 0;
 	size_t size = 2 * sizeof(uint32_t) + msg->size;
 	uint32_t *header = alloca(size);
 	char *buf = (char *)header;
@@ -308,7 +307,7 @@ static int _daemon_write(struct dm_event_fifos *fifos,
 		}
 		if (ret == 0)
 			break;
-		ret = read(fifos->server, drainbuf, 127);
+		ret = read(fifos->server, drainbuf, sizeof(drainbuf));
 	}
 
 	while (bytes < size) {
@@ -609,7 +608,7 @@ int dm_event_register_handler(const struct dm_event_handler *dmevh)
 	int ret = 1, err;
 	const char *uuid;
 	struct dm_task *dmt;
-	struct dm_event_daemon_message msg = { 0, 0, NULL };
+	struct dm_event_daemon_message msg = { 0 };
 
 	if (!(dmt = _get_device_info(dmevh)))
 		return_0;
@@ -643,7 +642,7 @@ int dm_event_unregister_handler(const struct dm_event_handler *dmevh)
 	int ret = 1, err;
 	const char *uuid;
 	struct dm_task *dmt;
-	struct dm_event_daemon_message msg = { 0, 0, NULL };
+	struct dm_event_daemon_message msg = { 0 };
 
 	if (!(dmt = _get_device_info(dmevh)))
 		return_0;
@@ -810,7 +809,7 @@ int dm_event_get_registered_device(struct dm_event_handler *dmevh, int next)
 
 int dm_event_get_version(struct dm_event_fifos *fifos, int *version) {
 	char *p;
-	struct dm_event_daemon_message msg = { 0, 0, NULL };
+	struct dm_event_daemon_message msg = { 0 };
 
 	if (daemon_talk(fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0))
 		return 0;


