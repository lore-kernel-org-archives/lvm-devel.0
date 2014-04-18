From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:00 +0000 (UTC)
Subject: master - dmeventd: check for list size within lock
Message-ID: <20140418145500.4C09A60758@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08e7de986cf2b4f8a05d6f1a7e996e4f298bfd1a
Commit:        08e7de986cf2b4f8a05d6f1a7e996e4f298bfd1a
Parent:        0e05e1cf6cb9323cc48ff38adc781f22a3c7d172
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 18 13:29:38 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:48 2014 +0200

dmeventd: check for list size within lock

Move check for _thread_registry list size behind mutex.
Use alloca() instead of buffer[count] (they are the same anyway)
---
 daemons/dmeventd/dmeventd.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index af7a2e4..906f731 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -464,20 +464,17 @@ static int _get_status(struct message_data *message_data)
 {
 	struct dm_event_daemon_message *msg = message_data->msg;
 	struct thread_status *thread;
-	int i, j;
-	int ret = -1;
-	int count = dm_list_size(&_thread_registry);
+	int i = 0, j;
+	int ret = -ENOMEM;
+	int count;
 	int size = 0, current;
-	char *buffers[count];
+	size_t len;
+	char **buffers;
 	char *message;
 
-	dm_free(msg->data);
-
-	for (i = 0; i < count; ++i)
-		buffers[i] = NULL;
-
-	i = 0;
 	_lock_mutex();
+	count = dm_list_size(&_thread_registry);
+	buffers = alloca(sizeof(char*) * count);
 	dm_list_iterate_items(thread, &_thread_registry) {
 		if ((current = dm_asprintf(buffers + i, "0:%d %s %s %u %" PRIu32 ";",
 					   i, thread->dso_data->dso_name,


