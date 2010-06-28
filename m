From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:32:22 -0000
Subject: LVM2/lib/display display.c
Message-ID: <20100628203222.14760.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:32:21

Modified files:
	lib/display    : display.c 

Log message:
	Use vg_mda_count() in vgdisplay.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/lib/display/display.c	2009/12/11 13:16:37	1.109
+++ LVM2/lib/display/display.c	2010/06/28 20:32:21	1.110
@@ -664,7 +664,7 @@
 	log_print("Format                %s", vg->fid->fmt->name);
 	if (vg->fid->fmt->features & FMT_MDAS) {
 		log_print("Metadata Areas        %d",
-			  dm_list_size(&vg->fid->metadata_areas));
+			  vg_mda_count(vg));
 		log_print("Metadata Sequence No  %d", vg->seqno);
 	}
 	access_str = vg->status & (LVM_READ | LVM_WRITE);


