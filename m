From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Sep 2011 20:48:35 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c daemons ...
Message-ID: <20110924204835.29357.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-24 20:48:34

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c lvm-functions.c lvm-functions.h 
	man            : clvmd.8.in 

Log message:
	CLVMD bugfix support for args -S -E
	
	Bugfix:
	Add (most probably unfinished) support for -E arg with list of exclusive
	locks.  (During clvmd restart all exclusive locks would have been lost and
	in fact, if there would have been an exclusive lock, usage text would be
	printed and clvmd exits.)
	
	Instead of parsing list options multiple times every time some lock UUID is
	checked - put them straight into the hash table - make the code easier to
	understand as well.
	
	Remove  was_ex_lock() function (replaced with dm_hash_lookup()).
	
	Swap return value for get_initial_state() (1 means success).
	
	Update man pages and usage info for -E option.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2133&r2=1.2134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/clvmd.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2011/09/23 15:17:54	1.2133
+++ LVM2/WHATS_NEW	2011/09/24 20:48:34	1.2134
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix restart of clvmd (preserve exlusive locks). (2.02.64)
   Add 'Volume Type' lv_attr characters for RAID and RAID_IMAGE.
   Add activation/retry_deactivation to lvm.conf to retry deactivation of an LV.
   Replace open_count check with holders/mounted_fs check on lvremove path.
--- LVM2/daemons/clvmd/clvmd.c	2011/09/16 14:40:07	1.109
+++ LVM2/daemons/clvmd/clvmd.c	2011/09/24 20:48:34	1.110
@@ -78,7 +78,7 @@
 };
 
 struct lvm_startup_params {
-	char **argv;
+	struct dm_hash_table *excl_uuid;
 };
 
 static debug_t debug = DEBUG_OFF;
@@ -149,6 +149,7 @@
 		"   -h       Show this help information\n"
 		"   -d[n]    Set debug logging (0:none, 1:stderr (implies -f option), 2:syslog)\n"
 		"   -f       Don't fork, run in the foreground\n"
+		"   -E<lockuuid> Take this lock uuid as exclusively locked resource (for restart)\n"
 		"   -R       Tell all running clvmds in the cluster to reload their device cache\n"
 		"   -S       Restart clvmd, preserving exclusive locks\n"
 		"   -C       Sets debug level (from -d) on all clvmd instances clusterwide\n"
@@ -348,6 +349,11 @@
 		{ NULL, 0, 0, 0 }
 	};
 
+	if (!(lvm_params.excl_uuid = dm_hash_create(128))) {
+		fprintf(stderr, "Failed to allocate hash table\n");
+		return 1;
+	}
+
 	/* Deal with command-line arguments */
 	opterr = 0;
 	optind = 0;
@@ -391,6 +397,12 @@
 		case 'I':
 			cluster_iface = parse_cluster_interface(optarg);
 			break;
+		case 'E':
+			if (!dm_hash_insert(lvm_params.excl_uuid, optarg, optarg)) {
+				fprintf(stderr, "Failed to allocate hash entry\n");
+				return 1;
+			}
+			break;
 		case 'T':
 			start_timeout = atoi(optarg);
 			if (start_timeout <= 0) {
@@ -565,7 +577,6 @@
 
 	/* Don't let anyone else to do work until we are started */
 	pthread_mutex_lock(&lvm_start_mutex);
-	lvm_params.argv = argv;
 	pthread_create(&lvm_thread, NULL, lvm_thread_fn, &lvm_params);
 
 	/* Tell the rest of the cluster our version number */
@@ -603,6 +614,8 @@
 		free(delfd);
 	}
 
+	dm_hash_destroy(lvm_params.excl_uuid);
+
 	return 0;
 }
 
@@ -1978,7 +1991,7 @@
 	pthread_sigmask(SIG_BLOCK, &ss, NULL);
 
 	/* Initialise the interface to liblvm */
-	init_clvm(lvm_params->argv);
+	init_clvm(lvm_params->excl_uuid);
 
 	/* Allow others to get moving */
 	pthread_mutex_unlock(&lvm_start_mutex);
