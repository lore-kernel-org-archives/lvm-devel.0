From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Jun 2017 18:29:24 -0400
Subject: master - raid: fix write_commit_backup
Message-ID: <201706262229.v5QMTORr010100@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b1e21cf9ed585796cd2d265c3bda50b7960b0478
Commit:        b1e21cf9ed585796cd2d265c3bda50b7960b0478
Parent:        52f4042f1a3b21054041298d7e50ded7ae366f44
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 26 23:25:24 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 00:27:25 2017 +0200

raid: fix write_commit_backup

With commit 41c10034aa0db3c63f18ff78b64af3a799c154a1 we actually
do require LV to be used with _vg_write_lv_suspend_commit_backup().

So write a proper separte single wrapper for write && commit && backup.
---
 lib/metadata/raid_manip.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2d735ed..158bcf2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2155,7 +2155,12 @@ static int _vg_write_lv_suspend_commit_backup(struct volume_group *vg,
 
 static int _vg_write_commit_backup(struct volume_group *vg)
 {
-	return _vg_write_lv_suspend_commit_backup(vg, NULL, 1, 1);
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
+
+	backup(vg);
+
+	return 1;
 }
 
 __attribute__ ((__unused__))


