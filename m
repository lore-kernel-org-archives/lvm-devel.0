From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 10 Sep 2014 17:57:09 +0000 (UTC)
Subject: master - lvmetad: Re-organise filters to properly avoid scans of component devices.
Message-ID: <20140910175709.D732A60556@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3685a51679e03ecd494063601161992dbe3bff22
Commit:        3685a51679e03ecd494063601161992dbe3bff22
Parent:        66cce64e6985f7f1614c6bde618c7a4207fea7e9
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 9 17:16:40 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Sep 9 17:16:40 2014 +0200

lvmetad: Re-organise filters to properly avoid scans of component devices.

If a PV label is exposed both through a composite device (MD for example) and
through its component devices, we always want the PV that lvmetad sees to be the
composite, since this is what all LVM commands (including activation) will then
use. If pvscan --cache is triggered for multiple clones of the same PV, the last
to finish wins. This patch basically re-arranges the filters so that
component-device filters are part of the global_filter chain, not of the
client-side filter chain. This has a subtle effect on filter evaluation order,
but should not alter visible semantics in the non-lvmetad case.
---
 lib/commands/toolcontext.c |   47 +++++++++++++++++++++----------------------
 1 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index fe79a81..5bf5cbf 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -861,11 +861,9 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 	}
 
 	/* regex filter. Optional. */
-	if (!(cn = find_config_tree_node(cmd, devices_filter_CFG, NULL)))
-		log_very_verbose("devices/filter not found in config file: "
-				 "no regex filter installed");
-	else if (!(filters[nr_filt] = regex_filter_create(cn->v))) {
-		log_error("Failed to create regex device filter");
+	if ((cn = find_config_tree_node(cmd, devices_global_filter_CFG, NULL)) &&
+	    !(filters[nr_filt] = regex_filter_create(cn->v))) {
+		log_error("Failed to create global regex device filter");
 		goto bad;
 	} else
 		nr_filt++;
@@ -918,16 +916,26 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 
 	cmd->dump_filter = 0;
 
-	if (!(f3 = _init_filter_components(cmd)))
+	if (!(cmd->lvmetad_filter = _init_filter_components(cmd)))
 		goto_bad;
 
 	init_ignore_suspended_devices(find_config_tree_bool(cmd, devices_ignore_suspended_devices_CFG, NULL));
 	init_ignore_lvm_mirrors(find_config_tree_bool(cmd, devices_ignore_lvm_mirrors_CFG, NULL));
 
+	if ((cn = find_config_tree_node(cmd, devices_filter_CFG, NULL))) {
+		if (!(f3 = regex_filter_create(cn->v)))
+			goto_bad;
+		toplevel_components[0] = cmd->lvmetad_filter;
+		toplevel_components[1] = f3;
+		if (!(f4 = composite_filter_create(2, toplevel_components)))
+			goto_bad;
+	} else
+		f4 = cmd->lvmetad_filter;
+
 	if (!(dev_cache = find_config_tree_str(cmd, devices_cache_CFG, NULL)))
 		goto_bad;
 
-	if (!(f4 = persistent_filter_create(cmd->dev_types, f3, dev_cache))) {
+	if (!(cmd->filter = persistent_filter_create(cmd->dev_types, f4, dev_cache))) {
 		log_verbose("Failed to create persistent device filter.");
 		goto bad;
 	}
@@ -948,29 +956,20 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	    load_persistent_cache && !cmd->is_long_lived &&
 	    !stat(dev_cache, &st) &&
 	    (st.st_ctime > config_file_timestamp(cmd->cft)) &&
-	    !persistent_filter_load(f4, NULL))
+	    !persistent_filter_load(cmd->filter, NULL))
 		log_verbose("Failed to load existing device cache from %s",
 			    dev_cache);
 
-	if (!(cn = find_config_tree_node(cmd, devices_global_filter_CFG, NULL))) {
-		cmd->filter = f4;
-	} else if (!(cmd->lvmetad_filter = regex_filter_create(cn->v)))
-		goto_bad;
-	else {
-		toplevel_components[0] = cmd->lvmetad_filter;
-		toplevel_components[1] = f4;
-		if (!(cmd->filter = composite_filter_create(2, toplevel_components)))
-			goto_bad;
-	}
-
 	return 1;
 bad:
-	if (f4)
+	if (f4) /* kills both f3 and cmd->lvmetad_filter */
 		f4->destroy(f4);
-	else if (f3)
-		f3->destroy(f3);
-	if (toplevel_components[0])
-		toplevel_components[0]->destroy(toplevel_components[0]);
+	else {
+		if (f3)
+			f3->destroy(f3);
+		if (cmd->lvmetad_filter)
+			cmd->lvmetad_filter->destroy(cmd->lvmetad_filter);
+	}
 	return 0;
 }
 


