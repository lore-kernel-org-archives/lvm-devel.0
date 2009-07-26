From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 12:40:28 -0000
Subject: LVM2/lib/format_text archive.c
Message-ID: <20090726124028.14687.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 12:40:28

Modified files:
	lib/format_text: archive.c 

Log message:
	Rename vg_size to vgsize to avoid naming conflicts.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/lib/format_text/archive.c	2009/07/15 20:02:47	1.35
+++ LVM2/lib/format_text/archive.c	2009/07/26 12:40:27	1.36
@@ -57,7 +57,7 @@
 /*
  * Extract vg name and version number from a filename.
  */
-static int _split_vg(const char *filename, char *vgname, size_t vg_size,
+static int _split_vg(const char *filename, char *vgname, size_t vgsize,
 		     uint32_t *ix)
 {
 	size_t len, vg_len;
@@ -78,7 +78,7 @@
 		return 0;
 
 	vg_len = underscore - filename;
-	if (vg_len + 1 > vg_size)
+	if (vg_len + 1 > vgsize)
 		return 0;
 
 	strncpy(vgname, filename, vg_len);


