From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Mar 2012 02:42:32 -0000
Subject: LVM2 tools/dmsetup.c libdm/libdm-common.c
Message-ID: <20120306024232.13259.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-06 02:42:32

Modified files:
	tools          : dmsetup.c 
	libdm          : libdm-common.c 

Log message:
	Adjust wording

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.186&r2=1.187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148

--- LVM2/tools/dmsetup.c	2012/03/05 12:48:13	1.186
+++ LVM2/tools/dmsetup.c	2012/03/06 02:42:31	1.187
@@ -2945,7 +2945,7 @@
 						  : DEFAULT_DM_NAME_MANGLING;
 
 	if (target_format == DM_STRING_MANGLING_AUTO && strstr(name, "\\x5cx")) {
-		log_error("The name \"%s\" seems to be multiple mangled. "
+		log_error("The name \"%s\" seems to be mangled more than once. "
 			  "Manual intervention required to rename the device.", name);
 		goto out;
 	}
--- LVM2/libdm/libdm-common.c	2012/03/05 12:48:12	1.147
+++ LVM2/libdm/libdm-common.c	2012/03/06 02:42:31	1.148
@@ -329,7 +329,7 @@
 int check_multiple_mangled_name_allowed(dm_string_mangling_t mode, const char *name)
 {
 	if (mode == DM_STRING_MANGLING_AUTO && strstr(name, "\\x5cx")) {
-		log_error("The name \"%s\" seems to be multiple mangled. "
+		log_error("The name \"%s\" seems to be mangled more than once. "
 			  "This is not allowed in auto mode.", name);
 		return 0;
 	}


