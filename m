From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Oct 2017 06:55:20 -0400
Subject: master - pool: drop create spare on error path
Message-ID: <201710301055.v9UAtKUw020843@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=90ee7783b4c2b1b13122e6107cebeb28ca30326d
Commit:        90ee7783b4c2b1b13122e6107cebeb28ca30326d
Parent:        52fd66210b120bf1185fbbc91b6bc487d99dd33a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 28 00:10:16 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 30 11:53:39 2017 +0100

pool: drop create spare on error path

When thin/cache pool creation fails and command created _pmspare,
such volume is now removed on error path.
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |    7 +++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4d1a6a8..961c7e5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Remove created spare LV when creation of thin-pool failed.
   Avoid reading ignored metadata when mda gets used again.
   Fix detection of moved PVs in vgsplit. (2.02.175)
   Ignore --stripes/--stripesize on RAID takeover
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 09bbe10..7f86a37 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1579,6 +1579,7 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 	struct processing_params *pp = (struct processing_params *) handle->custom_handle;
 	struct lvcreate_params *lp = pp->lp;
 	struct lvcreate_cmdline_params *lcp = pp->lcp;
+	struct logical_volume *spare = vg->pool_metadata_spare_lv;
 	int ret = ECMD_FAILED;
 
 	if (!_read_activation_params(cmd, vg, lp))
@@ -1652,6 +1653,12 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 
 	ret = ECMD_PROCESSED;
 out:
+	if (ret != ECMD_PROCESSED && !spare && vg->pool_metadata_spare_lv)
+		/* Remove created spare volume for failed pool creation */
+		if (!lvremove_single(cmd, vg->pool_metadata_spare_lv, NULL))
+			log_error("Removal of created spare volume failed. "
+				  "Manual intervention required.");
+
 	return ret;
 }
 


