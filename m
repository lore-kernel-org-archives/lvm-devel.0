From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:37:34 +0000 (UTC)
Subject: dev-dct-process-latest - filters: fix incorrect filter indexing in composite filter array
Message-ID: <20140922153734.42771615CC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=80ac8f37d6ac5f8c5228678d4ee07187b5d4db7b
Commit:        80ac8f37d6ac5f8c5228678d4ee07187b5d4db7b
Parent:        4748f4a9e4516a8c9226ce61b5a3ca41f0852ffc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 11 09:30:03 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 11 09:30:03 2014 +0200

filters: fix incorrect filter indexing in composite filter array

Caused by recent changes - a7be3b12dfe7388d1648595e6cc4c7a1379bb8a7.
If global filter was not defined, then part of the code
creating composite filter (the cmd->lvmetad_filter) incorrectly
increased index value even if this global filter was not created
as part of the composite filter. This caused a gap with "NULL"
value in the composite filter array which ended up with the rest
of the filters after the gap to be ignored and also it caused a mem
leak when destroying the composite filter.
---
 lib/commands/toolcontext.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 5bf5cbf..c3afae4 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -861,12 +861,13 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 	}
 
 	/* regex filter. Optional. */
-	if ((cn = find_config_tree_node(cmd, devices_global_filter_CFG, NULL)) &&
-	    !(filters[nr_filt] = regex_filter_create(cn->v))) {
-		log_error("Failed to create global regex device filter");
-		goto bad;
-	} else
+	if ((cn = find_config_tree_node(cmd, devices_global_filter_CFG, NULL))) {
+		if (!(filters[nr_filt] = regex_filter_create(cn->v))) {
+			log_error("Failed to create global regex device filter");
+			goto bad;
+		}
 		nr_filt++;
+	}
 
 	/* device type filter. Required. */
 	if (!(filters[nr_filt] = lvm_type_filter_create(cmd->dev_types))) {


