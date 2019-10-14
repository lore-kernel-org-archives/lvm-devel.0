From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:21:32 -0400
Subject: master - lvconvert: fix return value when zeroing fails
Message-ID: <201910141321.x9EDLWUo018695@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76a9a86fd359681a598a6509eb90940c3a10f1f3
Commit:        76a9a86fd359681a598a6509eb90940c3a10f1f3
Parent:        bd21736e8b082319e1a9a29e75badd906ee277f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 14 11:54:49 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:13:33 2019 +0200

lvconvert: fix return value when zeroing fails

Use correct error return code for fail path.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 767973c..d530d9f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Fix cmd return when zering of cachevol fails.
   Extend lvs to show all VDO properties.
   Preserve VDO write policy with vdopool.
   Increase default vdo bio threads to 4.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 60ab956..caef5d5 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5565,7 +5565,7 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 
 	if (!_writecache_zero(cmd, lv_fast)) {
 		log_error("LV %s could not be zeroed.", display_lvname(lv_fast));
-		return 0;
+		return ECMD_FAILED;
 	}
 
 	/*


