From: David Teigland <teigland@sourceware.org>
Date: Mon, 28 Aug 2017 17:26:18 -0400
Subject: master - lvmlockd: print error about starting lock manager
Message-ID: <201708282126.v7SLQI1e025016@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f847fcd31a41f61dd81b30ac91f3e2720088b8f2
Commit:        f847fcd31a41f61dd81b30ac91f3e2720088b8f2
Parent:        c8fdc5c0877b137ed3ca1f217d8ef0fa89299a9a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 28 16:24:00 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 28 16:24:00 2017 -0500

lvmlockd: print error about starting lock manager

In the case where lvmlockd is running, but no lock manager
is running, we should print a specific error message about
that situation.
---
 daemons/lvmlockd/lvmlockd-core.c |    2 +-
 lib/locking/lvmlockd.c           |   10 ++++++++++
 lib/locking/lvmlockd.h           |    1 +
 3 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 903da7c..f9d07c1 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3676,7 +3676,7 @@ static int client_send_result(struct client *cl, struct action *act)
 			if (!gl_lsname_dlm[0])
 				strcat(result_flags, "NO_GL_LS,");
 		} else {
-			strcat(result_flags, "NO_GL_LS,");
+			strcat(result_flags, "NO_GL_LS,NO_LM");
 		}
 	}
 
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index d85021c..a0e3f03 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -115,6 +115,9 @@ static void _flags_str_to_lockd_flags(const char *flags_str, uint32_t *lockd_fla
 	if (strstr(flags_str, "NO_GL_LS"))
 		*lockd_flags |= LD_RF_NO_GL_LS;
 
+	if (strstr(flags_str, "NO_LM"))
+		*lockd_flags |= LD_RF_NO_LM;
+
 	if (strstr(flags_str, "DUP_GL_LS"))
 		*lockd_flags |= LD_RF_DUP_GL_LS;
 
@@ -1362,6 +1365,9 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
 			log_error("Global lock failed: check that VG holding global lock exists and is started.");
 		else
 			log_error("Global lock failed: check that global lockspace is started.");
+
+		if (lockd_flags & LD_RF_NO_LM)
+			log_error("Start a lock manager, lvmlockd did not find one running.");
 		return 0;
 	}
 
@@ -1565,6 +1571,9 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 	 * access to lease storage.
 	 */
 
+	if (result == -ENOLS && (lockd_flags & LD_RF_NO_LM))
+		log_error("Start a lock manager, lvmlockd did not find one running.");
+
 	if (result == -ENOLS ||
 	    result == -ESTARTING ||
 	    result == -EVGKILLED ||
@@ -1583,6 +1592,7 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 				log_error("Global lock failed: storage failed for sanlock leases");
 			else
 				log_error("Global lock failed: error %d", result);
+
 			return 0;
 		}
 
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 8b282d8..cf23e9b 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -28,6 +28,7 @@
 #define LD_RF_NO_GL_LS          0x00000002
 #define LD_RF_WARN_GL_REMOVED   0x00000004
 #define LD_RF_DUP_GL_LS         0x00000008
+#define LD_RF_NO_LM		0x00000010
 
 /* lockd_state flags */
 #define LDST_EX			0x00000001


