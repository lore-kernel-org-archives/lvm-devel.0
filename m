From: David Teigland <teigland@sourceware.org>
Date: Thu, 9 Mar 2017 10:51:45 -0500
Subject: master - lvresize: poolmetadatasize cannot use minus
Message-ID: <201703091551.v29FpjA6002674@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa312722234621b7917e6cd51a39a323eb777079
Commit:        aa312722234621b7917e6cd51a39a323eb777079
Parent:        6dfe1ce251b1e2d01779817255d3beb3b9cfe2e9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 9 09:49:33 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 9 09:51:24 2017 -0600

lvresize: poolmetadatasize cannot use minus

---
 tools/command-lines.in |    4 ++--
 tools/command.c        |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 150f572..3a449ef 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1221,7 +1221,7 @@ ID: lvrename_lv_lv
 lvresize --size SSizeMB LV
 OO: --alloc Alloc, --autobackup Bool, --force,
 --nofsck, --nosync, --noudevsync, --reportformat ReportFmt, --resizefs,
---stripes Number, --stripesize SizeKB, --poolmetadatasize SSizeMB,
+--stripes Number, --stripesize SizeKB, --poolmetadatasize PSizeMB,
 --type SegType
 OP: PV ...
 ID: lvresize_by_size
@@ -1235,7 +1235,7 @@ OO: --alloc Alloc, --autobackup Bool, --force,
 ID: lvresize_by_pv
 DESC: Resize an LV by specified PV extents.
 
-lvresize --poolmetadatasize SSizeMB LV_thinpool
+lvresize --poolmetadatasize PSizeMB LV_thinpool
 OO: --alloc Alloc, --autobackup Bool, --force,
 --nofsck, --nosync, --noudevsync,
 --reportformat ReportFmt, --stripes Number, --stripesize SizeKB,
diff --git a/tools/command.c b/tools/command.c
index 1f31468..88b7216 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1534,10 +1534,10 @@ int define_commands(char *run_name)
 void configure_command_option_values(const char *name)
 {
 	if (!strcmp(name, "lvresize")) {
-		/* relative +|- allowed */
+		/* relative +|- allowed for LV, + allowed for metadata */
 		opt_names[size_ARG].val_enum = ssizemb_VAL;
 		opt_names[extents_ARG].val_enum = sextents_VAL;
-		opt_names[poolmetadatasize_ARG].val_enum = ssizemb_VAL;
+		opt_names[poolmetadatasize_ARG].val_enum = psizemb_VAL;
 		return;
 	}
 


