From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Nov 2010 10:19:31 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/lvm-string.c lib/mis ...
Message-ID: <20101117101931.20959.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-11-17 10:19:30

Modified files:
	.              : WHATS_NEW 
	lib/misc       : lvm-string.c lvm-string.h 
	man            : lvm.8.in 
	tools          : lvmcmdline.c toollib.c 

Log message:
	Remove tag length restriction and allow / = ! : # & characters.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1797&r2=1.1798
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.211&r2=1.212

--- LVM2/WHATS_NEW	2010/11/12 16:04:52	1.1797
+++ LVM2/WHATS_NEW	2010/11/17 10:19:29	1.1798
@@ -1,5 +1,6 @@
 Version 2.02.77 -
 ===================================
+  Remove tag length restriction and allow / = ! : # & characters.
   Support repetition of --addtag and --deltag arguments.
   Add infrastructure for specific cmdline arguments to be repeated in groups.
   Split the_args cmdline arguments and values into arg_props and arg_values.
--- LVM2/lib/misc/lvm-string.c	2010/09/28 01:29:07	1.23
+++ LVM2/lib/misc/lvm-string.c	2010/11/17 10:19:30	1.24
@@ -286,6 +286,25 @@
 }
 
 /*
+ * A-Za-z0-9._-+/=!:&#
+ */
+int validate_tag(const char *n)
+{
+	register char c;
+	register int len = 0;
+
+	if (!n || !*n)
+		return 0;
+
+	while ((len++, c = *n++))
+		if (!isalnum(c) && c != '.' && c != '_' && c != '-' && c != '+' && c != '/'
+		    && c != '=' && c != '!' && c != ':' && c != '&' && c != '#')
+			return 0;
+
+	return 1;
+}
+
+/*
  * Device layer names are all of the form <vg>-<lv>-<layer>, any
  * other hyphens that appear in these names are quoted with yet
  * another hyphen.  The top layer of any device has no layer
--- LVM2/lib/misc/lvm-string.h	2010/09/23 12:02:34	1.21
+++ LVM2/lib/misc/lvm-string.h	2010/11/17 10:19:30	1.22
@@ -33,6 +33,7 @@
 		    const char *layer);
 
 int validate_name(const char *n);
+int validate_tag(const char *n);
 
 int apply_lvname_restrictions(const char *name);
 int is_reserved_lvname(const char *name);
--- LVM2/man/lvm.8.in	2010/05/20 13:47:22	1.5
+++ LVM2/man/lvm.8.in	2010/11/17 10:19:30	1.6
@@ -205,6 +205,7 @@
 .TP
 \fB--addtag tag\fP
 Add the tag \fBtag\fP to a PV, VG or LV.  
+Supply this argument multiple times to add more than one tag at once.
 A tag is a word that can be used to group LVM2 objects of the same type 
 together. 
 Tags can be given on the command line in place of PV, VG or LV 
@@ -221,10 +222,13 @@
 LVM1 metadata format cannot be tagged because the on-disk format does not
 support it.
 Snapshots cannot be tagged.
-Characters allowed in tags are: A-Z a-z 0-9 _ + . -
+Characters allowed in tags are: A-Z a-z 0-9 _ + . - and 
+as of version 2.02.78 the following characters are also
+accepted: / = ! : # &
 .TP
 \fB--deltag tag\fP
 Delete the tag \fBtag\fP from a PV, VG or LV, if it's present.
+Supply this argument multiple times to remove more than one tag at once.
 .TP
 \fB--alloc AllocationPolicy\fP
 The allocation policy to use: \fBcontiguous\fP, \fBcling\fP, \fBnormal\fP, \fBanywhere\fP or \fBinherit\fP.
--- LVM2/tools/lvmcmdline.c	2010/11/11 17:29:06	1.130
+++ LVM2/tools/lvmcmdline.c	2010/11/17 10:19:30	1.131
@@ -418,7 +418,7 @@
 	if (*pos == '@')
 		pos++;
 
-	if (!validate_name(pos))
+	if (!validate_tag(pos))
 		return 0;
 
 	av->value = pos;
--- LVM2/tools/toollib.c	2010/11/09 12:34:43	1.211
+++ LVM2/tools/toollib.c	2010/11/17 10:19:30	1.212
@@ -222,7 +222,7 @@
 			vgname = lv_name;
 
 			if (*vgname == '@') {
-				if (!validate_name(vgname + 1)) {
+				if (!validate_tag(vgname + 1)) {
 					log_error("Skipping invalid tag %s",
 						  vgname);
 					continue;
@@ -528,7 +528,7 @@
 		for (; opt < argc; opt++) {
 			vg_name = argv[opt];
 			if (*vg_name == '@') {
-				if (!validate_name(vg_name + 1)) {
+				if (!validate_tag(vg_name + 1)) {
 					log_error("Skipping invalid tag %s",
 						  vg_name);
 					if (ret_max < EINVALID_CMD_LINE)
@@ -698,7 +698,7 @@
 			if (at_sign && (at_sign == argv[opt])) {
 				tagname = at_sign + 1;
 
-				if (!validate_name(tagname)) {
+				if (!validate_tag(tagname)) {
 					log_error("Skipping invalid tag %s",
 						  tagname);
 					if (ret_max < EINVALID_CMD_LINE)
@@ -1113,7 +1113,7 @@
 
 		if (at_sign && (at_sign == argv[i])) {
 			tagname = at_sign + 1;
-			if (!validate_name(tagname)) {
+			if (!validate_tag(tagname)) {
 				log_error("Skipping invalid tag %s", tagname);
 				continue;
 			}


