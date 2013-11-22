From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:02 +0000 (UTC)
Subject: master - dmeventd: move format text to printf
Message-ID: <20131122200902.EEBC061133@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6fa95d17ee85ffd77d4dc90b23cdd024f65c279c
Commit:        6fa95d17ee85ffd77d4dc90b23cdd024f65c279c
Parent:        069fa6c49d85f677320ccb1965ef2e59b6829303
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 12:54:59 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:51 2013 +0100

dmeventd: move format text to printf

Instead of passing argument with format string to printf(),
put the string as arg directly.
Also move there remains args to make the code shorter.
---
 WHATS_NEW_DM                          |    1 +
 daemons/dmeventd/dmeventd.c           |   12 +++++-------
 daemons/dmeventd/libdevmapper-event.c |   16 ++++++++--------
 3 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 24d53af..564419f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.84 -
 ====================================
+  Move printf format string directly into dm_asprintf args list.
   Catch invalid use of string sort values when reporting numerical fields.
 
 Version 1.02.83 - 13th November 2013
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index bdaf552..e9fc59b 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1110,20 +1110,18 @@ static int _unregister_for_event(struct message_data *message_data)
 static int _registered_device(struct message_data *message_data,
 			     struct thread_status *thread)
 {
-	struct dm_event_daemon_message *msg = message_data->msg;
-
-	const char *fmt = "%s %s %s %u";
-	const char *id = message_data->id;
-	const char *dso = thread->dso_data->dso_name;
-	const char *dev = thread->device.uuid;
 	int r;
+	struct dm_event_daemon_message *msg = message_data->msg;
 	unsigned events = ((thread->status == DM_THREAD_RUNNING) &&
 			   thread->events) ? thread->events :
 			    thread->events | DM_EVENT_REGISTRATION_PENDING;
 
 	dm_free(msg->data);
 
-	if ((r = dm_asprintf(&(msg->data), fmt, id, dso, dev, events)) < 0) {
+	if ((r = dm_asprintf(&(msg->data), "%s %s %s %u",
+			     message_data->id,
+			     thread->dso_data->dso_name,
+			     thread->device.uuid, events)) < 0) {
 		msg->size = 0;
 		return -ENOMEM;
 	}
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 72f0f92..92e9c1d 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -345,9 +345,6 @@ int daemon_talk(struct dm_event_fifos *fifos,
 		const char *dso_name, const char *dev_name,
 		enum dm_event_mask evmask, uint32_t timeout)
 {
-	const char *dso = dso_name ? dso_name : "-";
-	const char *dev = dev_name ? dev_name : "-";
-	const char *fmt = "%d:%d %s %s %u %" PRIu32;
 	int msg_size;
 	memset(msg, 0, sizeof(*msg));
 
@@ -355,14 +352,17 @@ int daemon_talk(struct dm_event_fifos *fifos,
 	 * Set command and pack the arguments
 	 * into ASCII message string.
 	 */
-	msg->cmd = cmd;
-	if (cmd == DM_EVENT_CMD_HELLO)
-		fmt = "%d:%d HELLO";
-	if ((msg_size = dm_asprintf(&(msg->data), fmt, getpid(), _sequence_nr,
-				    dso, dev, evmask, timeout)) < 0) {
+	if ((msg_size =
+	     ((cmd == DM_EVENT_CMD_HELLO) ?
+	      dm_asprintf(&(msg->data), "%d:%d HELLO", getpid(), _sequence_nr) :
+	      dm_asprintf(&(msg->data), "%d:%d %s %s %u %" PRIu32,
+			  getpid(), _sequence_nr,
+			  dso_name ? : "-", dev_name ? : "-", evmask, timeout)))
+	    < 0) {
 		log_error("_daemon_talk: message allocation failed");
 		return -ENOMEM;
 	}
+	msg->cmd = cmd;
 	msg->size = msg_size;
 
 	/*


