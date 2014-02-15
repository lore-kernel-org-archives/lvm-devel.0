From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Feb 2014 10:38:55 +0000 (UTC)
Subject: master - activation: drop test r/w vg state for activing LV
Message-ID: <20140215103855.07FFD60E70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0f4248333a6dfa017d84dfd7bb298a3321a6ec2
Commit:        f0f4248333a6dfa017d84dfd7bb298a3321a6ec2
Parent:        fa4812bf7b336cf1a301ec7218f905894422e61e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 13 14:42:29 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 15 11:34:54 2014 +0100

activation: drop test r/w vg state for activing LV

VG status read/write is meant to influence only VG metadata.
It's not related to the read/write status of the LV itself.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e2a33b5..17b79ba 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Do not use VG read/write state for LV read/write state.
   Use --ignoreskippedcluster in activation systemd units if use_lvmetad=0.
   Allow approximate allocation when specifying size in percentage terms.
   Add basic LVM support for cache[pool] segment types.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 9a10e74..fe36149 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -63,7 +63,7 @@ struct lv_layer {
 
 int read_only_lv(struct logical_volume *lv, struct lv_activate_opts *laopts)
 {
-	return (laopts->read_only || !(lv->vg->status & LVM_WRITE) || !(lv->status & LVM_WRITE));
+	return (laopts->read_only || !(lv->status & LVM_WRITE));
 }
 
 /*


