From: Lidong Zhong <lzhong@suse.com>
Date: Tue, 27 Oct 2015 15:36:57 +0800
Subject: [PATCH] dmeventd: compare dso name with "-"
Message-ID: <1445931417-9667-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If the dso name is not set in client, then it will be replaced by "-".
So the server should compare the dso name with "-" to decide whether
it is set.

Signed-off-by: Lidong Zhong <lzhong@suse.com>
---
Hi list,

Currently I notice that there are a lot of patches for dmeventd. It may be
a good chance to mention the problem I met before again.

344 int daemon_talk(struct dm_event_fifos *fifos,
345         struct dm_event_daemon_message *msg, int cmd,
346         const char *dso_name, const char *dev_name,
347         enum dm_event_mask evmask, uint32_t timeout)
348 {
349     int msg_size;
350     memset(msg, 0, sizeof(*msg));
351 
352     /*
353      * Set command and pack the arguments
354      * into ASCII message string.
355      */
356     if ((msg_size =
357          ((cmd == DM_EVENT_CMD_HELLO) ?
358           dm_asprintf(&(msg->data), "%d:%d HELLO", getpid(), _sequence_nr) :
359           dm_asprintf(&(msg->data), "%d:%d %s %s %u %" PRIu32,
360               getpid(), _sequence_nr,
361               dso_name ? : "-", dev_name ? : "-", evmask, timeout)))
362         < 0) {

We can see that it will set the dso_name to "-" if the client doesn't give. So
the server will never get the variable as empty. And it is a problem for dmevent_tool.
We can fix it with the following patch.

Regards,
Lidong



 daemons/dmeventd/dmeventd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index d6accbf..a16f198 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1213,12 +1213,12 @@ static int _want_registered_device(char *dso_name, char *device_uuid,
 				   struct thread_status *thread)
 {
 	/* If DSO names and device paths are equal. */
-	if (dso_name && device_uuid)
+	if (strcmp(dso_name, "-") && device_uuid)
 		return !strcmp(dso_name, thread->dso_data->dso_name) &&
 		    !strcmp(device_uuid, thread->device.uuid);
 
 	/* If DSO names are equal. */
-	if (dso_name)
+	if (strcmp(dso_name, "-"))
 		return !strcmp(dso_name, thread->dso_data->dso_name);
 
 	/* If device paths are equal. */
-- 
1.8.1.4


