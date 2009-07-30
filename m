From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 30 Jul 2009 17:41:02 -0000
Subject: LVM2/lib/format_text format-text.c
Message-ID: <20090730174102.26972.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-30 17:41:02

Modified files:
	lib/format_text: format-text.c 

Log message:
	Remove legacy support for preserving pe_start if a PV already has data
	areas.
	
	This preserved pe_start would quickly be readjusted to follow the first
	mda anyway.  An example use-case that hit this code path is: running
	pvcreate on an already existing PV _without_ a preceeding pvremove.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109

--- LVM2/lib/format_text/format-text.c	2009/07/30 17:19:31	1.108
+++ LVM2/lib/format_text/format-text.c	2009/07/30 17:41:01	1.109
@@ -1327,7 +1327,6 @@
 	char buf[MDA_HEADER_SIZE] __attribute((aligned(8)));
 	struct mda_header *mdah = (struct mda_header *) buf;
 	uint64_t adjustment;
-	struct data_area_list *da;
 
 	/* FIXME Test mode don't update cache? */
 
@@ -1364,16 +1363,9 @@
 		dm_list_init(&info->mdas);
 	}
 
-	/*
-	 * If no pe_start supplied but PV already exists,
-	 * preserve existing value.
-	 */
-	if (info->das.n) {
-		if (!pv->pe_start)
-			dm_list_iterate_items(da, &info->das)
-				pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
+	if (info->das.n)
 		del_das(&info->das);
-	} else
+	else
 		dm_list_init(&info->das);
 
 	/*


