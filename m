From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:34:12 -0000
Subject: LVM2/man pvchange.8.in pvs.8.in vgs.8.in
Message-ID: <20100628203412.15914.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:34:12

Modified files:
	man            : pvchange.8.in pvs.8.in vgs.8.in 

Log message:
	Update pvchange, pvs and vgs man pages for metadata ignore.
	
	Explain --metadataignore argument to pvchange, add new fields to pvs / vgs.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvchange.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/man/pvchange.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/pvchange.8.in	2010/06/28 20:34:12	1.3
@@ -6,6 +6,7 @@
 [\-\-addtag Tag]
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] 
 [\-\-deltag Tag]
+[\-\-metadataignore y|n]
 [\-h|\-?|\-\-help]
 [\-t|\-\-test]
 [\-v|\-\-verbose] [\-a|\-\-all] [\-x|\-\-allocatable y|n]
@@ -25,10 +26,20 @@
 .TP
 .I \-x, \-\-allocatable y|n
 Enable or disable allocation of physical extents on this physical volume.
+.TP
+.I \-\-metadataignore y|n
+Ignore or un-ignore metadata areas on this physical volume.  If metadata
+areas on a physical volume are ignored, LVM will not not store metadata
+in the metadata areas present on this Physical Volume.  Metadata areas
+cannot be created or extended after Logical Volumes have been allocated
+on the device. If you do not want to store metadata on this device, it
+is still wise always to allocate a metadata area in case you need it in
+the future and to use this option to instruct LVM2 to ignore it.
+(This option is not applicable to the old LVM1 metadata format.)
 .SH Example
 "pvchange -x n /dev/sdk1" disallows the allocation of physical extents
 on this physical volume (possibly because of disk errors, or because it will
 be removed after freeing it.
 .SH SEE ALSO
-.BR lvm (8), 
+.BR lvm (8),
 .BR pvcreate (8)
--- LVM2/man/pvs.8.in	2009/10/26 14:37:09	1.12
+++ LVM2/man/pvs.8.in	2010/06/28 20:34:12	1.13
@@ -54,7 +54,8 @@
 .IP
 Column names include: pv_fmt, pv_uuid, dev_size, pv_name, pv_mda_free,
 pv_mda_size, pe_start, pv_size, pv_free, pv_used, pv_attr, pv_pe_count,
-pv_pe_alloc_count, pv_tags, pv_mda_count, pvseg_start, and pvseg_size.
+pv_pe_alloc_count, pv_tags, pv_mda_count, pv_mda_used_count,
+pvseg_start, and pvseg_size.
 .IP
 With --segments, any "pvseg_" prefixes are optional; otherwise any
 "pv_" prefixes are optional.  Columns mentioned in \fBvgs (8)\fP can also
--- LVM2/man/vgs.8.in	2009/10/26 14:37:09	1.11
+++ LVM2/man/vgs.8.in	2010/06/28 20:34:12	1.12
@@ -49,7 +49,7 @@
 Column names include: vg_fmt, vg_uuid, vg_name, vg_attr, vg_size, vg_free,
 vg_sysid, vg_extent_size, vg_extent_count, vg_free_count, max_lv, max_pv,
 pv_count, lv_count, snap_count, vg_seqno, vg_tags, vg_mda_count, vg_mda_free,
-and vg_mda_size.
+and vg_mda_size, vg_mda_used_count.
 .IP
 Any "vg_" prefixes are optional.  Columns mentioned in either \fBpvs (8)\fP 
 or \fBlvs (8)\fP can also be chosen, but columns cannot be taken from both


