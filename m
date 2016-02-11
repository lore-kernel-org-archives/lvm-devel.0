From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Feb 2016 17:39:39 +0000 (UTC)
Subject: master - lvconvert: enable spare creation during conversion
Message-ID: <20160211173939.CAD5360DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e32e793c43280c898ff6b20d22488af568825287
Commit:        e32e793c43280c898ff6b20d22488af568825287
Parent:        3b76e9fd98bcbe89e1a73c8a0f7419c21799eecb
Author:        M.H. Tsai <mingnus@gmail.com>
AuthorDate:    Wed Jan 27 19:11:03 2016 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 11 18:30:40 2016 +0100

lvconvert: enable spare creation during conversion

Let user control pool metadata spare creation after repair as
the VG might not have enough free space.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a757f79..7b10da8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.142 - 
 ====================================
+  Support control of spare metadata creation when repairing thin-pool.
   Fix config type of 'log/verbose' from bool to int (2.02.99).
   Fix thinp watermark calc for data LV for faster dmeventd responce (2.02.133).
   Use use_blkid_wiping=0 if not defined in lvm.conf and support not compiled in.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fbec9b0..e2b91fa 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2481,7 +2481,8 @@ deactivate_pmslv:
 	}
 
 	/* Try to allocate new pool metadata spare LV */
-	if (!handle_pool_metadata_spare(pool_lv->vg, 0, lp->pvh, 1))
+	if (!handle_pool_metadata_spare(pool_lv->vg, 0, lp->pvh,
+					lp->poolmetadataspare))
 		stack;
 
 	if (dm_snprintf(meta_path, sizeof(meta_path), "%s_meta%%d", pool_lv->name) < 0) {


