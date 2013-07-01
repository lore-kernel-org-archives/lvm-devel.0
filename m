From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  1 Jul 2013 21:13:21 +0000 (UTC)
Subject: master - cleanup: more dmeventd code cleanup
Message-ID: <20130701211321.70EA4610D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2fb116e71eabfc33dfa72717f9c3c40bb6966983
Commit:        2fb116e71eabfc33dfa72717f9c3c40bb6966983
Parent:        fd399d52a920b2b2974e53f2f36524fa7431033f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 30 16:04:14 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 1 23:06:41 2013 +0200

cleanup: more dmeventd code cleanup

---
 daemons/dmeventd/dmeventd.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 9c5757e..92c93d9 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -704,9 +704,10 @@ static void _monitor_unregister(void *arg)
 	if (!_do_unregister_device(thread))
 		syslog(LOG_ERR, "%s: %s unregister failed\n", __func__,
 		       thread->device.name);
-	if (thread->current_task)
+	if (thread->current_task) {
 		dm_task_destroy(thread->current_task);
-	thread->current_task = NULL;
+		thread->current_task = NULL;
+	}
 
 	_lock_mutex();
 	if (thread->events & DM_EVENT_TIMEOUT) {
@@ -1091,9 +1092,9 @@ static int _registered_device(struct message_data *message_data,
 	const char *dso = thread->dso_data->dso_name;
 	const char *dev = thread->device.uuid;
 	int r;
-	unsigned events = ((thread->status == DM_THREAD_RUNNING)
-			   && (thread->events)) ? thread->events : thread->
-	    events | DM_EVENT_REGISTRATION_PENDING;
+	unsigned events = ((thread->status == DM_THREAD_RUNNING) &&
+			   thread->events) ? thread->events :
+			    thread->events | DM_EVENT_REGISTRATION_PENDING;
 
 	dm_free(msg->data);
 
@@ -1499,17 +1500,16 @@ static void _process_request(struct dm_event_fifos *fifos)
 
 static void _process_initial_registrations(void)
 {
-	int i = 0;
+	int i;
 	char *reg;
-	struct dm_event_daemon_message msg = { 0, 0, NULL };
+	struct dm_event_daemon_message msg = { 0 };
 
-	while ((reg = _initial_registrations[i])) {
+	for (i = 0; (reg = _initial_registrations[i]); ++i) {
 		msg.cmd = DM_EVENT_CMD_REGISTER_FOR_EVENT;
 		if ((msg.size = strlen(reg))) {
 			msg.data = reg;
 			_do_process_request(&msg);
 		}
-		++ i;
 	}
 }
 


