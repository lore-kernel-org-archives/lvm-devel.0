From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:07 -0400
Subject: master - config: revert to normal locking when no cluster
Message-ID: <201805311414.w4VEE7O7031146@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a4fe54ca12daf0af142e47092968cadb279d10b
Commit:        3a4fe54ca12daf0af142e47092968cadb279d10b
Parent:        7f7ec769d98cfe7af47b202189b279f354763b5a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 23 10:15:39 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

config: revert to normal locking when no cluster

and suggest lvmlockd
---
 lib/locking/locking.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 105419a..2584227 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -148,11 +148,11 @@ int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 		}
 #endif
 
-#ifdef CLUSTER_LOCKING_INTERNAL
 		log_very_verbose("Falling back to internal clustered locking.");
 		/* Fall through */
 
 	case 3:
+#ifdef CLUSTER_LOCKING_INTERNAL
 		log_very_verbose("Cluster locking selected.");
 		if (!init_cluster_locking(&_locking, cmd, suppress_messages)) {
 			log_error_suppress(suppress_messages,
@@ -160,6 +160,20 @@ int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 			break;
 		}
 		return 1;
+#else
+		log_warn("WARNING: Using locking_type=1, ignoring locking_type=3.");
+		log_warn("WARNING: See lvmlockd(8) for information on using cluster/clvm VGs.");
+		type = 1;
+
+		log_very_verbose("%sFile-based locking selected.",
+				 _blocking_supported ? "" : "Non-blocking ");
+
+		if (!init_file_locking(&_locking, cmd, suppress_messages)) {
+			log_error_suppress(suppress_messages,
+					   "File-based locking initialisation failed.");
+			break;
+		}
+		return 1;
 #endif
 
 	case 4:


