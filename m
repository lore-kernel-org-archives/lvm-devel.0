From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:21 +0000 (UTC)
Subject: master - memlock: Do not check memory balance if RUNNING_ON_VALGRIND.
Message-ID: <20150205134321.6A25B60E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a8dc7fb538595ffecee53298a38a284f8df89c0
Commit:        2a8dc7fb538595ffecee53298a38a284f8df89c0
Parent:        d571eab3b2bbb9be80e75e633bf2e30834975552
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 1 08:17:59 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:50:34 2015 +0100

memlock: Do not check memory balance if RUNNING_ON_VALGRIND.

---
 lib/mm/memlock.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index c5358dc..2327d4c 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -27,6 +27,10 @@
 #include <sys/resource.h>
 #include <malloc.h>
 
+#ifdef HAVE_VALGRIND
+#include <valgrind.h>
+#endif
+
 #ifndef DEVMAPPER_SUPPORT
 
 void memlock_inc_daemon(struct cmd_context *cmd)
@@ -254,12 +258,13 @@ static int _maps_line(const struct dm_config_node *cn, lvmlock_t lock,
 		}
 	}
 
-#ifdef VALGRIND_POOL
+#ifdef HAVE_VALGRIND
 	/*
 	 * Valgrind is continually eating memory while executing code
 	 * so we need to deactivate check of locked memory size
          */
-	sz -= sz; /* = 0, but avoids getting warning about dead assigment */
+	if (RUNNING_ON_VALGRIND)
+		sz -= sz; /* = 0, but avoids getting warning about dead assigment */
 
 #endif
 	*mstats += sz;


