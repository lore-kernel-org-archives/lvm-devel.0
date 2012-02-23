From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 22:36:25 -0000
Subject: LVM2/lib/config config.c
Message-ID: <20120223223625.18438.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 22:36:22

Modified files:
	lib/config     : config.c 

Log message:
	Drop const modifier from fb
	
	It's not useful here to use const - since we need non-const value for unmap.
	Also remove now unneeded cast.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113

--- LVM2/lib/config/config.c	2012/01/23 17:46:31	1.112
+++ LVM2/lib/config/config.c	2012/02/23 22:36:21	1.113
@@ -190,7 +190,7 @@
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum)
 {
-	const char *fb, *fe;
+	char *fb, *fe;
 	int r = 0;
 	int use_mmap = 1;
 	off_t mmap_offset = 0;
@@ -240,7 +240,7 @@
 		dm_free(buf);
 	else {
 		/* unmap the file */
-		if (munmap((char *) (fb - mmap_offset), size + mmap_offset)) {
+		if (munmap(fb - mmap_offset, size + mmap_offset)) {
 			log_sys_error("munmap", dev_name(dev));
 			r = 0;
 		}


