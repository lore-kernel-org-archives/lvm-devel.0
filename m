From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 09:18:49 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20111011091849.6933.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 09:18:49

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Limit thread stack
	
	Since default thread stack size is around 8MB and clvmd creates for now thread
	for message, clvmd may easily reach multi GB size of in-memory locked pages
	(runs with mlockall()).
	
	This patch significantly reduces memory usage to just tens of MB,
	and now different reasons are the cause of server overloading.
	Now we are running out of free file descriptors mostly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111

--- LVM2/daemons/clvmd/clvmd.c	2011/09/24 20:48:34	1.110
+++ LVM2/daemons/clvmd/clvmd.c	2011/10/11 09:18:49	1.111
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -84,6 +84,9 @@
 static debug_t debug = DEBUG_OFF;
 static int foreground_mode = 0;
 static pthread_t lvm_thread;
+/* Stack size 128KiB for thread, must be bigger then DEFAULT_RESERVED_STACK */
+static const size_t STACK_SIZE = 128 * 1024;
+static pthread_attr_t stack_attr;
 static pthread_mutex_t lvm_thread_mutex;
 static pthread_cond_t lvm_thread_cond;
 static pthread_mutex_t lvm_start_mutex;
@@ -495,6 +498,11 @@
 
 	/* Initialise the LVM thread variables */
 	dm_list_init(&lvm_cmd_head);
+	if (pthread_attr_init(&stack_attr) ||
+	    pthread_attr_setstacksize(&stack_attr, STACK_SIZE)) {
+		log_sys_error("pthread_attr_init", "");
+		exit(1);
+	}
 	pthread_mutex_init(&lvm_thread_mutex, NULL);
 	pthread_cond_init(&lvm_thread_cond, NULL);
 	pthread_mutex_init(&lvm_start_mutex, NULL);
@@ -577,7 +585,7 @@
 
 	/* Don't let anyone else to do work until we are started */
 	pthread_mutex_lock(&lvm_start_mutex);
-	pthread_create(&lvm_thread, NULL, lvm_thread_fn, &lvm_params);
+	pthread_create(&lvm_thread, &stack_attr, lvm_thread_fn, &lvm_params);
 
 	/* Tell the rest of the cluster our version number */
 	if (clops->cluster_init_completed)
@@ -1355,8 +1363,8 @@
 		thisfd->bits.localsock.in_progress = TRUE;
 		thisfd->bits.localsock.state = PRE_COMMAND;
 		DEBUGLOG("Creating pre&post thread\n");
-		status = pthread_create(&thisfd->bits.localsock.threadid, NULL,
-			       pre_and_post_thread, thisfd);
+		status = pthread_create(&thisfd->bits.localsock.threadid,
+					&stack_attr, pre_and_post_thread, thisfd);
 		DEBUGLOG("Created pre&post thread, state = %d\n", status);
 	}
 	return len;


