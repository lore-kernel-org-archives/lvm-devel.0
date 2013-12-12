From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Dec 2013 12:43:43 +0000 (UTC)
Subject: master - dmeventd: prevent busy looping on CPU
Message-ID: <20131212124343.233B16024C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c5feaed3be5c26f5782e4e891ba99862f1e968f
Commit:        7c5feaed3be5c26f5782e4e891ba99862f1e968f
Parent:        b87c148499c6a9dd8c6d34d9991350e203d37fe9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 22 17:00:25 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 12 13:40:55 2013 +0100

dmeventd: prevent busy looping on CPU

Use usleep when looping on DM_WAIT_RETRY.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 1e30d2a..effd0cc 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.84 -
 ====================================
+  Avoid busy looping on CPU when dmeventd reads event DM_WAIT_RETRY.
   Ensure global mutex is being hold when working with dmeventd thread.
   Drop taking timeout mutex for un/registering dmeventd monitor.
   Allow section names in config file data to be quoted strings.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index baa4fc3..179775a 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -796,8 +796,10 @@ static void *_monitor_thread(void *arg)
 		thread->current_events = 0;
 
 		wait_error = _event_wait(thread, &task);
-		if (wait_error == DM_WAIT_RETRY)
+		if (wait_error == DM_WAIT_RETRY) {
+			usleep(100); /* avoid busy loop */
 			continue;
+		}
 
 		if (wait_error == DM_WAIT_FATAL)
 			break;


