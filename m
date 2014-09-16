From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Tue, 16 Sep 2014 15:35:20 +0000 (UTC)
Subject: dev-mcsontos-clvmd-stack-overflow - clvmd: Fix stack overflow on 64 bit ARM
Message-ID: <20140916153520.BEDD760735@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05716c2d8a68e5acc698daf1234bed5feb93b743
Commit:        05716c2d8a68e5acc698daf1234bed5feb93b743
Parent:        4a853361b01feda77031901eb2828c6ecabe760f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Sep 16 17:23:11 2014 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Sep 16 17:34:32 2014 +0200

clvmd: Fix stack overflow on 64 bit ARM

Seems the amount of allocated data on stack is dependent on page size.
As the page size on aarch64 is 64kiB writing to memory allocated by
alloca results in stack overflow as at the time of allocation the are
already 2 pages allocated. Clearly 128kiB is not sufficient and at least
3 pages are needed.
---
 daemons/clvmd/clvmd.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 9b865f6..0684efb 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -24,6 +24,7 @@
 #include "clvmd.h"
 #include "lvm-functions.h"
 #include "lvm-version.h"
+#include "lvm-wrappers.h"
 #include "refresh_clvmd.h"
 
 #ifdef HAVE_COROSYNC_CONFDB_H
@@ -88,7 +89,7 @@ static debug_t debug = DEBUG_OFF;
 static int foreground_mode = 0;
 static pthread_t lvm_thread;
 /* Stack size 128KiB for thread, must be bigger then DEFAULT_RESERVED_STACK */
-static const size_t STACK_SIZE = 128 * 1024;
+static const size_t MIN_STACK_SIZE = 128 * 1024;
 static pthread_attr_t stack_attr;
 static int lvm_thread_exit = 0;
 static pthread_mutex_t lvm_thread_mutex;
@@ -358,6 +359,7 @@ int main(int argc, char *argv[])
 	int clusterwide_opt = 0;
 	mode_t old_mask;
 	int ret = 1;
+	size_t stack_size;
 
 	struct option longopts[] = {
 		{ "help", 0, 0, 'h' },
@@ -514,8 +516,10 @@ int main(int argc, char *argv[])
 
 	/* Initialise the LVM thread variables */
 	dm_list_init(&lvm_cmd_head);
+	stack_size = 3 * lvm_getpagesize();
+	stack_size = stack_size < MIN_STACK_SIZE ? MIN_STACK_SIZE : stack_size;
 	if (pthread_attr_init(&stack_attr) ||
-	    pthread_attr_setstacksize(&stack_attr, STACK_SIZE)) {
+	    pthread_attr_setstacksize(&stack_attr, stack_size)) {
 		log_sys_error("pthread_attr_init", "");
 		exit(1);
 	}


