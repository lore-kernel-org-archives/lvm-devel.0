From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 22 Sep 2011 11:52:49 +0200
Subject: [PATCH 2/3] CLVMD bugfix support arg -E
In-Reply-To: <cover.1316684951.git.zkabelac@redhat.com>
References: <cover.1316684951.git.zkabelac@redhat.com>
Message-ID: <3f7f81fb3dad919c78ce4f84281465fbaaba743c.1316684951.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.c         |   19 +++++++++++++++--
 daemons/clvmd/lvm-functions.c |   42 ++++++++--------------------------------
 daemons/clvmd/lvm-functions.h |    2 +-
 man/clvmd.8.in                |    4 +++
 4 files changed, 30 insertions(+), 37 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 2c9f8db..b0383dc 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -78,7 +78,7 @@ struct lvm_thread_cmd {
 };
 
 struct lvm_startup_params {
-	char **argv;
+	struct dm_hash_table *excl_uuid;
 };
 
 static debug_t debug = DEBUG_OFF;
@@ -149,6 +149,7 @@ static void usage(const char *prog, FILE *file)
 		"   -h       Show this help information\n"
 		"   -d[n]    Set debug logging (0:none, 1:stderr (implies -f option), 2:syslog)\n"
 		"   -f       Don't fork, run in the foreground\n"
+		"   -E<lockuuid> Take this lock uuid as exclusively locked resource (for restart)\n"
 		"   -R       Tell all running clvmds in the cluster to reload their device cache\n"
 		"   -S       Restart clvmd, preserving exclusive locks\n"
 		"   -C       Sets debug level (from -d) on all clvmd instances clusterwide\n"
@@ -349,6 +350,11 @@ int main(int argc, char *argv[])
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
@@ -392,6 +398,12 @@ int main(int argc, char *argv[])
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
@@ -566,7 +578,6 @@ int main(int argc, char *argv[])
 
 	/* Don't let anyone else to do work until we are started */
 	pthread_mutex_lock(&lvm_start_mutex);
-	lvm_params.argv = argv;
 	pthread_create(&lvm_thread, NULL, lvm_thread_fn, &lvm_params);
 
 	/* Tell the rest of the cluster our version number */
@@ -604,6 +615,8 @@ int main(int argc, char *argv[])
 		free(delfd);
 	}
 
+	dm_hash_destroy(lvm_params.excl_uuid);
+
 	return 0;
 }
 
@@ -1981,7 +1994,7 @@ static void *lvm_thread_fn(void *arg)
 	pthread_sigmask(SIG_BLOCK, &ss, NULL);
 
 	/* Initialise the interface to liblvm */
-	init_clvm(lvm_params->argv);
+	init_clvm(lvm_params->excl_uuid);
 
 	/* Allow others to get moving */
 	pthread_mutex_unlock(&lvm_start_mutex);
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index b988b15..ba786bb 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -694,34 +694,11 @@ void do_lock_vg(unsigned char command, unsigned char lock_flags, char *resource)
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
@@ -733,7 +710,7 @@ static int get_initial_state(char **argv)
 	     "r");
 
 	if (!lvs)
-		return 1;
+		return 0;
 
 	while (fgets(line, sizeof(line), lvs)) {
 	        if (sscanf(line, "%s %s %s %s\n", vg, lv, flags, vg_flags) == 4) {
@@ -759,12 +736,10 @@ static int get_initial_state(char **argv)
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
@@ -773,7 +748,8 @@ static int get_initial_state(char **argv)
 	}
 	if (fclose(lvs))
 		DEBUGLOG("lvs fclose failed: %s\n", strerror(errno));
-	return 0;
+
+	return 1;
 }
 
 static void lvm2_log_fn(int level, const char *file, int line, int dm_errno,
@@ -880,14 +856,14 @@ void lvm_do_fs_unlock(void)
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
diff --git a/daemons/clvmd/lvm-functions.h b/daemons/clvmd/lvm-functions.h
index f9c43b7..565f878 100644
--- a/daemons/clvmd/lvm-functions.h
+++ b/daemons/clvmd/lvm-functions.h
@@ -27,7 +27,7 @@ extern int post_lock_lv(unsigned char lock_cmd, unsigned char lock_flags,
 			char *resource);
 extern int do_check_lvm1(const char *vgname);
 extern int do_refresh_cache(void);
-extern int init_clvm(char **argv);
+extern int init_clvm(struct dm_hash_table *excl_uuid);
 extern void destroy_lvm(void);
 extern void init_lvhash(void);
 extern void destroy_lvhash(void);
diff --git a/man/clvmd.8.in b/man/clvmd.8.in
index a4b9cc9..22d94b2 100644
--- a/man/clvmd.8.in
+++ b/man/clvmd.8.in
@@ -4,6 +4,7 @@ clvmd \- cluster LVM daemon
 .SH SYNOPSIS
 .B clvmd
 [\-d[<value>]] [\-C] [\-h]
+[\-E <lock uuid>]
 [\-R]
 [\-S]
 [\-t <timeout>]
@@ -69,6 +70,9 @@ sensible.
 .br
 This timeout will be ignored if you start clvmd with the -d switch.
 .TP
+.I \-E <lock uuid>
+Pass lock uuid to be reacquired exclusively when clvmd is restarted.
+.TP
 .I \-R
 Tells all the running clvmds in the cluster to reload their device cache and
 re-read the lvm configuration file. This command should be run whenever the
-- 
1.7.6.2


