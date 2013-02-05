From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 13:47:39 +0000 (UTC)
Subject: master - lvconvert: fix accepting second lv name
Message-ID: <20130205134739.3C700A0C2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be5ad90703ca789becc10d56c19f6dc24f4c7eae
Commit:        be5ad90703ca789becc10d56c19f6dc24f4c7eae
Parent:        d3b8f270eac7314767e9098ef28e2f8b89fbf296
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 4 13:56:54 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 14:31:17 2013 +0100

lvconvert: fix accepting second lv name

Do not allow to accept second LV name on lvconvert --thinpool
command line.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 272c6c8..84a3590 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Do not take a free lv name argument for lvconvert --thinpool option.
   Avoid flushing thin pool when quering for transaction_id.
   Add internal function lv_layer() to obtain layer name for LV.
   Report partial and in-sync RAID attribute based on kernel status
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5bda00f..94767b6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -92,7 +92,12 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 			lp->origin = ptr + 1;
 	}
 
-	if (!*pargc && lp->pool_data_lv_name) {
+	if (lp->pool_data_lv_name) {
+		if (*pargc) {
+			log_error("More then one logical volume name name specified.");
+			return 0;
+		}
+
 		if (!lp->vg_name || !validate_name(lp->vg_name)) {
 			log_error("Please provide a valid volume group name.");
 			return 0;


