From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:34:04 +0000 (UTC)
Subject: master - dmeventd: snapshot plugin unmonitor
Message-ID: <20151022213404.AF95C6057E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aeec62ad1987a5ec59b782f3377d6ae1693e1eab
Commit:        aeec62ad1987a5ec59b782f3377d6ae1693e1eab
Parent:        12aa56d29867b962257d7d2789a661a22c649347
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 15:36:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:41:12 2015 +0200

dmeventd: snapshot plugin unmonitor

Send signal to itself to mark plugin as 'finished' as
the watching rule is no longer usable.
---
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index d9bef5c..7962e96 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -18,6 +18,7 @@
 
 #include <sys/wait.h>
 #include <stdarg.h>
+#include <pthread.h>
 
 /* First warning when snapshot is 80% full. */
 #define WARNING_THRESH	(DM_PERCENT_1 * 80)
@@ -203,6 +204,15 @@ void process_event(struct dm_task *dmt,
 		/* Maybe configurable ? */
 		_remove(dm_task_get_uuid(dmt));
 #endif
+		pthread_kill(pthread_self(), SIGALRM);
+		goto out;
+	}
+
+	if (length <= (status->used_sectors - status->metadata_sectors)) {
+		/* TODO eventually recognize earlier when room is enough */
+		log_info("Dropping monitoring of fully provisioned snapshot %s.",
+			 device);
+		pthread_kill(pthread_self(), SIGALRM);
 		goto out;
 	}
 


