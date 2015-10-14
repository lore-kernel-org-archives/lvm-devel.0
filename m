From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 14 Oct 2015 12:28:56 +0000 (UTC)
Subject: master - dmeventd: use matching function
Message-ID: <20151014122856.998B86116C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6d1c8ac651ecdc6fbdfa20f892ba318c2dddeda
Commit:        a6d1c8ac651ecdc6fbdfa20f892ba318c2dddeda
Parent:        7c36d7c90c77f8225432b451cb831711cea01883
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 14 14:19:47 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 14 14:25:27 2015 +0200

dmeventd: use matching function

Respect lvm2_log_fn prototype. The idea of 'reusing' print_log with
plain cast is causing very strange crashes with some older 'gcc'  compilers.
So just do it cleanly...
---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index e3d8321..49bfb56 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -34,6 +34,12 @@ static void *_lvm_handle = NULL;
 
 DM_EVENT_LOG_FN("lvm")
 
+static void lvm2_print_log(int level, const char *file, int line,
+			   int dm_errno_or_class, const char *msg)
+{
+	print_log(level, file, line, dm_errno_or_class, "%s", msg);
+}
+
 /*
  * Currently only one event can be processed at a time.
  */
@@ -56,7 +62,7 @@ int dmeventd_lvm2_init(void)
 	pthread_mutex_lock(&_register_mutex);
 
 	if (!_lvm_handle) {
-		lvm2_log_fn((lvm2_log_fn_t)print_log);
+		lvm2_log_fn(lvm2_print_log);
 
 		if (!(_lvm_handle = lvm2_init()))
 			goto out;


