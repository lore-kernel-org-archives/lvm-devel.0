From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Nov 2008 09:53:34 -0000
Subject: LVM2 lib/misc/last-path-component.h tools/lvmc ...
Message-ID: <20081112095334.15933.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-11-12 09:53:33

Modified files:
	lib/misc       : last-path-component.h 
	tools          : lvmcmdline.c 

Log message:
	cleaner const char* usage for last_path_component()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/last-path-component.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/lib/misc/last-path-component.h	2008/07/31 15:38:51	1.2
+++ LVM2/lib/misc/last-path-component.h	2008/11/12 09:53:33	1.3
@@ -19,10 +19,9 @@
 
 #include <string.h>
 
-static inline char *last_path_component(char const *name)
+static inline const char *last_path_component(char const *name)
 {
 	char const *slash = strrchr(name, '/');
-	char const *res = slash ? slash + 1 : name;
 
-	return (char *)res;
+	return (slash) ? slash + 1 : name;
 }
--- LVM2/tools/lvmcmdline.c	2008/11/12 09:49:06	1.73
+++ LVM2/tools/lvmcmdline.c	2008/11/12 09:53:33	1.74
@@ -483,7 +483,7 @@
 static struct command *_find_command(const char *name)
 {
 	int i;
-	char *base;
+	const char *base;
 
 	base = last_path_component(name);
 


