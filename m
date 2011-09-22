From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 22 Sep 2011 15:36:22 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20110922153622.13112.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-22 15:36:21

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	Disallow the creation of mirrors (mirror or raid1 segtype) with only one leg.
	
	If you specify the segment type (e.g. --type mirror) and the mirrors argument
	as zero, it would result in a mirrored LV with only one image.  While the device
	may be valid in theory, it should not be allowed in practice.  It also makes it
	difficult on the conversion tools, since they react badly to single-image
	mirrors.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2129&r2=1.2130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.241&r2=1.242

--- LVM2/WHATS_NEW	2011/09/22 09:47:34	1.2129
+++ LVM2/WHATS_NEW	2011/09/22 15:36:21	1.2130
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Disallow the creation of mirrors (mirror or raid1 segtype) with only one leg.
   Cleanup restart clvmd code (no memory allocation, debug print passed args).
   Add all exclusive locks to clvmd restart option args.
   Always send the whole clvmd packet header in refresh commands.
--- LVM2/tools/lvcreate.c	2011/09/15 15:26:40	1.241
+++ LVM2/tools/lvcreate.c	2011/09/22 15:36:21	1.242
@@ -618,8 +618,13 @@
 
 	if (arg_count(cmd, mirrors_ARG)) {
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
-		if (lp->mirrors == 1)
+		if (lp->mirrors == 1) {
+			if (segtype_is_mirrored(lp->segtype)) {
+				log_error("Image count for segtype \"%s\" cannot be 0.", lp->segtype->name);
+				return 0;
+			}
 			log_print("Redundant mirrors argument: default is 0");
+		}
 		if (arg_sign_value(cmd, mirrors_ARG, 0) == SIGN_MINUS) {
 			log_error("Mirrors argument may not be negative");
 			return 0;


