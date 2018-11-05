From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 5 Nov 2018 11:27:17 -0500
Subject: master - cov: trace failing pthread_kill
Message-ID: <201811051627.wA5GRHcn005367@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0d934e730ec62d16c4f47dbb0d8e97ed16910786
Commit:        0d934e730ec62d16c4f47dbb0d8e97ed16910786
Parent:        813347cf84617a946d9184f44c5fbd275bb41766
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 2 22:11:18 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 3 16:10:32 2018 +0100

cov: trace failing pthread_kill

---
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 6ffa9fc..9e9053c 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -175,6 +175,7 @@ void process_event(struct dm_task *dmt,
 	const char *device = dm_task_get_name(dmt);
 	int percent;
 	struct dm_info info;
+	int ret;
 
 	/* No longer monitoring, waiting for remove */
 	if (!state->percent_check)
@@ -205,7 +206,8 @@ void process_event(struct dm_task *dmt,
 		/* Maybe configurable ? */
 		_remove(dm_task_get_uuid(dmt));
 #endif
-		pthread_kill(pthread_self(), SIGALRM);
+		if ((ret = pthread_kill(pthread_self(), SIGALRM)) && (ret != ESRCH))
+			log_sys_error("pthread_kill", "self");
 		goto out;
 	}
 
@@ -213,7 +215,8 @@ void process_event(struct dm_task *dmt,
 		/* TODO eventually recognize earlier when room is enough */
 		log_info("Dropping monitoring of fully provisioned snapshot %s.",
 			 device);
-		pthread_kill(pthread_self(), SIGALRM);
+		if ((ret = pthread_kill(pthread_self(), SIGALRM)) && (ret != ESRCH))
+			log_sys_error("pthread_kill", "self");
 		goto out;
 	}
 


