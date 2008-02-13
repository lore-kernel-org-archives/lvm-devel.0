From: meyering@sourceware.org <meyering@sourceware.org>
Date: 13 Feb 2008 20:01:49 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20080213200149.607.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-02-13 20:01:48

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	is_orphan: make parameter "const" to avoid compiler warning

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.793&r2=1.794
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.157&r2=1.158

--- LVM2/WHATS_NEW	2008/02/12 13:29:08	1.793
+++ LVM2/WHATS_NEW	2008/02/13 20:01:48	1.794
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Avoid a compiler warning: make is_orphan's parameter "const".
   Fix lvconvert detection of mirror conversion in progress. (2.02.30)
   Avoid automatic lvconvert polldaemon invocation when -R specified. (2.02.30)
   Fix 'pvs -a' to detect VGs of PVs without metadata areas.
--- LVM2/lib/metadata/metadata-exported.h	2008/02/06 15:47:28	1.43
+++ LVM2/lib/metadata/metadata-exported.h	2008/02/13 20:01:48	1.44
@@ -318,7 +318,7 @@
 	     struct list *mdas, int64_t label_sector);
 int is_pv(pv_t *pv);
 int is_orphan_vg(const char *vg_name);
-int is_orphan(pv_t *pv);
+int is_orphan(const pv_t *pv);
 int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_from,
 		       struct volume_group *vg_to);
--- LVM2/lib/metadata/metadata.c	2008/02/06 15:47:28	1.157
+++ LVM2/lib/metadata/metadata.c	2008/02/13 20:01:48	1.158
@@ -1975,7 +1975,7 @@
  * is_orphan - Determine whether a pv is an orphan based on its vg_name
  * @pv: handle to the physical volume
  */
-int is_orphan(pv_t *pv)
+int is_orphan(const pv_t *pv)
 {
 	return is_orphan_vg(pv_field(pv, vg_name));
 }


