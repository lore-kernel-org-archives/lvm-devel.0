From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:12:33 -0000
Subject: LVM2/lib/metadata metadata.c pv.h
Message-ID: <20110221121233.29265.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:12:32

Modified files:
	lib/metadata   : metadata.c pv.h 

Log message:
	Initialise a new PV-based format instance for a PV that is being created.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.427&r2=1.428
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/lib/metadata/metadata.c	2011/02/21 12:10:58	1.427
+++ LVM2/lib/metadata/metadata.c	2011/02/21 12:12:32	1.428
@@ -1555,6 +1555,7 @@
 	if (!pv)
 		return_NULL;
 
+	pv->fid = NULL;
 	pv->pe_size = 0;
 	pv->pe_start = 0;
 	pv->pe_count = 0;
@@ -1606,6 +1607,7 @@
 				  unsigned metadataignore, struct dm_list *mdas)
 {
 	const struct format_type *fmt = cmd->fmt;
+	struct format_instance_ctx fic;
 	struct dm_pool *mem = fmt->cmd->mem;
 	struct physical_volume *pv = _alloc_pv(mem, dev);
 
@@ -1646,6 +1648,13 @@
 		goto bad;
 	}
 
+	fic.type = FMT_INSTANCE_PV;
+	fic.context.pv_id = (const char *) &pv->id;
+	if (!(pv->fid = fmt->ops->create_instance(fmt, &fic))) {
+		log_error("Couldn't create format instance for PV %s.", pv_dev_name(pv));
+		goto bad;
+	}
+
 	pv->fmt = fmt;
 	pv->vg_name = fmt->orphan_vg_name;
 
--- LVM2/lib/metadata/pv.h	2010/10/25 12:01:59	1.8
+++ LVM2/lib/metadata/pv.h	2011/02/21 12:12:32	1.9
@@ -24,6 +24,7 @@
 	struct id id;
 	struct device *dev;
 	const struct format_type *fmt;
+	struct format_instance *fid;
 
 	/*
 	 * vg_name and vgid are used before the parent VG struct exists.


