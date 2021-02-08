From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:45:01 +0000 (GMT)
Subject: main - lv_resize: use 'bad' code path for error case
Message-ID: <20210208224501.917A1384A02A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bdc2f4c70462733046f4f828c49eac6440993cb1
Commit:        bdc2f4c70462733046f4f828c49eac6440993cb1
Parent:        eed060f0408738eb8191ee6bcef4fa93b9b87511
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 7 00:39:13 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:18:44 2021 +0100

lv_resize: use 'bad' code path for error case

---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5c528a50b..43c162e5e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6133,7 +6133,7 @@ out:
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
 	    !_fsadm_cmd(FSADM_CMD_RESIZE, lv, lp->extents, lp->yes, lp->force, NULL))
-		return_0;
+		goto_bad;
 
 	ret = 1;
 bad:


