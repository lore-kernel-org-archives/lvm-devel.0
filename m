From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 09:54:40 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20111011095440.13912.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 09:54:39

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Simplify worker loop
	
	Do not reacquire mutex several times without a real reason.
	Code readability is also better.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2159&r2=1.2160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114

--- LVM2/WHATS_NEW	2011/10/11 09:26:04	1.2159
+++ LVM2/WHATS_NEW	2011/10/11 09:54:39	1.2160
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Simplify code for lvm worker thread in clvmd.
   Use pthread_barrier to synchronize clvmd threads at startup.
   Limit clvmd's thread size to 128KiB.
   Reduce default preallocated stack size to 64KiB.
--- LVM2/daemons/clvmd/clvmd.c	2011/10/11 09:26:04	1.113
+++ LVM2/daemons/clvmd/clvmd.c	2011/10/11 09:54:39	1.114
@@ -1988,6 +1988,7 @@
 	struct dm_list *cmdl, *tmp;
 	sigset_t ss;
 	struct lvm_startup_params *lvm_params = arg;
+	struct lvm_thread_cmd *cmd;
 
 	DEBUGLOG("LVM thread function started\n");
 
@@ -2005,18 +2006,15 @@
 	DEBUGLOG("Sub thread ready for work.\n");
 
 	/* Now wait for some actual work */
-	while (!quit) {
-		DEBUGLOG("LVM thread waiting for work\n");
+	pthread_mutex_lock(&lvm_thread_mutex);
 
-		pthread_mutex_lock(&lvm_thread_mutex);
-		if (dm_list_empty(&lvm_cmd_head))
+	while (!quit) {
+		if (dm_list_empty(&lvm_cmd_head)) {
+			DEBUGLOG("LVM thread waiting for work\n");
 			pthread_cond_wait(&lvm_thread_cond, &lvm_thread_mutex);
-
-		dm_list_iterate_safe(cmdl, tmp, &lvm_cmd_head) {
-			struct lvm_thread_cmd *cmd;
-
-			cmd =
-			    dm_list_struct_base(cmdl, struct lvm_thread_cmd, list);
+		} else {
+			cmd = dm_list_item(dm_list_first(&lvm_cmd_head),
+					   struct lvm_thread_cmd);
 			dm_list_del(&cmd->list);
 			pthread_mutex_unlock(&lvm_thread_mutex);
 
@@ -2026,9 +2024,10 @@
 
 			pthread_mutex_lock(&lvm_thread_mutex);
 		}
-		pthread_mutex_unlock(&lvm_thread_mutex);
 	}
 
+	pthread_mutex_unlock(&lvm_thread_mutex);
+
 	pthread_exit(NULL);
 }
 


