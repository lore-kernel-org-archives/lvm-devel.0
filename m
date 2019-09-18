From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 18 Sep 2019 06:47:23 -0400
Subject: stable-2.02 - thin: activate layer pool aas read-only LV
Message-ID: <201909181047.x8IAlNcp016768@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2e51535b18f3a05428f087f3916ebce5c08d58d1
Commit:        2e51535b18f3a05428f087f3916ebce5c08d58d1
Parent:        2caae8a572f5d31f9dececf75aa4126be439bcba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 14 01:08:14 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 17 15:29:11 2019 +0200

thin: activate layer pool aas read-only LV

When lvm2 is activating layered pool LV (to basically keep pool opened,
the other function used to be 'locking' be in sync with DM table)
use this LV in read-only mode - this prevents 'write' access into
data volume content of thin-pool.

Note: since EMPTY/unused thin-pool is created as 'public LV' for generic
use by any user who i.e. wish to maintain thin-pool and thins himself.
At this moment, thin-pool appears as writable LV.  As soon as the 1st.
thinLV is created, layer volume will appear is 'read-only' LV from this moment.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 32298c8..eee10ce 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.187 - 
 ===================================
+  Activate thin-pool layered volume as 'read-only' device.
   Ignore crypto devices with UUID signature CRYPT-SUBDEV.
   Enhance validation for thin and cache pool conversion and swapping.
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 657b046..886e11b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -85,6 +85,11 @@ int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts
 	if (lv_is_raid_image(lv) || lv_is_raid_metadata(lv))
 		return 0; /* Keep RAID SubLvs writable */
 
+	if (!layer) {
+		if (lv_is_thin_pool(lv))
+			return 1;
+	}
+
 	return (laopts->read_only || !(lv->status & LVM_WRITE));
 }
 


