From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 3 Mar 2009 16:35:37 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20090303163537.20000.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-03-03 16:35:35

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	vgname_from_mda now tries to parse for vgname even
	if rlocn not defined (there is no metadata area).
	
	In most cases it fails in validate_name(),
	unfortunately there are situatuions, when
	validate_name is ok and later code fails with
	checksum error.
	
	Reproducer:
	
	# dd if=/dev/zero of=/dev/loop0
	
	# pvcreate --metadatasize 637k /dev/loop0
	Physical volume "/dev/loop0" successfully created
	
	# pvs /dev/loop0
	/dev/loop0: Checksum error
	PV         VG   Fmt  Attr PSize PFree
	/dev/loop0      lvm2 --   1.00M 1.00M
	
	Signed-off-by: Milan Broz <mbroz@redhat.com>
	
	-

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1059&r2=1.1060
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103

--- LVM2/WHATS_NEW	2009/03/03 13:03:03	1.1059
+++ LVM2/WHATS_NEW	2009/03/03 16:35:32	1.1060
@@ -1,5 +1,6 @@
 Version 2.02.45 - 3rd March 2009
 ================================
+  Avoid scanning empty metadata areas for VG names.
   Attempt proper clean up in child before executing new binary in exec_cmd().
   Do not scan devices if reporting only attributes from PV label.
   Use pkgconfig to obtain corosync library details during configuration.
--- LVM2/lib/format_text/format-text.c	2009/02/25 23:29:06	1.102
+++ LVM2/lib/format_text/format-text.c	2009/03/03 16:35:34	1.103
@@ -1061,6 +1061,12 @@
 	/* FIXME Cope with returning a list */
 	rlocn = mdah->raw_locns;
 
+	/*
+	 * If no valid offset, do not try to search for vgname
+	 */
+	if (!rlocn->offset)
+		goto out;
+
 	/* Do quick check for a vgname */
 	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
 		      NAME_LEN, buf))


