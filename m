From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Mar 2012 22:44:32 -0000
Subject: LVM2/lib/cache lvmetad.c
Message-ID: <20120302224432.18832.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-02 22:44:32

Modified files:
	lib/cache      : lvmetad.c 

Log message:
	a fixme

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/lib/cache/lvmetad.c	2012/03/02 21:24:37	1.16
+++ LVM2/lib/cache/lvmetad.c	2012/03/02 22:44:31	1.17
@@ -654,6 +654,7 @@
 	struct _pvscan_lvmetad_baton *b = baton;
 	struct volume_group *this = mda->ops->vg_read(b->fid, "", mda, 1);
 
+	/* FIXME Also ensure contents match etc. */
 	if (!b->vg || this->seqno > b->vg->seqno)
 		b->vg = this;
 	else if (b->vg)


