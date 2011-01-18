From: Milan Broz <mbroz@redhat.com>
Date: Tue, 18 Jan 2011 18:33:29 +0100
Subject: [PATCH] Fix CLVM DLM lockspace increasing reference count.
Message-ID: <1295372009-12673-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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
---
 daemons/clvmd/clvmd-cman.c     |   13 +++++++------
 daemons/clvmd/clvmd-command.c  |   11 +++++++++--
 daemons/clvmd/clvmd-corosync.c |   15 +++++++--------
 3 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/daemons/clvmd/clvmd-cman.c b/daemons/clvmd/clvmd-cman.c
index 52da2ac..c7a2b2d 100644
--- a/daemons/clvmd/clvmd-cman.c
+++ b/daemons/clvmd/clvmd-cman.c
@@ -89,16 +89,17 @@ static int _init_cluster(void)
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
diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 2576dcf..3872702 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -147,7 +147,7 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 		break;
 
 	case CLVMD_CMD_RESTART:
-		restart_clvmd();
+		status = restart_clvmd();
 		break;
 
 	case CLVMD_CMD_GET_CLUSTERNAME:
@@ -382,8 +382,14 @@ static int restart_clvmd(void)
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
@@ -402,6 +408,7 @@ static int restart_clvmd(void)
 	argv[argc++] = NULL;
 
 	/* Exec new clvmd */
+	DEBUGLOG("--- Restarting %s ---\n", CLVMD_PATH);
 	/* NOTE: This will fail when downgrading! */
 	execve(CLVMD_PATH, argv, NULL);
 out:
@@ -413,5 +420,5 @@ out:
 	free(argv);
 	free(debug_arg);
 
-	return 0;
+	return EIO;
 }
diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
index cfe7150..01ee09f 100644
--- a/daemons/clvmd/clvmd-corosync.c
+++ b/daemons/clvmd/clvmd-corosync.c
@@ -294,19 +294,18 @@ static int _init_cluster(void)
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
 
-- 
1.7.2.3


