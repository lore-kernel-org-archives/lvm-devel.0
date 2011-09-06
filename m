From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Sep 2011 15:38:46 -0000
Subject: LVM2/lib/misc lvm-string.c
Message-ID: <20110906153846.8780.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-06 15:38:45

Modified files:
	lib/misc       : lvm-string.c 

Log message:
	tdata->tpool

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/lib/misc/lvm-string.c	2011/09/06 00:26:43	1.30
+++ LVM2/lib/misc/lvm-string.c	2011/09/06 15:38:44	1.31
@@ -95,58 +95,40 @@
 
 int apply_lvname_restrictions(const char *name)
 {
-	if (!strncmp(name, "snapshot", 8)) {
-		log_error("Names starting \"snapshot\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
-	if (!strncmp(name, "pvmove", 6)) {
-		log_error("Names starting \"pvmove\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
-	if (strstr(name, "_mlog")) {
-		log_error("Names including \"_mlog\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
-	if (strstr(name, "_mimage")) {
-		log_error("Names including \"_mimage\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
-	if (strstr(name, "_rimage")) {
-		log_error("Names including \"_rimage\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
-	if (strstr(name, "_rmeta")) {
-		log_error("Names including \"_rmeta\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
-	if (strstr(name, "_vorigin")) {
-		log_error("Names including \"_vorigin\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
-	if (strstr(name, "_tdata")) {
-		log_error("Names including \"_tpool\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
-	if (strstr(name, "_tmeta")) {
-		log_error("Names including \"_tpool\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
+	const char *reserved_prefixes[] = {
+		"snapshot",
+		"pvmove",
+		NULL
+	};
+
+	const char *reserved_strings[] = {
+		"_mlog",
+		"_mimage",
+		"_rimage",
+		"_rmeta",
+		"_vorigin",
+		"_tpool",
+		"_tmeta",
+		NULL
+	};
+
+	unsigned i;
+	const char *s;
+
+	for (i = 0; (s = reserved_prefixes[i]); i++) {
+		if (!strncmp(name, s, strlen(s))) {
+			log_error("Names starting \"%s\" are reserved. "
+				  "Please choose a different LV name.", s);
+			return 0;
+		}
+	}
+
+	for (i = 0; (s = reserved_strings[i]); i++) {
+		if (strstr(name, s)) {
+			log_error("Names including \"%s\" are reserved. "
+				  "Please choose a different LV name.", s);
+			return 0;
+		}
 	}
 
 	return 1;


