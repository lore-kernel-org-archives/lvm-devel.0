From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2008 15:38:52 -0000
Subject: LVM2 lib/misc/last-path-component.h tools/lvmc ...
Message-ID: <20080731153852.20945.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-07-31 15:38:52

Modified files:
	lib/misc       : last-path-component.h 
	tools          : lvmcmdline.c 

Log message:
	remove now-redundant slash-stripping

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/last-path-component.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/lib/misc/last-path-component.h	2007/10/03 16:10:04	1.1
+++ LVM2/lib/misc/last-path-component.h	2008/07/31 15:38:51	1.2
@@ -21,7 +21,8 @@
 
 static inline char *last_path_component(char const *name)
 {
-	char const *slash = strrchr (name, '/');
+	char const *slash = strrchr(name, '/');
 	char const *res = slash ? slash + 1 : name;
-	return (char *) res;
+
+	return (char *)res;
 }
--- LVM2/tools/lvmcmdline.c	2008/06/06 19:28:35	1.67
+++ LVM2/tools/lvmcmdline.c	2008/07/31 15:38:52	1.68
@@ -1165,8 +1165,6 @@
 	_close_stray_fds();
 
 	base = last_path_component(argv[0]);
-	while (*base == '/')
-		base++;
 	if (strcmp(base, "lvm") && strcmp(base, "lvm.static") &&
 	    strcmp(base, "initrd-lvm"))
 		alias = 1;


