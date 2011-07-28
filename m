From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Jul 2011 13:03:38 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/dmeventd.c
Message-ID: <20110728130338.17442.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-07-28 13:03:38

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: dmeventd.c 

Log message:
	Add support for new oom killer adjustment interface (oom_score_adj).
	
	The filename to adjust the oom score was changed in 2.6.36.
	We should use oom_score_adj instead of oom_adj (which is still
	there under /proc, but it's scheduled for removal in August 2012).
	
	New oom_score_adj uses a range from -1000 (OOM_SCORE_ADJ_MIN,
	disable oom killing) to 1000 (OOM_SCORE_ADJ_MAX).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.483&r2=1.484
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/WHATS_NEW_DM	2011/07/28 12:54:28	1.483
+++ LVM2/WHATS_NEW_DM	2011/07/28 13:03:37	1.484
@@ -1,5 +1,6 @@
 Version 1.02.66 - 
 ===============================
+  Add support for new oom killer adjustment interface (oom_score_adj).
   Add systemd unit files for dmeventd.
   Fix read-only identical table reload supression.
 
--- LVM2/daemons/dmeventd/dmeventd.c	2011/04/04 16:11:09	1.80
+++ LVM2/daemons/dmeventd/dmeventd.c	2011/07/28 13:03:37	1.81
@@ -41,11 +41,19 @@
 #ifdef linux
 #  include <malloc.h>
 
-#  define OOM_ADJ_FILE "/proc/self/oom_adj"
+/*
+ * Kernel version 2.6.36 and higher has
+ * new OOM killer adjustment interface.
+ */
+#  define OOM_ADJ_FILE_OLD "/proc/self/oom_adj"
+#  define OOM_ADJ_FILE "/proc/self/oom_score_adj"
 
 /* From linux/oom.h */
+/* Old interface */
 #  define OOM_DISABLE (-17)
 #  define OOM_ADJUST_MIN (-16)
+/* New interface */
+#  define OOM_SCORE_ADJ_MIN (-1000)
 
 #endif
 
@@ -1594,33 +1602,48 @@
 }
 
 #ifdef linux
+static int _set_oom_adj(const char *oom_adj_path, int val)
+{
+	FILE *fp;
+
+	if (!(fp = fopen(oom_adj_path, "w"))) {
+		perror("oom_adj: fopen failed");
+		return 0;
+	}
+
+	fprintf(fp, "%i", val);
+
+	if (dm_fclose(fp))
+		perror("oom_adj: fclose failed");
+
+	return 1;
+}
+
 /*
  * Protection against OOM killer if kernel supports it
  */
-static int _set_oom_adj(int val)
+static int _protect_against_oom_killer()
 {
-	FILE *fp;
-
 	struct stat st;
 
 	if (stat(OOM_ADJ_FILE, &st) == -1) {
-		if (errno == ENOENT)
-			perror(OOM_ADJ_FILE " not found");
-		else
+		if (errno != ENOENT)
 			perror(OOM_ADJ_FILE ": stat failed");
-		return 1;
-	}
 
-	if (!(fp = fopen(OOM_ADJ_FILE, "w"))) {
-		perror(OOM_ADJ_FILE ": fopen failed");
-		return 0;
-	}
+		/* Try old oom_adj interface as a fallback */
+		if (stat(OOM_ADJ_FILE_OLD, &st) == -1) {
+			if (errno == ENOENT)
+				perror(OOM_ADJ_FILE_OLD " not found");
+			else
+				perror(OOM_ADJ_FILE_OLD ": stat failed");
+			return 1;
+		}
 
-	fprintf(fp, "%i", val);
-	if (dm_fclose(fp))
-		perror(OOM_ADJ_FILE ": fclose failed");
+		return _set_oom_adj(OOM_ADJ_FILE_OLD, OOM_DISABLE) ||
+		       _set_oom_adj(OOM_ADJ_FILE_OLD, OOM_ADJUST_MIN);
+	}
 
-	return 1;
+	return _set_oom_adj(OOM_ADJ_FILE, OOM_SCORE_ADJ_MIN);
 }
 #endif
 
@@ -1829,8 +1852,8 @@
 	signal(SIGQUIT, &_exit_handler);
 
 #ifdef linux
-	if (!_set_oom_adj(OOM_DISABLE) && !_set_oom_adj(OOM_ADJUST_MIN))
-		syslog(LOG_ERR, "Failed to set oom_adj to protect against OOM killer");
+	if (!_protect_against_oom_killer())
+		syslog(LOG_ERR, "Failed to protect against OOM killer");
 #endif
 
 	_init_thread_signals();


