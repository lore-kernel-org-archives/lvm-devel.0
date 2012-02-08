From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 12:57:16 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/misc ...
Message-ID: <20120208125716.27071.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 12:57:15

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/misc       : lvm-string.c 

Log message:
	Some fixmes
	
	'len' calculation is unused ?
	Unreachable code could be removed or moved upward ?

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2270&r2=1.2271
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/WHATS_NEW	2012/02/08 12:52:58	1.2270
+++ LVM2/WHATS_NEW	2012/02/08 12:57:15	1.2271
@@ -1,7 +1,7 @@
 Version 2.02.91 -
 ===================================
-  Switch int to void return for str_list_del()
-  Fix error path handling in _build_desc()
+  Switch int to void return for str_list_del().
+  Fix error path handling in _build_desc().
   Add range test for device number in _scan_proc_dev().
   Use signed long for sysconf() call in cmirrord.
   Do not write in front of log buffer in print_log().
--- LVM2/lib/cache/lvmcache.c	2011/12/18 21:56:03	1.121
+++ LVM2/lib/cache/lvmcache.c	2012/02/08 12:57:15	1.122
@@ -987,6 +987,7 @@
 	if (vginfo && *vginfo->vgid)
 		dm_hash_remove(_vgid_hash, vginfo->vgid);
 	if (!vgid) {
+		/* FIXME: unreachable code path */
 		log_debug("lvmcache: %s: clearing VGID", info ? dev_name(info->dev) : vginfo->vgname);
 		return 1;
 	}
--- LVM2/lib/misc/lvm-string.c	2011/11/03 14:38:36	1.32
+++ LVM2/lib/misc/lvm-string.c	2012/02/08 12:57:15	1.33
@@ -49,12 +49,13 @@
 int validate_tag(const char *n)
 {
 	register char c;
-	register int len = 0;
+	/* int len = 0; */
 
 	if (!n || !*n)
 		return 0;
 
-	while ((len++, c = *n++))
+	/* FIXME: Is unlimited tag size support needed ? */
+	while ((/* len++, */ c = *n++))
 		if (!isalnum(c) && c != '.' && c != '_' && c != '-' && c != '+' && c != '/'
 		    && c != '=' && c != '!' && c != ':' && c != '&' && c != '#')
 			return 0;


