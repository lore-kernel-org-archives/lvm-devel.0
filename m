From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Nov 2006 17:36:01 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c
Message-ID: <20061116173601.4417.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-16 17:36:01

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 

Log message:
	Warn if certain duplicate config file entries are seen.
	(not thoroughly tested)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.498&r2=1.499
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/WHATS_NEW	2006/11/16 16:44:48	1.498
+++ LVM2/WHATS_NEW	2006/11/16 17:36:00	1.499
@@ -1,5 +1,6 @@
 Version 2.02.15 -
 ====================================
+  Warn if certain duplicate config file entries are seen.
   Enhance lvm_dump.sh for sysreport integration and add man page.
   Fix --autobackup argument which could never disable backups.
   Fix a label_verify error path.
--- LVM2/lib/config/config.c	2006/11/04 03:34:09	1.48
+++ LVM2/lib/config/config.c	2006/11/16 17:36:00	1.49
@@ -772,6 +772,7 @@
 					     const char *path)
 {
 	const char *e;
+	const struct config_node *cn_found;
 
 	while (cn) {
 		/* trim any leading slashes */
@@ -782,22 +783,30 @@
 		for (e = path; *e && (*e != sep); e++) ;
 
 		/* hunt for the node */
+		cn_found = NULL;
 		while (cn) {
-			if (_tok_match(cn->key, path, e))
-				break;
+			if (_tok_match(cn->key, path, e)) {
+				/* Inefficient */
+				if (!cn_found)
+					cn_found = cn;
+				else
+					log_error("WARNING: Ignoring duplicate"
+						  " config node: %s ("
+						  "seeking %s)", cn->key, path);
+			}
 
 			cn = cn->sib;
 		}
 
-		if (cn && *e)
-			cn = cn->child;
+		if (cn_found && *e)
+			cn = cn_found->child;
 		else
 			break;	/* don't move into the last node */
 
 		path = e;
 	}
 
-	return (struct config_node *) cn;
+	return (struct config_node *) cn_found;
 }
 
 static struct config_node *_find_first_config_node(const struct config_node *cn1,


