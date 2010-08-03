From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Aug 2010 13:24:07 -0000
Subject: LVM2 ./WHATS_NEW libdm/mm/dbg_malloc.c
Message-ID: <20100803132407.14566.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-08-03 13:24:07

Modified files:
	.              : WHATS_NEW 
	libdm/mm       : dbg_malloc.c 

Log message:
	Fix 'void*' arithmetic warnings in dbg_malloc.c.
	Use more readable char[idx] access instead of *char+idx access.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1692&r2=1.1693
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/WHATS_NEW	2010/08/03 13:16:21	1.1692
+++ LVM2/WHATS_NEW	2010/08/03 13:24:07	1.1693
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Fix 'void*' arithmetic warnings in dbg_malloc.c.
   Fix 'void*' arithmetic warning in some functions from libdm-iface.c.
   Fix const warning in dev_manager_info() and _dev_manager_lv_rmnodes().
   Fix const warning in archive_file structure from archive.c.
--- LVM2/libdm/mm/dbg_malloc.c	2010/07/09 15:34:47	1.18
+++ LVM2/libdm/mm/dbg_malloc.c	2010/08/03 13:24:07	1.19
@@ -196,12 +196,12 @@
 		for (c = 0; c < sizeof(str) - 1; c++) {
 			if (c >= mb->length)
 				str[c] = ' ';
-			else if (*(char *)(mb->magic + c) == '\0')
+			else if (((char *)mb->magic)[c] == '\0')
 				str[c] = '\0';
-			else if (*(char *)(mb->magic + c) < ' ')
+			else if (((char *)mb->magic)[c] < ' ')
 				str[c] = '?';
 			else
-				str[c] = *(char *)(mb->magic + c);
+				str[c] = ((char *)mb->magic)[c];
 		}
 		str[sizeof(str) - 1] = '\0';
 


