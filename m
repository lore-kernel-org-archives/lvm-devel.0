From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:24:38 +0000 (UTC)
Subject: dev-mornfall-activate - thin: explicitly avoid pvmove operation
Message-ID: <20130604192438.82CA461020@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17a691505467cd5a73059fe5ca22fe50dafd345a
Commit:        17a691505467cd5a73059fe5ca22fe50dafd345a
Parent:        78a42bac157edba2b68bdfd77ea5c3096845aceb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 08:49:17 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:09:11 2013 +0200

thin: explicitly avoid pvmove operation

So far we do not support pvmove for thin volumes
and thin pools.
---
 WHATS_NEW      |    1 +
 tools/pvmove.c |    7 +++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 819fea4..b016b8e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add explicit message about unsupported pvmove for thin/thinpool volumes.
   Fix lvmetad error path in lvmetad_vg_lookup() for null vgname.
   Fix clvmd _cluster_request() return code in memory fail path.
   Add writemostly/writebehind support for RAID1
diff --git a/tools/pvmove.c b/tools/pvmove.c
index a733049..5c51c5f 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -248,6 +248,13 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			log_print_unless_silent("Skipping mirror image LV %s", lv->name);
 			continue;
 		}
+		if (lv_is_thin_volume(lv) || lv_is_thin_pool(lv)) {
+			lv_skipped = 1;
+			log_print_unless_silent("Skipping thin%s LV %s",
+						lv_is_thin_pool(lv) ? "-pool" : "",
+						lv->name);
+			continue;
+		}
 		if (lv->status & LOCKED) {
 			lv_skipped = 1;
 			log_print_unless_silent("Skipping locked LV %s", lv->name);


