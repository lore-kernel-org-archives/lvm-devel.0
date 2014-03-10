From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:00 +0000 (UTC)
Subject: master - dmeventd: wakeup timeout thread earlier
Message-ID: <20140310112700.91D9A60CD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a6c0e2425432cf6aa690709a985f6208f930ef6
Commit:        7a6c0e2425432cf6aa690709a985f6208f930ef6
Parent:        2a9b62c7f9948238f4ba8f60546b2fb1ae44c2c6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 10 09:40:32 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:07 2014 +0100

dmeventd: wakeup timeout thread earlier

When the last entry in the timeout queue is unregistered,
wakeup sleeping condition, so the thread is deleted earlier.
So the thread resource is release earlier.

Also when monitored with tools like valgrind this eliminites reported
leak.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e470cd2..4f67bc3 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.85 - 
 ===================================
+  Stop timeout thread immediately when the last worker thread is finished.
   Fix dmeventd logging with parallel wait event processing.
   Reuse _node_send_messages() for validation of transaction_id in preload.
   Transaction_id could be lower by one only when messages are prepared.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index f27444c..621ae36 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -614,6 +614,8 @@ static void _unregister_for_timeout(struct thread_status *thread)
 	if (!dm_list_empty(&thread->timeout_list)) {
 		dm_list_del(&thread->timeout_list);
 		dm_list_init(&thread->timeout_list);
+		if (dm_list_empty(&_timeout_registry))
+			pthread_cond_signal(&_timeout_cond);
 	}
 	pthread_mutex_unlock(&_timeout_mutex);
 }


