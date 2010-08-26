From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 26 Aug 2010 12:08:20 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.h
Message-ID: <20100826120820.27742.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-08-26 12:08:20

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.h 

Log message:
	Fix return type qualifier to avoid compiler warning.
	
	introduced in commit b16b4d92a7bd80b61b85c5db857173a8f0567374
	"Improve various log messages."
	
	fixes a lot of
	../include/metadata.h:148: warning: type qualifiers ignored on function return type

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1723&r2=1.1724
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.217&r2=1.218

--- LVM2/WHATS_NEW	2010/08/23 11:37:02	1.1723
+++ LVM2/WHATS_NEW	2010/08/26 12:08:19	1.1724
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 ==================================
+  Fix return type qualifier to avoid compiler warning. (2.02.69)
   Automatically generate LSB Requires-Start for clvmd init script.
   Fix return code of pvmove --abort PV.
   Fix pvmove --abort to remove even for empty pvmove LV.
--- LVM2/lib/metadata/metadata.h	2010/08/20 12:43:49	1.217
+++ LVM2/lib/metadata/metadata.h	2010/08/26 12:08:19	1.218
@@ -145,7 +145,7 @@
 	 * Per location description for logging.
 	 */
 	const char *(*mda_metadata_locn_name) (void *metadata_locn);
-	uint64_t const (*mda_metadata_locn_offset) (void *metadata_locn);
+	uint64_t (*mda_metadata_locn_offset) (void *metadata_locn);
 
 	/*
 	 * Returns number of free sectors in given metadata area.


