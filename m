From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:23 +0000 (GMT)
Subject: stable-2.02 - label: use open_rw
Message-ID: <20201018210223.8EC2A3858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ba7740df50e93d9a7a2ec919511ba2541e9cc52c
Commit:        ba7740df50e93d9a7a2ec919511ba2541e9cc52c
Parent:        8792d417f3bcec4b9142234786c9a8d9474db3ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 18 00:25:33 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:26:38 2020 +0200

label: use open_rw

Add missing declaration for label_scan_open_rw()
which has been already introduced without declaration
and use it for wiping LV.
---
 lib/label/label.h       | 2 ++
 lib/metadata/lv_manip.c | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/label/label.h b/lib/label/label.h
index ea29c84ee..e4da686f8 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -118,6 +118,8 @@ void label_scan_confirm(struct device *dev);
 int label_scan_setup_bcache(void);
 int label_scan_open(struct device *dev);
 int label_scan_open_excl(struct device *dev);
+int label_scan_open_rw(struct device *dev);
+
 int label_scan_pvscan_all(struct cmd_context *cmd, struct dm_list *scan_devs);
 
 /*
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e4ea30d12..0751a7a2b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7219,7 +7219,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		return 0;
 	}
 
-	if (!label_scan_open(dev)) {
+	if (!label_scan_open_rw(dev)) {
 		log_error("Failed to open %s/%s for wiping and zeroing.", lv->vg->name, lv->name);
 		goto out;
 	}


