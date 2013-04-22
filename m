From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 22 Apr 2013 11:08:30 +0200
Subject: [PATCH 1/2] clvmd: avoid precheck of dev existance
In-Reply-To: <cover.1366621483.git.zkabelac@redhat.com>
References: <cover.1366621483.git.zkabelac@redhat.com>
Message-ID: <bb41414bf881498035d74607cb59d68e2595f655.1366621483.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Tricky patch here - When the pretest is made here, only the commited
data are cached back. However call of lv_suspend_if_active() would
also read precommited metadata. The problem is, that in sequence:

vg_write(), suspend_lv(), vg_commit(), resume_lv()

may end with leaving outdated mda in lvm cache, since vg_write()
drops cached metadata and vg_commit() only transforms precommited
to commited metadata, but in the case of pretesting we have
no precommited mda available so the cache will continue to use
old metadata. This happens, when LV is inactive,

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/lvm-functions.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 6d78090..c7d90aa 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -450,12 +450,7 @@ static int do_suspend_lv(char *resource, unsigned char command, unsigned char lo
 
 	exclusive = (oldmode == LCK_EXCL) ? 1 : 0;
 
-	/* Only suspend it if it exists */
-	if (!lv_info_by_lvid(cmd, resource, origin_only, &lvi, 0, 0))
-		return EIO;
-
-	if (lvi.exists &&
-	    !lv_suspend_if_active(cmd, resource, origin_only, exclusive))
+	if (!lv_suspend_if_active(cmd, resource, origin_only, exclusive))
 		return EIO;
 
 	return 0;
-- 
1.8.2


