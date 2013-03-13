From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Mar 2013 14:16:08 +0000 (UTC)
Subject: master - thin: lvconvert read params sooner
Message-ID: <20130313141608.A65F2A0D6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=82eee72019e7311341fcd4e36bf92a8264f353cd
Commit:        82eee72019e7311341fcd4e36bf92a8264f353cd
Parent:        b36a776a7fed84fa6228ffa287b4c9ccdf355ddf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 11 10:44:49 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 13 15:13:54 2013 +0100

thin: lvconvert read params sooner

Move code for reading stripesize and readahead to the
_read_params function.
---
 tools/lvconvert.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 88ad719..932a4f6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -390,9 +390,22 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 				log_error("--poolmetadatasize is invalid with --poolmetadata.");
 				return 0;
 			}
+			if (arg_count(cmd, stripesize_ARG) || arg_count(cmd, stripes_long_ARG)) {
+				log_error("Can't use --stripes and --stripesize with --poolmetadata.");
+				return 0;
+			}
+
+			if (arg_count(cmd, readahead_ARG)) {
+				log_error("Can't use --readahead with --poolmetadata.");
+				return 0;
+			}
 			lp->pool_metadata_lv_name = arg_str_value(cmd, poolmetadata_ARG, "");
 		}
 
+		/* Hmm _read_activation_params */
+		lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
+						cmd->default_settings.read_ahead);
+
 		/* If --thinpool contains VG name, extract it. */
 		if ((tmp_str = strchr(lp->pool_data_lv_name, (int) '/'))) {
 			if (!(lp->vg_name = extract_vgname(cmd, lp->pool_data_lv_name)))
@@ -2026,14 +2039,6 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	}
 
 	if (lp->pool_metadata_lv_name) {
-		if (arg_count(cmd, stripesize_ARG) || arg_count(cmd, stripes_long_ARG)) {
-			log_error("Can't use --stripes and --stripesize with --poolmetadata.");
-			return 0;
-		}
-		if (arg_count(cmd, readahead_ARG)) {
-			log_error("Can't use --readahead with --poolmetadata.");
-			return 0;
-		}
 		metadata_lv = find_lv(pool_lv->vg, lp->pool_metadata_lv_name);
 		if (!metadata_lv) {
 			log_error("Unknown metadata LV %s.", lp->pool_metadata_lv_name);
@@ -2140,9 +2145,6 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 
 		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
 			return_0;
-		/* Hmm _read_activation_params */
-		lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
-						cmd->default_settings.read_ahead);
 
 		if (!(metadata_lv = alloc_pool_metadata(pool_lv, lp->alloc, name,
 							lp->pvh, lp->read_ahead,


