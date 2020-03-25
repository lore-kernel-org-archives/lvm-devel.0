From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 25 Mar 2020 18:55:55 +0000 (GMT)
Subject: master - vdo: make vdopool wrapping device is read-only
Message-ID: <20200325185555.D16E0385E00C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=caff31df192bc4b06c8b0e9c75cbe93ff79581a5
Commit:        caff31df192bc4b06c8b0e9c75cbe93ff79581a5
Parent:        e6b93dc24e293bb06403f914ed5c03f9afa1a8ee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 11 12:57:44 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 23 17:13:26 2020 +0100

vdo: make vdopool wrapping device is read-only

When vdopool is activated standalone - we use a wrapping linear device
to hold actual vdo device active - for this we can set-up read-only
device to ensure there cannot be made write through this device to
actual pool device.
---
 lib/activate/dev_manager.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 3b991319f..75d4df0e6 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -86,7 +86,7 @@ int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts
 		return 0; /* Keep RAID SubLvs writable */
 
 	if (!layer) {
-		if (lv_is_thin_pool(lv))
+		if (lv_is_thin_pool(lv) || lv_is_vdo_pool(lv))
 			return 1;
 	}
 



