From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:15 +0000 (UTC)
Subject: master - lvremove: few more validation before archive
Message-ID: <20141110210615.0CFB0602E3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=979d12eb4a69ad328a8583eaafc4d3d30e4d1771
Commit:        979d12eb4a69ad328a8583eaafc4d3d30e4d1771
Parent:        e2c4a3ef67261d4a8d32b62906b05e4292b47f90
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 8 23:15:15 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:48 2014 +0100

lvremove: few more validation before archive

Before we finally call archive, we still can do a few more validation
without modifying VG. So delay archive() call few lines.
---
 lib/metadata/lv_manip.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b029395..1943c07 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5404,9 +5404,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!archive(vg))
-		return 0;
-
 	if (lv_is_cache(lv)) {
 		if (!lv_remove_single(cmd, first_seg(lv)->pool_lv, force,
 				      suppress_remove_message)) {
@@ -5420,6 +5417,9 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
+	if (!archive(vg))
+		return 0;
+
 	if (lv_is_cow(lv)) {
 		/* Old format1 code */
 		if (!(lv->vg->fid->fmt->features & FMT_MDAS))


