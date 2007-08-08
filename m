From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Aug 2007 18:00:37 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20070808180037.18571.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-08 18:00:37

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Remove extra checks for sub LV renaming.
	Patch by Jun'ichi Nomura <j-nomura@ce.jp.nec.com>.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122

--- LVM2/lib/metadata/lv_manip.c	2007/08/07 18:55:38	1.121
+++ LVM2/lib/metadata/lv_manip.c	2007/08/08 18:00:36	1.122
@@ -1491,25 +1491,7 @@
 }
 
 /*
- * Returns a pointer to LV name suffix.
- * Returns NULL if the LV doesn't have suffix.
- */
-static char *_sub_lv_name_suffix(const char *lvname)
-{
-	char *s;
-
-	if ((s = strstr(lvname, "_mimage")))
-		return s;
-
-	if ((s = strstr(lvname, "_mlog")))
-		return s;
-
-	return NULL;
-}
-
-/*
  * Rename sub LV.
- * If a new name for the sub LV cannot be determined, 1 is returned.
  * 'lv_name_old' and 'lv_name_new' are old and new names of the main LV.
  */
 static int _rename_sub_lv(struct cmd_context *cmd,
@@ -1519,14 +1501,18 @@
 	char *suffix, *new_name;
 	size_t len;
 
-	/* Rename only if the lv has known suffix */
-	if (!(suffix = _sub_lv_name_suffix(lv->name)))
-		return 1;
-
-	/* Make sure that lv->name is exactly a lv_name_old + suffix */
-	len = suffix - lv->name;
-	if (strlen(lv_name_old) != len || strncmp(lv->name, lv_name_old, len))
-		return 1;
+	/*
+	 * A sub LV name starts with lv_name_old + '_'.
+	 * The suffix follows lv_name_old and includes '_'.
+	 */
+	len = strlen(lv_name_old);
+	if (strncmp(lv->name, lv_name_old, len) || lv->name[len] != '_') {
+		log_error("Cannot rename \"%s\": name format not recognized "
+			  "for internal LV \"%s\"",
+			  lv_name_old, lv->name);
+		return 0;
+	}
+	suffix = lv->name + len;
 
  	/*
 	 * Compose a new name for sub lv:


