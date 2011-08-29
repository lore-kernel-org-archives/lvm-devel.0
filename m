From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 29 Aug 2011 13:37:37 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20110829133737.30499.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-08-29 13:37:37

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Directly allocate buffer memory in a pvck scan instead of using a mempool.
	
	There's a very high memory usage when calling _pv_analyse_mda_raw (e.g. while
	executing pvck) that can end up with "out of memory".
	
	_pv_analyse_mda_raw scans for metadata in the MDA, iteratively increasing the
	size to scan with SECTOR_SIZE until we find a probable config section or we're
	at the edge of the metadata area. However, when using a memory pool, we're also
	iteratively chasing for bigger and bigger mempool chunk which can't be found
	and so we're always allocating a new one, consuming more and more memory...
	
	This patch just changes the mempool to direct memory allocation in this
	problematic part of the code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2084&r2=1.2085
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.183&r2=1.184

--- LVM2/WHATS_NEW	2011/08/24 13:41:46	1.2084
+++ LVM2/WHATS_NEW	2011/08/29 13:37:36	1.2085
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Directly allocate buffer memory in a pvck scan instead of using a mempool.
   Add configure --with-thin for (unimplemented) segtypes "thin" and "thin_pool".
   Fix raid shared lib segtype registration (2.02.87).
 
--- LVM2/lib/format_text/format-text.c	2011/08/10 20:25:30	1.183
+++ LVM2/lib/format_text/format-text.c	2011/08/29 13:37:37	1.184
@@ -226,7 +226,7 @@
 		 * "maybe_config_section" returning true when there's no valid
 		 * metadata in a sector (sectors with all nulls).
 		 */
-		if (!(buf = dm_pool_alloc(fmt->cmd->mem, size + size2)))
+		if (!(buf = dm_malloc(size + size2)))
 			goto_out;
 
 		if (!dev_read_circular(area->dev, offset, size,
@@ -261,14 +261,14 @@
 				size += SECTOR_SIZE;
 			}
 		}
-		dm_pool_free(fmt->cmd->mem, buf);
+		dm_free(buf);
 		buf = NULL;
 	}
 
 	r = 1;
  out:
 	if (buf)
-		dm_pool_free(fmt->cmd->mem, buf);
+		dm_free(buf);
 	if (!dev_close(area->dev))
 		stack;
 	return r;


