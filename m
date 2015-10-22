From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:28 +0000 (UTC)
Subject: master - dmeventd: lvm2 plugin correctly debug
Message-ID: <20151022213328.BA695610C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cde12cbe9e4d3cabefc8644846e86b73b6217b6d
Commit:        cde12cbe9e4d3cabefc8644846e86b73b6217b6d
Parent:        ab6d16a8a5214ace81b9af346b9c065ec62fb04b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 10:38:05 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:28:37 2015 +0200

dmeventd: lvm2 plugin correctly debug

Fix debug message and report exit when really doing it.
Also add missing '_' to static function.
---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 49bfb56..aaf9a49 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -34,8 +34,8 @@ static void *_lvm_handle = NULL;
 
 DM_EVENT_LOG_FN("lvm")
 
-static void lvm2_print_log(int level, const char *file, int line,
-			   int dm_errno_or_class, const char *msg)
+static void _lvm2_print_log(int level, const char *file, int line,
+			    int dm_errno_or_class, const char *msg)
 {
 	print_log(level, file, line, dm_errno_or_class, "%s", msg);
 }
@@ -62,7 +62,7 @@ int dmeventd_lvm2_init(void)
 	pthread_mutex_lock(&_register_mutex);
 
 	if (!_lvm_handle) {
-		lvm2_log_fn(lvm2_print_log);
+		lvm2_log_fn(_lvm2_print_log);
 
 		if (!(_lvm_handle = lvm2_init()))
 			goto out;
@@ -103,10 +103,10 @@ void dmeventd_lvm2_exit(void)
 		log_debug("lvm plugin exiting.");
 		lvm2_exit(_lvm_handle);
 		_lvm_handle = NULL;
+		log_debug("lvm plugin exited.");
 	}
 
 	pthread_mutex_unlock(&_register_mutex);
-	log_debug("lvm plugin exited.");
 }
 
 struct dm_pool *dmeventd_lvm2_pool(void)


