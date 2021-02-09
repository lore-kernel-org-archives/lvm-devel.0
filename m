From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  9 Feb 2021 14:06:48 +0000 (GMT)
Subject: stable-2.02 - lv_resize: use 'bad' code path for error case
Message-ID: <20210209140648.DB79C3836C73@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=619ad644ccfe08e91be98ef10f13ecd0caeb956b
Commit:        619ad644ccfe08e91be98ef10f13ecd0caeb956b
Parent:        6c99725261a53c6d984fa262980aab0df2ae6d62
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 7 00:39:13 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 9 14:45:29 2021 +0100

lv_resize: use 'bad' code path for error case

---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c37757e9a..e0bc61fa2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5712,7 +5712,7 @@ out:
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
 	    !_fsadm_cmd(FSADM_CMD_RESIZE, lv, lp->extents, lp->yes, lp->force, NULL))
-		return_0;
+		goto_bad;
 
 	ret = 1;
 bad:


