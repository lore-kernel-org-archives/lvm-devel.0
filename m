From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 2 Mar 2011 10:23:30 -0000
Subject: LVM2/lib/format_text format-text.c
Message-ID: <20110302102330.15491.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-03-02 10:23:29

Modified files:
	lib/format_text: format-text.c 

Log message:
	Use a copy if moving an mda from pv fid to vg fid.
	
	We'll destroy the pv fid (with all mdas in it) after merging all pv mdas to
	a vg in _text_pv_setup fn, hence we need to use a copy here!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.172&r2=1.173

--- LVM2/lib/format_text/format-text.c	2011/03/02 10:19:14	1.172
+++ LVM2/lib/format_text/format-text.c	2011/03/02 10:23:29	1.173
@@ -1647,7 +1647,7 @@
 	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	struct lvmcache_info *info;
 	unsigned mda_index;
-	struct metadata_area *pv_mda;
+	struct metadata_area *pv_mda, *pv_mda_copy;
 	struct mda_context *pv_mdac;
 	uint64_t pe_count;
 	uint64_t size_reduction = 0;
@@ -1659,8 +1659,10 @@
 				continue;
 
 			/* Be sure it's not already in VG's format instance! */
-			if (!fid_get_mda_indexed(vg->fid, pvid, ID_LEN, mda_index))
-				fid_add_mda(vg->fid, pv_mda, pvid, ID_LEN, mda_index);
+			if (!fid_get_mda_indexed(vg->fid, pvid, ID_LEN, mda_index)) {
+				pv_mda_copy = mda_copy(vg->fid->fmt->cmd->mem, pv_mda);
+				fid_add_mda(vg->fid, pv_mda_copy, pvid, ID_LEN, mda_index);
+			}
 		}
 	}
 	/*


