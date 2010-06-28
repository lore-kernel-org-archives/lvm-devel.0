From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:34:24 -0000
Subject: LVM2/lib/format_text text_label.c
Message-ID: <20100628203424.16077.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:34:24

Modified files:
	lib/format_text: text_label.c 

Log message:
	Implement ignore of mda if bit set by skipping r/w of metadata.
	
	We implement ignore of an mda at label_read time by checking for
	the ignore bit, and then skipping the reading of the vgname and
	other information in the metadata.  This will have an effect similar
	to a PV found with no mdas.  Thus, it will look like an orphan in the
	cache until we scan the rest of the system and find a PV with
	metadata, and the mda will not be on the vg->fid->metadata_areas
	list so no read/writes will be done to the metadata area.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/lib/format_text/text_label.c	2010/06/28 20:31:18	1.31
+++ LVM2/lib/format_text/text_label.c	2010/06/28 20:34:24	1.32
@@ -311,6 +311,12 @@
 		}
 		mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
 
+		if (mda_is_ignored(mda)) {
+			if (!dev_close(mdac->area.dev))
+				stack;
+			continue;
+		}
+
 		if ((vgname = vgname_from_mda(info->fmt, mdah,
 					      &mdac->area,
 					      &vgid, &vgstatus, &creation_host,


