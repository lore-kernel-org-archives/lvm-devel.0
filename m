From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 09:26:04 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20111011092604.10366.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 09:26:04

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Use barrier instead of mutex
	
	Barrier is supposed to be used in situation like this
	and replace tricky mutex usage, where mutex has been unlocked
	by a different thread than the locking thread.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2158&r2=1.2159
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113

--- LVM2/WHATS_NEW	2011/10/11 09:20:17	1.2158
+++ LVM2/WHATS_NEW	2011/10/11 09:26:04	1.2159
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Use pthread_barrier to synchronize clvmd threads at startup.
   Limit clvmd's thread size to 128KiB.
   Reduce default preallocated stack size to 64KiB.
   Add check for access through NULL pointer when refresh_filter() fails.
--- LVM2/daemons/clvmd/clvmd.c	2011/10/11 09:23:48	1.112
+++ LVM2/daemons/clvmd/clvmd.c	2011/10/11 09:26:04	1.113
@@ -89,7 +89,7 @@
 static pthread_attr_t stack_attr;
 static pthread_mutex_t lvm_thread_mutex;
 static pthread_cond_t lvm_thread_cond;
-static pthread_mutex_t lvm_start_mutex;
+static pthread_barrier_t lvm_start_barrier;
 static struct dm_list lvm_cmd_head;
 static volatile sig_atomic_t quit = 0;
 static volatile sig_atomic_t reread_config = 0;
@@ -505,7 +505,7 @@
 	}
 	pthread_mutex_init(&lvm_thread_mutex, NULL);
 	pthread_cond_init(&lvm_thread_cond, NULL);
-	pthread_mutex_init(&lvm_start_mutex, NULL);
+	pthread_barrier_init(&lvm_start_barrier, NULL, 2);
 	init_lvhash();
 
 	/* Start the cluster interface */
@@ -584,9 +584,11 @@
 	DEBUGLOG("starting LVM thread\n");
 
 	/* Don't let anyone else to do work until we are started */
-	pthread_mutex_lock(&lvm_start_mutex);
 	pthread_create(&lvm_thread, &stack_attr, lvm_thread_fn, &lvm_params);
 
+	/* Don't start until the LVM thread is ready */
+	pthread_barrier_wait(&lvm_start_barrier);
+
 	/* Tell the rest of the cluster our version number */
 	if (clops->cluster_init_completed)
 		clops->cluster_init_completed();
@@ -1633,11 +1635,6 @@
 	DEBUGLOG("in sub thread: client = %p\n", client);
 	pthread_mutex_lock(&client->bits.localsock.mutex);
 
-	/* Don't start until the LVM thread is ready */
-	pthread_mutex_lock(&lvm_start_mutex);
-	pthread_mutex_unlock(&lvm_start_mutex);
-	DEBUGLOG("Sub thread ready for work.\n");
-
 	/* Ignore SIGUSR1 (handled by master process) but enable
 	   SIGUSR2 (kills subthreads) */
 	sigemptyset(&ss);
@@ -2004,7 +2001,8 @@
 	init_clvm(lvm_params->excl_uuid);
 
 	/* Allow others to get moving */
-	pthread_mutex_unlock(&lvm_start_mutex);
+	pthread_barrier_wait(&lvm_start_barrier);
+	DEBUGLOG("Sub thread ready for work.\n");
 
 	/* Now wait for some actual work */
 	while (!quit) {


