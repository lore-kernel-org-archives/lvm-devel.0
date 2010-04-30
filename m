From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 30 Apr 2010 11:07:20 +0200
Subject: [PATCH 2/3] Release allocated pools in error path
In-Reply-To: <cover.1272618315.git.zkabelac@redhat.com>
References: <cover.1272618315.git.zkabelac@redhat.com>
Message-ID: <a732b01db96b48347d2c9d03617df2dcef2ddd13.1272618315.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Release pools for regex if there is error during processing
(so we do not get error messages about unreleased pools).

Do we want to really drop all filters here ?

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/commands/toolcontext.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index ba99a8d..b4c2690 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -639,14 +639,14 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 
 	else if (!(filters[nr_filt++] = regex_filter_create(cn->v))) {
 		log_error("Failed to create regex device filter");
-		return NULL;
+		goto err;
 	}
 
 	/* device type filter. Required. */
 	cn = find_config_tree_node(cmd, "devices/types");
 	if (!(filters[nr_filt++] = lvm_type_filter_create(cmd->proc_dir, cn))) {
 		log_error("Failed to create lvm type filter");
-		return NULL;
+		goto err;
 	}
 
 	/* md component filter. Optional, non-critical. */
@@ -660,6 +660,11 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 	/* Only build a composite filter if we really need it. */
 	return (nr_filt == 1) ?
 	    filters[0] : composite_filter_create(nr_filt, filters);
+err:
+	nr_filt--; /* skip NULL */
+	while (nr_filt-- > 0)
+		 filters[nr_filt]->destroy(filters[nr_filt]);
+	return NULL;
 }
 
 static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
-- 
1.7.0.1


