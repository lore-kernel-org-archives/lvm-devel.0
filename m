From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 29 Mar 2010 17:27:19 +0200
Subject: [PATCH 1/7] Remove mlockall() form dmeventd
In-Reply-To: <cover.1269876115.git.zkabelac@redhat.com>
References: <cover.1269876115.git.zkabelac@redhat.com>
Message-ID: <3aefc9f17bcc5a2d4591fb37af237ebb1282e525.1269876115.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As the header file <sys/mman.h> was not included in dmeventd.c
thus missed definition of MCL_CURRENT  - thus patch only makes
it obvious we were not locking memory here.

This patch has no functional change.
Later part of this patch set handles mlockall() via memlock_inc_daemon().

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/dmeventd.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 7eb3b6b..37122c9 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1725,11 +1725,6 @@ int main(int argc, char *argv[])
 
 	pthread_mutex_init(&_global_mutex, NULL);
 
-#ifdef MCL_CURRENT
-	if (mlockall(MCL_CURRENT | MCL_FUTURE) == -1)
-		exit(EXIT_FAILURE);
-#endif
-
 	if ((ret = _open_fifos(&fifos)))
 		exit(EXIT_FIFO_FAILURE);
 
@@ -1749,9 +1744,6 @@ int main(int argc, char *argv[])
 
 	_exit_dm_lib();
 
-#ifdef MCL_CURRENT
-	munlockall();
-#endif
 	pthread_mutex_destroy(&_global_mutex);
 
 	syslog(LOG_NOTICE, "dmeventd shutting down.");
-- 
1.7.0.1


