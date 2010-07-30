From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 30 Jul 2010 09:39:53 -0500
Subject: [PATCH] Disallow mirrored log type for cluster mirrors
Message-ID: <1280500793.20453.1.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

	brassow

Disallow mirrored logs in cluster mirrors.

The cluster log daemon (cmirrord) is not multi-threaded and
can handle only one request at a time.  When a log is stacked
on top of a mirror (which itself contains a 'core' log), it
creates a situation that cannot be solved without threading.

When the top level mirror issues a "resume", the log daemon
attempts to read from the log device to retrieve the log
state.  However, the log is a mirror which, before issuing
the read, attempts to determine the 'sync' status of the
region of the mirror which is to be read.  This sync status
request cannot be completed by the daemon because it is
blocked on a read I/O to the very mirror requesting the
sync status.

 brassow

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -1970,10 +1970,21 @@ int lv_add_mirrors(struct cmd_context *c
 		return 0;
 	}
 
-	if (vg_is_clustered(lv->vg) &&  !(lv->status & ACTIVATE_EXCL) &&
-	    !cluster_mirror_is_available(lv)) {
-		log_error("Shared cluster mirrors are not available.");
-		return 0;
+	if (vg_is_clustered(lv->vg)) {
+		if (!(lv->status & ACTIVATE_EXCL) &&
+		    !cluster_mirror_is_available(lv)) {
+			log_error("Shared cluster mirrors are not available.");
+			return 0;
+		}
+
+		/*
+		 * No mirrored logs for cluster mirrors until
+		 * log daemon is multi-threaded.
+		 */
+		if (log_count > 1) {
+			log_error("Log type, \"mirrored\", is unavailable to cluster mirrors");
+			return 0;
+		}
 	}
 
 	/* For corelog mirror, activation code depends on
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -919,6 +919,15 @@ static int _lvconvert_mirrors_parse_para
 		return 0;
 	}
 
+	/*
+	 * No mirrored logs for cluster mirrors until
+	 * log daemon is multi-threaded.
+	 */
+	if ((*new_log_count == 2) && vg_is_clustered(lv->vg)) {
+		log_error("Log type, \"mirrored\", is unavailable to cluster mirrors");
+		return 0;
+	}
+
 	log_verbose("Setting logging type to %s", mirrorlog);
 
 	/*



