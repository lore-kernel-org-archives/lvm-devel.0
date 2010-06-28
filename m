From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:29:42 -0000
Subject: LVM2/lib/format_text layout.h
Message-ID: <20100628202942.12703.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:29:42

Modified files:
	lib/format_text: layout.h 

Log message:
	Change 'filler' to 'flags' in on-disk 'raw_locn' structure.
	
	Future patches will make use of a specific flag in the on-disk 'raw_locn'
	structure to enable/disable metadata areas, and facilitate metadata
	balancing.
	
	Note that 'filler' is always set to '0' (see add_mda() - memset),
	so use of this area as a non-zero flags field is a safe way to
	provide future code features.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/layout.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/lib/format_text/layout.h	2008/11/03 22:14:28	1.9
+++ LVM2/lib/format_text/layout.h	2010/06/28 20:29:42	1.10
@@ -51,7 +51,7 @@
 	uint64_t offset;	/* Offset in bytes to start sector */
 	uint64_t size;		/* Bytes */
 	uint32_t checksum;
-	uint32_t filler;
+	uint32_t flags;
 } __attribute__ ((packed));
 
 /* On disk */


