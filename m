From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Mar 2016 09:28:15 +0000 (UTC)
Subject: master - commands: lvdisplay: recognize -H|--history switch
Message-ID: <20160304092815.CE39260C9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b114b4d723129998b1578410b0b054bebfef1817
Commit:        b114b4d723129998b1578410b0b054bebfef1817
Parent:        ad9cbe271458741f87dca834c16078f181612d76
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 4 10:27:45 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 4 10:27:45 2016 +0100

commands: lvdisplay: recognize -H|--history switch

---
 lib/display/display.c |   31 +++++++++++++++++++++++++++++++
 tools/commands.h      |   10 ++++++----
 2 files changed, 37 insertions(+), 4 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index 2b7ea52..a6387c6 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -332,6 +332,34 @@ void lvdisplay_colons(const struct logical_volume *lv)
 		  inkernel ? info.major : -1, inkernel ? info.minor : -1);
 }
 
+static int _lvdisplay_historical_full(struct cmd_context *cmd,
+				      const struct logical_volume *lv)
+{
+	char uuid[64] __attribute__((aligned(8)));
+	int lvm1compat = find_config_tree_bool(cmd, global_lvdisplay_shows_full_device_path_CFG, NULL);
+	struct historical_logical_volume *hlv = lv->this_glv->historical;
+
+	if (!id_write_format(&hlv->lvid.id[1], uuid, sizeof(uuid)))
+		return_0;
+
+	log_print("--- Historical Logical volume ---");
+
+	if (lvm1compat)
+		/* /dev/vgname/lvname doen't actually exist for historical devices */
+		log_print("LV Name                %s%s/%s",
+			  hlv->vg->cmd->dev_dir, hlv->vg->name, hlv->name);
+	else
+		log_print("LV Name                %s%s", HISTORICAL_LV_PREFIX, hlv->name);
+
+	log_print("VG Name                %s", hlv->vg->name);
+	log_print("LV UUID                %s", uuid);
+	log_print("LV Creation time       %s", lv_creation_time_dup(cmd->mem, lv, 1));
+	log_print("LV Removal time        %s", lv_removal_time_dup(cmd->mem, lv, 1));
+
+	log_print(" ");
+	return 1;
+}
+
 int lvdisplay_full(struct cmd_context *cmd,
 		   const struct logical_volume *lv,
 		   void *handle __attribute__((unused)))
@@ -349,6 +377,9 @@ int lvdisplay_full(struct cmd_context *cmd,
 	int thin_active = 0;
 	dm_percent_t thin_percent;
 
+	if (lv_is_historical(lv))
+		return _lvdisplay_historical_full(cmd, lv);
+
 	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid)))
 		return_0;
 
diff --git a/tools/commands.h b/tools/commands.h
index bc5eb92..b3627dd 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -409,6 +409,7 @@ xx(lvdisplay,
    "\t[-d|--debug]\n"
    "\t[--foreign]\n"
    "\t[-h|--help]\n"
+   "\t[-H|--history]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
    "\t[-m|--maps]\n"
@@ -429,6 +430,7 @@ xx(lvdisplay,
    "\t[-d|--debug]\n"
    "\t[--foreign]\n"
    "\t[-h|--help]\n"
+   "\t[-H|--history]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
    "\t[--noheadings]\n"
@@ -447,10 +449,10 @@ xx(lvdisplay,
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
     aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG, foreign_ARG,
-    ignorelockingfailure_ARG, ignoreskippedcluster_ARG, maps_ARG,
-    noheadings_ARG, nosuffix_ARG, options_ARG, sort_ARG, partial_ARG,
-    readonly_ARG, segments_ARG, select_ARG, separator_ARG, shared_ARG,
-    unbuffered_ARG, units_ARG)
+    history_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
+    maps_ARG, noheadings_ARG, nosuffix_ARG, options_ARG, sort_ARG,
+    partial_ARG, readonly_ARG, segments_ARG, select_ARG, separator_ARG,
+    shared_ARG, unbuffered_ARG, units_ARG)
 
 xx(lvextend,
    "Add space to a logical volume",


