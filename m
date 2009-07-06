From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 6 Jul 2009 19:17:16 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090706191716.4716.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-06 19:17:16

Modified files:
	.              : WHATS_NEW 

Log message:
	Reword the WHATS_NEW commandline sizes update.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1165&r2=1.1166

--- LVM2/WHATS_NEW	2009/07/06 19:13:26	1.1165
+++ LVM2/WHATS_NEW	2009/07/06 19:17:15	1.1166
@@ -1,7 +1,7 @@
 Version 2.02.49 - 
 ================================
   Update the man pages to document size units uniformly.
-  Allow specifying commandline sizes in terms of bytes and sectors.
+  Allow commandline sizes to be specified in terms of bytes and sectors.
   Update 'md_chunk_alignment' to use stripe-width to align PV data area.
   Update test/t-inconsistent-metadata.sh to match new vg_read interface.
   Add lvmcache_init() to polldaemon initialization.


