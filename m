From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Jan 2011 23:09:32 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-cman.c da ...
Message-ID: <20110119230932.22038.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-01-19 23:09:31

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-cman.c clvmd-command.c clvmd-corosync.c 

Log message:
	In some versions (RHEL6) dlm_create_lockspace() always
	return lockspace reference (even if lockspace already exists)
	and thus increases DLM lockspace count. It means that after
	clvmd restart the lockspace is still in use.
	
	(The only way to clean environment to enable clean cluster
	shutdown is call "dlm_tool leave clvmd" several times.)
	
	Because only one clvmd can run in time, we can use simpler logic,
	try to open lockspace with dlm_open_lockspace() and only if it fails
	try to create new one. This way the lockspace reference doesn not
	increase.
	
	Very easily reproducible with  "clvmd -S" command.
	
	Patch also fixes return code when clvmd_restart fails and fixes
	double free if debug option was specified during restart.
	
	Fixes https://bugzilla.redhat.com/show_bug.cgi?id=612862

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1884&r2=1.1885
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-cman.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/WHATS_NEW	2011/01/17 23:13:14	1.1884
+++ LVM2/WHATS_NEW	2011/01/19 23:09:31	1.1885
@@ -1,6 +1,7 @@
 Version 2.02.82 -
 ===================================
   Add -f (don't fork) option to clvmd and fix clvmd -d<num> description.
+  Fix possible clvmd DLM lockspace increasing reference count.
 
 Version 2.02.81 - 17th January 2011
 ===================================
--- LVM2/daemons/clvmd/clvmd-cman.c	2010/06/21 15:56:58	1.28
+++ LVM2/daemons/clvmd/clvmd-cman.c	2011/01/19 23:09:31	1.29
@@ -89,16 +89,17 @@
 	DEBUGLOG("CMAN initialisation complete\n");
 
 	/* Create a lockspace for LV & VG locks to live in */
-	lockspace = dlm_create_lockspace(LOCKSPACE_NAME, 0600);
+	lockspace = dlm_open_lockspace(LOCKSPACE_NAME);
 	if (!lockspace) {
-		if (errno == EEXIST) {
-			lockspace = dlm_open_lockspace(LOCKSPACE_NAME);
-		}
+		lockspace = dlm_create_lockspace(LOCKSPACE_NAME, 0600);
 		if (!lockspace) {
-			syslog(LOG_ERR, "Unable to create lockspace for CLVM: %m");
+			syslog(LOG_ERR, "Unable to create DLM lockspace for CLVM: %m");
 			return -1;
 		}
-	}
+		DEBUGLOG("Created DLM lockspace for CLVMD.\n");
+	} else
+		DEBUGLOG("Opened existing DLM lockspace for CLVMD.\n");
+
 	dlm_ls_pthread_init(lockspace);
 	DEBUGLOG("DLM initialisation complete\n");
 	return 0;
--- LVM2/daemons/clvmd/clvmd-command.c	2011/01/17 23:13:14	1.48
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/01/19 23:09:31	1.49
@@ -147,7 +147,7 @@
 		break;
 
 	case CLVMD_CMD_RESTART:
-		restart_clvmd();
+		status = restart_clvmd();
 		break;
 
 	case CLVMD_CMD_GET_CLUSTERNAME:
@@ -382,8 +382,14 @@
 		    dm_snprintf(debug_arg, 16, "-d%d", (int)clvmd_get_debug()) < 0)
 			goto_out;
 		argv[argc++] = debug_arg;
+		debug_arg = NULL;
 	}
 
+	/*
+	 * FIXME: specify used cluster backend
+	 * argv[argc++] = strdup("-Isinglenode");
+	 */
+
 	/* Now add the exclusively-open LVs */
 	do {
 		hn = get_next_excl_lock(hn, &lv_name);
@@ -402,6 +408,7 @@
 	argv[argc++] = NULL;
 
 	/* Exec new clvmd */
+	DEBUGLOG("--- Restarting %s ---\n", CLVMD_PATH);
 	/* NOTE: This will fail when downgrading! */
 	execve(CLVMD_PATH, argv, NULL);
 out:
@@ -413,5 +420,5 @@
 	free(argv);
 	free(debug_arg);
 
-	return 0;
+	return EIO;
 }
--- LVM2/daemons/clvmd/clvmd-corosync.c	2010/06/21 15:56:58	1.14
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2011/01/19 23:09:31	1.15
@@ -294,19 +294,18 @@
 		return cs_to_errno(err);
 	}
 
-
 	/* Create a lockspace for LV & VG locks to live in */
-	lockspace = dlm_create_lockspace(LOCKSPACE_NAME, 0600);
+	lockspace = dlm_open_lockspace(LOCKSPACE_NAME);
 	if (!lockspace) {
-		if (errno == EEXIST) {
-			lockspace = dlm_open_lockspace(LOCKSPACE_NAME);
-		}
+		lockspace = dlm_create_lockspace(LOCKSPACE_NAME, 0600);
 		if (!lockspace) {
-			syslog(LOG_ERR, "Unable to create lockspace for CLVM: %m");
-			quorum_finalize(quorum_handle);
+			syslog(LOG_ERR, "Unable to create DLM lockspace for CLVM: %m");
 			return -1;
 		}
-	}
+		DEBUGLOG("Created DLM lockspace for CLVMD.\n");
+	} else
+		DEBUGLOG("Opened existing DLM lockspace for CLVMD.\n");
+
 	dlm_ls_pthread_init(lockspace);
 	DEBUGLOG("DLM initialisation complete\n");
 