--- LVM2/daemons/clvmd/lvm-functions.c	2011/08/10 20:25:29	1.122
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/09/24 20:48:34	1.123
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -694,34 +694,11 @@
 }
 
 /*
- * Compare the uuid with the list of exclusive locks that clvmd
- * held before it was restarted, so we can get the right kind
- * of lock now we are restarting.
- */
-static int was_ex_lock(char *uuid, char **argv)
-{
-	int optnum = 0;
-	char *opt = argv[optnum];
-
-	while (opt) {
-		if (strcmp(opt, "-E") == 0) {
-			opt = argv[++optnum];
-			if (opt && (strcmp(opt, uuid) == 0)) {
-				DEBUGLOG("Lock %s is exclusive\n", uuid);
-				return 1;
-			}
-		}
-		opt = argv[++optnum];
-	}
-	return 0;
-}
-
-/*
  * Ideally, clvmd should be started before any LVs are active
  * but this may not be the case...
  * I suppose this also comes in handy if clvmd crashes, not that it would!
  */
-static int get_initial_state(char **argv)
+static int get_initial_state(struct dm_hash_table *excl_uuid)
 {
 	int lock_mode;
 	char lv[64], vg[64], flags[25], vg_flags[25];
@@ -733,7 +710,7 @@
 	     "r");
 
 	if (!lvs)
-		return 1;
+		return 0;
 
 	while (fgets(line, sizeof(line), lvs)) {
 	        if (sscanf(line, "%s %s %s %s\n", vg, lv, flags, vg_flags) == 4) {
@@ -759,12 +736,10 @@
 				memcpy(&uuid[58], &lv[32], 6);
 				uuid[64] = '\0';
 
-				lock_mode = LCK_READ;
-
 				/* Look for this lock in the list of EX locks
 				   we were passed on the command-line */
-				if (was_ex_lock(uuid, argv))
-					lock_mode = LCK_EXCL;
+				lock_mode = (dm_hash_lookup(excl_uuid, uuid)) ?
+					LCK_EXCL : LCK_READ;
 
 				DEBUGLOG("getting initial lock for %s\n", uuid);
 				hold_lock(uuid, lock_mode, LCKF_NOQUEUE);
@@ -773,7 +748,8 @@
 	}
 	if (fclose(lvs))
 		DEBUGLOG("lvs fclose failed: %s\n", strerror(errno));
-	return 0;
+
+	return 1;
 }
 
 static void lvm2_log_fn(int level, const char *file, int line, int dm_errno,
@@ -880,14 +856,14 @@
 }
 
 /* Called to initialise the LVM context of the daemon */
-int init_clvm(char **argv)
+int init_clvm(struct dm_hash_table *excl_uuid)
 {
 	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
 
 	/* Initialise already held locks */
-	if (get_initial_state(argv))
+	if (!get_initial_state(excl_uuid))
 		log_error("Cannot load initial lock states.");
 
 	if (!(cmd = create_toolcontext(1, NULL, 0))) {
--- LVM2/daemons/clvmd/lvm-functions.h	2011/08/09 18:11:00	1.16
+++ LVM2/daemons/clvmd/lvm-functions.h	2011/09/24 20:48:34	1.17
@@ -27,7 +27,7 @@
 			char *resource);
 extern int do_check_lvm1(const char *vgname);
 extern int do_refresh_cache(void);
-extern int init_clvm(char **argv);
+extern int init_clvm(struct dm_hash_table *excl_uuid);
 extern void destroy_lvm(void);
 extern void init_lvhash(void);
 extern void destroy_lvhash(void);
--- LVM2/man/clvmd.8.in	2011/08/09 18:11:00	1.6
+++ LVM2/man/clvmd.8.in	2011/09/24 20:48:34	1.7
@@ -4,6 +4,7 @@
 .SH SYNOPSIS
 .B clvmd
 [\-d[<value>]] [\-C] [\-h]
+[\-E <lock uuid>]
 [\-R]
 [\-S]
 [\-t <timeout>]
@@ -69,6 +70,9 @@
 .br
 This timeout will be ignored if you start clvmd with the -d switch.
 .TP
+.I \-E <lock uuid>
+Pass lock uuid to be reacquired exclusively when clvmd is restarted.
+.TP
 .I \-R
 Tells all the running clvmds in the cluster to reload their device cache and
 re-read the lvm configuration file. This command should be run whenever the


