From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:37:10 -0000
Subject: LVM2/lib/format_text export.c import_vsn1.c
Message-ID: <20100628203710.18258.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:37:10

Modified files:
	lib/format_text: export.c import_vsn1.c 

Log message:
	Make vg->mda_copies persistent in on disk vg metadata.
	
	This patch adds the ability to read/write the vg->mda_copies values
	from/to the vg metadata.
	
	If we read the VG metadata and this field does not exist, we set
	mda_copies to the default value of 0.  Later in the code, we use
	this special '0' value to indicate a disable of metadata balancing.
	This should preserve existing LVM behavior and ensure metadata balancing
	can be turned off should the need arise.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/lib/format_text/export.c	2010/01/07 14:45:28	1.75
+++ LVM2/lib/format_text/export.c	2010/06/28 20:37:10	1.76
@@ -397,6 +397,7 @@
 		outf(f, "allocation_policy = \"%s\"",
 		     get_alloc_string(vg->alloc));
 	}
+	outf(f, "metadata_copies = %u", vg->mda_copies);
 
 	return 1;
 }
--- LVM2/lib/format_text/import_vsn1.c	2010/05/05 22:37:53	1.75
+++ LVM2/lib/format_text/import_vsn1.c	2010/06/28 20:37:10	1.76
@@ -23,6 +23,7 @@
 #include "pv_alloc.h"
 #include "segtype.h"
 #include "text_import.h"
+#include "defaults.h"
 
 typedef int (*section_fn) (struct format_instance * fid, struct dm_pool * mem,
 			   struct volume_group * vg, struct config_node * pvn,
@@ -745,6 +746,10 @@
 			return_0;
 	}
 
+	if (!_read_uint32(vgn, "metadata_copies", &vg->mda_copies)) {
+		vg->mda_copies = DEFAULT_VGMETADATACOPIES;
+	}
+
 	/*
 	 * The pv hash memorises the pv section names -> pv
 	 * structures.


