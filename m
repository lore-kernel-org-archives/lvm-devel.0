From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 26 Feb 2012 13:42:50 -0000
Subject: LVM2/lib/cache lvmetad.c
Message-ID: <20120226134250.2471.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-26 13:42:50

Modified files:
	lib/cache      : lvmetad.c 

Log message:
	Fix a possible SEGV in lvmetad client code, and a minor leak in pvscan
	--lvmetad.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/lib/cache/lvmetad.c	2012/02/26 08:49:40	1.5
+++ LVM2/lib/cache/lvmetad.c	2012/02/26 13:42:50	1.6
@@ -566,9 +566,10 @@
 {
 	struct _pvscan_lvmetad_baton *b = baton;
 	struct volume_group *this = mda->ops->vg_read(b->fid, "", mda);
-	if ((this && !b->vg) || this->seqno > b->vg->seqno)
+	if (!b->vg || this->seqno > b->vg->seqno)
 		b->vg = this;
-	else release_vg(this);
+	else if (b->vg)
+		release_vg(this);
 	return 1;
 }
 
@@ -647,6 +648,8 @@
 							     &fic);
 
 	lvmcache_foreach_mda(info, _pvscan_lvmetad_single, &baton);
+	if (!baton.vg)
+		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
 
 	/*
 	 * NB. If this command failed and we are relying on lvmetad to have an


