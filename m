From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Jul 2007 11:17:22 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20070702111722.16421.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-07-02 11:17:21

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c dev_manager.c 
	lib/format_text: archive.c format-text.c 
	lib/snapshot   : snapshot.c 

Log message:
	Don't use index and rindex functions marked by SUSv3 as legacy - Jakub Bogusz <qboosh@pld-linux.org>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.643&r2=1.644
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/WHATS_NEW	2007/06/28 17:59:34	1.643
+++ LVM2/WHATS_NEW	2007/07/02 11:17:20	1.644
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Don't use index and rindex functions marked by SUSv3 as legacy.
   Fix vgsplit if splitting all PVs from VG.
   Fix lvmdiskscan volume reporting when run in the lvm shell
   Fix missing lvm_shell symbol in lvm2cmd library. (2.02.23)
--- LVM2/lib/activate/activate.c	2007/06/28 17:33:43	1.123
+++ LVM2/lib/activate/activate.c	2007/07/02 11:17:21	1.124
@@ -313,7 +313,7 @@
 			else
 				continue;
 		}
-		if (!index(str, '/')) {
+		if (!strchr(str, '/')) {
 			/* vgname supplied */
 			if (!strcmp(str, lv->vg->name))
 				return 1;
--- LVM2/lib/activate/dev_manager.c	2007/05/15 14:42:01	1.124
+++ LVM2/lib/activate/dev_manager.c	2007/07/02 11:17:21	1.125
@@ -561,7 +561,7 @@
 	log_debug("Getting device info for %s", dl->name);
 
 	/* Rename? */
-		if ((suffix = rindex(dl->dlid + sizeof(UUID_PREFIX) - 1, '-')))
+		if ((suffix = strrchr(dl->dlid + sizeof(UUID_PREFIX) - 1, '-')))
 			suffix++;
 		newname = build_dm_name(dm->mem, dm->vg_name, dl->lv->name,
 					suffix);
--- LVM2/lib/format_text/archive.c	2007/06/08 22:38:48	1.26
+++ LVM2/lib/format_text/archive.c	2007/07/02 11:17:21	1.27
@@ -71,7 +71,7 @@
 	if (strcmp(".vg", dot))
 		return 0;
 
-	if (!(underscore = rindex(filename, '_')))
+	if (!(underscore = strrchr(filename, '_')))
 		return 0;
 
 	if (sscanf(underscore + 1, "%u", ix) != 1)
--- LVM2/lib/format_text/format-text.c	2007/06/28 17:33:44	1.76
+++ LVM2/lib/format_text/format-text.c	2007/07/02 11:17:21	1.77
@@ -850,7 +850,7 @@
 	char *slash;
 	char temp_file[PATH_MAX], temp_dir[PATH_MAX];
 
-	slash = rindex(tc->path_edit, '/');
+	slash = strrchr(tc->path_edit, '/');
 
 	if (slash == 0)
 		strcpy(temp_dir, ".");
@@ -948,7 +948,7 @@
 		return 0;
 
 	/* vgrename? */
-	if ((slash = rindex(tc->path_live, '/')))
+	if ((slash = strrchr(tc->path_live, '/')))
 		slash = slash + 1;
 	else
 		slash = tc->path_live;
--- LVM2/lib/snapshot/snapshot.c	2006/10/18 18:01:52	1.19
+++ LVM2/lib/snapshot/snapshot.c	2007/07/02 11:17:21	1.20
@@ -98,7 +98,7 @@
 	float percent2;
 	uint64_t numerator, denominator;
 
-	if (index(params, '/')) {
+	if (strchr(params, '/')) {
 		if (sscanf(params, "%" PRIu64 "/%" PRIu64,
 			   &numerator, &denominator) == 2) {
 			*total_numerator += numerator;


