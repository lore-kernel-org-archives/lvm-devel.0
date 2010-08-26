From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 26 Aug 2010 12:22:05 -0000
Subject: LVM2/lib/format_text format-text.c
Message-ID: <20100826122205.3576.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-08-26 12:22:05

Modified files:
	lib/format_text: format-text.c 

Log message:
	Fix previous const removal.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144

--- LVM2/lib/format_text/format-text.c	2010/08/20 20:59:07	1.143
+++ LVM2/lib/format_text/format-text.c	2010/08/26 12:22:05	1.144
@@ -1649,7 +1649,7 @@
 	return dev_name(mdac->area.dev);
 }
 
-static uint64_t const _metadata_locn_offset_raw(void *metadata_locn)
+static uint64_t _metadata_locn_offset_raw(void *metadata_locn)
 {
 	struct mda_context *mdac = (struct mda_context *) metadata_locn;
 


