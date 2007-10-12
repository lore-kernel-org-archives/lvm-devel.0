From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Oct 2007 14:08:10 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20071012140810.3921.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-10-12 14:08:10

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 

Log message:
	Accessor functions for PV will not modify the given PV.
	So we can add 'const' to it.
	Patch by Jun'ichi Nomura <j-nomura@ce.jp.nec.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.718&r2=1.719
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.171&r2=1.172

--- LVM2/WHATS_NEW	2007/10/10 11:31:21	1.718
+++ LVM2/WHATS_NEW	2007/10/12 14:08:10	1.719
@@ -1,5 +1,7 @@
 Version 2.02.29 -
 ==================================
+  Add const attributes to pv accessor functions.
+  Refactor vg_add_snapshot and lv_create_empty.
   Handle new sysfs subsystem/block/devices directory structure.
   Tests are run with LVM_SYSTEM_DIR pointing to private root and /dev dirs.
   Fix a bug in lvm_dump.sh checks for lvm/dmsetup binaries.
--- LVM2/lib/metadata/metadata-exported.h	2007/10/11 19:20:38	1.18
+++ LVM2/lib/metadata/metadata-exported.h	2007/10/12 14:08:10	1.19
@@ -468,15 +468,15 @@
 /*
 * Begin skeleton for external LVM library
 */
-struct device *pv_dev(pv_t *pv);
-const char *pv_vg_name(pv_t *pv);
-uint64_t pv_size(pv_t *pv);
-uint32_t pv_status(pv_t *pv);
-uint32_t pv_pe_size(pv_t *pv);
-uint64_t pv_pe_start(pv_t *pv);
-uint32_t pv_pe_count(pv_t *pv);
-uint32_t pv_pe_alloc_count(pv_t *pv);
+struct device *pv_dev(const pv_t *pv);
+const char *pv_vg_name(const pv_t *pv);
+uint64_t pv_size(const pv_t *pv);
+uint32_t pv_status(const pv_t *pv);
+uint32_t pv_pe_size(const pv_t *pv);
+uint64_t pv_pe_start(const pv_t *pv);
+uint32_t pv_pe_count(const pv_t *pv);
+uint32_t pv_pe_alloc_count(const pv_t *pv);
 
-uint32_t vg_status(vg_t *vg);
+uint32_t vg_status(const vg_t *vg);
 
 #endif
--- LVM2/lib/metadata/metadata.c	2007/09/17 16:02:46	1.136
+++ LVM2/lib/metadata/metadata.c	2007/10/12 14:08:10	1.137
@@ -1927,62 +1927,62 @@
 /*
  * Gets/Sets for external LVM library
  */
-struct id pv_id(pv_t *pv)
+struct id pv_id(const pv_t *pv)
 {
 	return pv_field(pv, id);
 }
 
-const struct format_type *pv_format_type(pv_t *pv)
+const struct format_type *pv_format_type(const pv_t *pv)
 {
 	return pv_field(pv, fmt);
 }
 
-struct id pv_vgid(pv_t *pv)
+struct id pv_vgid(const pv_t *pv)
 {
 	return pv_field(pv, vgid);
 }
 
-struct device *pv_dev(pv_t *pv)
+struct device *pv_dev(const pv_t *pv)
 {
 	return pv_field(pv, dev);
 }
 
-const char *pv_vg_name(pv_t *pv)
+const char *pv_vg_name(const pv_t *pv)
 {
 	return pv_field(pv, vg_name);
 }
 
-uint64_t pv_size(pv_t *pv)
+uint64_t pv_size(const pv_t *pv)
 {
 	return pv_field(pv, size);
 }
 
-uint32_t pv_status(pv_t *pv)
+uint32_t pv_status(const pv_t *pv)
 {
 	return pv_field(pv, status);
 }
 
-uint32_t pv_pe_size(pv_t *pv)
+uint32_t pv_pe_size(const pv_t *pv)
 {
 	return pv_field(pv, pe_size);
 }
 
-uint64_t pv_pe_start(pv_t *pv)
+uint64_t pv_pe_start(const pv_t *pv)
 {
 	return pv_field(pv, pe_start);
 }
 
-uint32_t pv_pe_count(pv_t *pv)
+uint32_t pv_pe_count(const pv_t *pv)
 {
 	return pv_field(pv, pe_count);
 }
 
-uint32_t pv_pe_alloc_count(pv_t *pv)
+uint32_t pv_pe_alloc_count(const pv_t *pv)
 {
 	return pv_field(pv, pe_alloc_count);
 }
 
-uint32_t vg_status(vg_t *vg)
+uint32_t vg_status(const vg_t *vg)
 {
 	return vg->status;
 }
--- LVM2/lib/metadata/metadata.h	2007/08/20 20:55:26	1.171
+++ LVM2/lib/metadata/metadata.h	2007/10/12 14:08:10	1.172
@@ -304,9 +304,9 @@
 /*
  * Begin skeleton for external LVM library
  */
-struct id pv_id(pv_t *pv);
-const struct format_type *pv_format_type(pv_t *pv);
-struct id pv_vgid(pv_t *pv);
+struct id pv_id(const pv_t *pv);
+const struct format_type *pv_format_type(const pv_t *pv);
+struct id pv_vgid(const pv_t *pv);
 
 pv_t *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,


