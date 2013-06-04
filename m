From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:25:07 +0000 (UTC)
Subject: dev-mornfall-activate - format1: add workaround for vg_set_fid
Message-ID: <20130604192507.CB31160D19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a12f92c494a60fe6e6c9e133aa879bd0d0da069a
Commit:        a12f92c494a60fe6e6c9e133aa879bd0d0da069a
Parent:        994c32272e7c36f45defda12848d3856590a0d1f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 23:53:53 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:53:53 2013 +0200

format1: add workaround for vg_set_fid

Since we want to set fid just before return of vg,
add this termporary workaround.
---
 lib/format1/format1.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 2864227..115f8d1 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -217,8 +217,13 @@ static struct volume_group *_format1_vg_read(struct format_instance *fid,
 	if (!import_extents(fid->fmt->cmd, vg, &pvs))
 		goto_bad;
 
-	if (!import_snapshots(vg->vgmem, vg, &pvs))
+	/* FIXME: workaround - temporary assignment of fid */
+	vg->fid = fid;
+	if (!import_snapshots(vg->vgmem, vg, &pvs)) {
+		vg->fid = NULL;
 		goto_bad;
+	}
+	vg->fid = NULL;
 
 	/* Fix extents counts by adding missing PV if partial VG */
 	if ((vg->status & PARTIAL_VG) && !_fix_partial_vg(vg, &pvs))


