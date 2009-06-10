From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Jun 2009 16:14:40 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090610161440.6464.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-06-10 16:14:40

Modified files:
	lib/metadata   : metadata.c 

Log message:
	In the new _vg_read_for_update(), we always do the check for CLUSTERED vg
	status flag after reading the volume group.  Thus, no need to set the flag
	in vg_read() or clear it later before calling _vg_bad_status_bits().
	
	Also, add back in the !lockingfailed() as part of the CLUSTERED flag check.
	It's unclear why it was removed when the check was moved from
	_vg_bad_status_bits() to inside _vg_lock_and_read().
	There was an open question about the last check in the 'if' stmt for
	lockingfailed() with a previous patch submitted.  However, I would
	defer that right now as it is a separate item and this patch should
	be no functional change by including the !lockingfailed().
	
	Petr acked this patch on 5/26 I just forgot to check it in.
	
	Acked-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.225&r2=1.226

--- LVM2/lib/metadata/metadata.c	2009/06/09 14:29:10	1.225
+++ LVM2/lib/metadata/metadata.c	2009/06/10 16:14:40	1.226
@@ -2772,7 +2772,8 @@
 		goto_bad;
 	}
 
-	if (vg_is_clustered(vg) && !locking_is_clustered()) {
+	if (vg_is_clustered(vg) && !locking_is_clustered() &&
+	    !lockingfailed()) {
 		log_error("Skipping clustered volume group %s", vg->name);
 		failure |= FAILED_CLUSTERED;
 		goto_bad;
@@ -2790,7 +2791,7 @@
 	}
 	
 
-	failure |= _vg_bad_status_bits(vg, status_flags & ~CLUSTERED);
+	failure |= _vg_bad_status_bits(vg, status_flags);
 	if (failure)
 		goto_bad;
 
@@ -2837,7 +2838,7 @@
 vg_t *vg_read(struct cmd_context *cmd, const char *vg_name,
 	      const char *vgid, uint32_t flags)
 {
-	uint32_t status = CLUSTERED;
+	uint32_t status = 0;
 	uint32_t lock_flags = LCK_VG_READ;
 
 	if (flags & READ_FOR_UPDATE) {


