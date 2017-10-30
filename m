From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 30 Oct 2017 18:10:24 -0400
Subject: master - liblvm: Fix segfault in lvm_pv_remove.
Message-ID: <201710302210.v9UMAOjd023916@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=248144d06654a509249938c44bb68ece4a71e6f1
Commit:        248144d06654a509249938c44bb68ece4a71e6f1
Parent:        7e3be7d1ba4c6ae56dd80ec7ae098e9e451de775
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Oct 30 22:03:35 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Oct 30 22:03:35 2017 +0000

liblvm: Fix segfault in lvm_pv_remove.

Since 4fa5add6b1bd4d7f7313f2950021a09e4130ad08 ("pvcreate: Wipe cached
bootloaderarea when wiping label.") label_remove is responsible
for the lvmcache_del.  (toollib and liblvm need fixing to share
the code.)
---
 WHATS_NEW                      |    1 +
 lib/metadata/metadata-liblvm.c |    3 ---
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0ee52ba..ab4f656 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  liblvm: Fix segfault in lvm_pv_remove. (2.02.173)
   Do not allow storing VG metadata with LV without any segment.
   Fix printed message when thin snapshot was already merged.
   Remove created spare LV when creation of thin-pool failed.
diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
index f37008d..4202950 100644
--- a/lib/metadata/metadata-liblvm.c
+++ b/lib/metadata/metadata-liblvm.c
@@ -602,9 +602,6 @@ static int _pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		goto out;
 	}
 
-	if (info)
-		lvmcache_del(info);
-
 	if (!lvmetad_pv_gone_by_dev(dev))
 		goto_out;
 


