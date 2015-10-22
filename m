From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:49 +0000 (UTC)
Subject: master - dmeventd: wake up timer when setting new timeout
Message-ID: <20151022213349.E620B60B67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=941c6354dbf783da17851be7e38f243334a4acd6
Commit:        941c6354dbf783da17851be7e38f243334a4acd6
Parent:        02eb000f5145aa60578b4591053bff9a797e64cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 12:37:18 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:34:29 2015 +0200

dmeventd: wake up timer when setting new timeout

---
 daemons/dmeventd/dmeventd.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 885aa9d..bbdee82 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1274,11 +1274,20 @@ static int _set_timeout(struct message_data *message_data)
 	struct thread_status *thread;
 
 	_lock_mutex();
-	if ((thread = _lookup_thread_status(message_data)))
-		thread->timeout = message_data->timeout_secs;
+	thread = _lookup_thread_status(message_data);
 	_unlock_mutex();
 
-	return thread ? 0 : -ENODEV;
+	if (!thread)
+		return -ENODEV;
+
+	/* Lets reprogram timer */
+	pthread_mutex_lock(&_timeout_mutex);
+	thread->timeout = message_data->timeout_secs;
+	thread->next_time = 0;
+	pthread_cond_signal(&_timeout_cond);
+	pthread_mutex_unlock(&_timeout_mutex);
+
+	return 0;
 }
 
 static int _get_timeout(struct message_data *message_data)


