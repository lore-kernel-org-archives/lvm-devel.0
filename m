From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 2 Aug 2010 19:03:47 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c tools/l ...
Message-ID: <20100802190347.28597.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-08-02 19:03:46

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 
	tools          : lvconvert.c 

Log message:
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

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1686&r2=1.1687
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142

--- LVM2/WHATS_NEW	2010/08/02 13:56:35	1.1686
+++ LVM2/WHATS_NEW	2010/08/02 19:03:45	1.1687
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Disallow 'mirrored' log type for cluster mirrors.
   Do not use VPATH in include/Makefile.
   Fix exported_symbols generation to use standard compiler arguments.
   Use #include <> not "" in lvm2app.h which gets installed on the system.
--- LVM2/lib/metadata/mirror.c	2010/07/21 13:40:22	1.128
+++ LVM2/lib/metadata/mirror.c	2010/08/02 19:03:45	1.129
@@ -1970,10 +1970,21 @@
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
--- LVM2/tools/lvconvert.c	2010/07/30 17:50:16	1.141
+++ LVM2/tools/lvconvert.c	2010/08/02 19:03:45	1.142
@@ -919,6 +919,15 @@
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


