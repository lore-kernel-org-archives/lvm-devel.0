From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Aug 2011 20:26:41 -0000
Subject: LVM2/lib/metadata vg.h
Message-ID: <20110810202641.22001.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-10 20:26:41

Modified files:
	lib/metadata   : vg.h 

Log message:
	Just add new lines between header comment

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/lib/metadata/vg.h	2011/08/10 20:25:30	1.13
+++ LVM2/lib/metadata/vg.h	2011/08/10 20:26:41	1.14
@@ -139,10 +139,12 @@
 uint32_t vg_mda_used_count(const struct volume_group *vg);
 uint32_t vg_mda_copies(const struct volume_group *vg);
 int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies);
+
 /*
  * Returns visible LV count - number of LVs from user perspective
  */
 unsigned vg_visible_lvs(const struct volume_group *vg);
+
 /*
  * Count snapshot LVs.
  */


