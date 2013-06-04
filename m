From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:24:19 +0000 (UTC)
Subject: dev-mornfall-activate - dmeventd: convert union to struct members
Message-ID: <20130604192419.C058E6119A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5ea466673af377328a7ed50d6fb24e66a478b44b
Commit:        5ea466673af377328a7ed50d6fb24e66a478b44b
Parent:        45f396f2a075054f4e047abdef5eafffca72a281
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 19 20:44:20 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:01:35 2013 +0200

dmeventd: convert union to struct members

Sharing char* with field has a problem in error path,
when we allocate event, but fail to allocate timeout string.
Instead of creating complicated error paths to resolve
it individually stop using unions, and let the resource
to be released in a simple _free_message().
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |   54 ++++++++++++++++---------------------------
 2 files changed, 21 insertions(+), 34 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index eff6bd6..6e45a4c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Update dmevent structure message_data to simplify/fix error path handling.
   Validate passed params to dm_get_status_raid/thin/thin_pool(). 
   Fix 'dmsetup splitname -o' to not fail if used without '-c' switch (1.02.68).
   Add dm_config_write_{node_out/one_node_out} for enhanced config output.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 06c0c92..35a2b25 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -167,14 +167,10 @@ struct message_data {
 	char *id;
 	char *dso_name;		/* Name of DSO. */
 	char *device_uuid;	/* Mapped device path. */
-	union {
-		char *str;	/* Events string as fetched from message. */
-		enum dm_event_mask field;	/* Events bitfield. */
-	} events;
-	union {
-		char *str;
-		uint32_t secs;
-	} timeout;
+	char *events_str;	/* Events string as fetched from message. */
+	enum dm_event_mask events_field;	/* Events bitfield. */
+	char *timeout_str;
+	uint32_t timeout_secs;
 	struct dm_event_daemon_message *msg;	/* Pointer to message buffer. */
 };
 
@@ -235,8 +231,8 @@ static struct thread_status *_alloc_thread_status(struct message_data *data,
 	ret->device.name = NULL;
 	ret->device.major = ret->device.minor = 0;
 	ret->dso_data = dso_data;
-	ret->events = data->events.field;
-	ret->timeout = data->timeout.secs;
+	ret->events = data->events_field;
+	ret->timeout = data->timeout_secs;
 	dm_list_init(&ret->timeout_list);
 
 	return ret;
@@ -325,9 +321,9 @@ static void _free_message(struct message_data *message_data)
 {
 	dm_free(message_data->id);
 	dm_free(message_data->dso_name);
-
 	dm_free(message_data->device_uuid);
-
+	dm_free(message_data->events_str);
+	dm_free(message_data->timeout_str);
 }
 
 /* Parse a register message from the client. */
@@ -347,25 +343,15 @@ static int _parse_message(struct message_data *message_data)
 	if (_fetch_string(&message_data->id, &p, ' ') &&
 	    _fetch_string(&message_data->dso_name, &p, ' ') &&
 	    _fetch_string(&message_data->device_uuid, &p, ' ') &&
-	    _fetch_string(&message_data->events.str, &p, ' ') &&
-	    _fetch_string(&message_data->timeout.str, &p, ' ')) {
-		if (message_data->events.str) {
-			enum dm_event_mask i = atoi(message_data->events.str);
-
-			/*
-			 * Free string representaion of events.
-			 * Not needed an more.
-			 */
-			dm_free(message_data->events.str);
-			message_data->events.field = i;
-		}
-		if (message_data->timeout.str) {
-			uint32_t secs = atoi(message_data->timeout.str);
-			dm_free(message_data->timeout.str);
-			message_data->timeout.secs = secs ? secs :
-			    DM_EVENT_DEFAULT_TIMEOUT;
-		}
-
+	    _fetch_string(&message_data->events_str, &p, ' ') &&
+	    _fetch_string(&message_data->timeout_str, &p, ' ')) {
+		if (message_data->events_str)
+			message_data->events_field =
+				atoi(message_data->events_str);
+		if (message_data->timeout_str)
+			message_data->timeout_secs =
+				atoi(message_data->timeout_str)
+				? : DM_EVENT_DEFAULT_TIMEOUT;
 		ret = 1;
 	}
 
@@ -1025,7 +1011,7 @@ static int _register_for_event(struct message_data *message_data)
 	}
 
 	/* Or event # into events bitfield. */
-	thread->events |= message_data->events.field;
+	thread->events |= message_data->events_field;
 
     outth:
 	_unlock_mutex();
@@ -1070,7 +1056,7 @@ static int _unregister_for_event(struct message_data *message_data)
 		return 0;
 	}
 
-	thread->events &= ~message_data->events.field;
+	thread->events &= ~message_data->events_field;
 
 	if (!(thread->events & DM_EVENT_TIMEOUT))
 		_unregister_for_timeout(thread);
@@ -1208,7 +1194,7 @@ static int _set_timeout(struct message_data *message_data)
 
 	_lock_mutex();
 	if ((thread = _lookup_thread_status(message_data)))
-		thread->timeout = message_data->timeout.secs;
+		thread->timeout = message_data->timeout_secs;
 	_unlock_mutex();
 
 	return thread ? 0 : -ENODEV;


