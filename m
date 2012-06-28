From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 28 Jun 2012 13:49:04 +0000 (UTC)
Subject: master - vgchange: add --activate ay option (autoactivate)
Message-ID: <20120628134904.B4B0C1687@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=215a314f195ea4af5265e37999502462fcf2a341
Commit:        215a314f195ea4af5265e37999502462fcf2a341
Parent:        95ced7a7be26499fed2ffa03d71002e73c2d3ca9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 27 10:21:15 2012 -0400
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 28 09:42:48 2012 -0400

vgchange: add --activate ay option (autoactivate)

Normally, the 'vgchange -ay' activates all volume groups (that pass
the activation/volume_list filter if set).

This call can appear in two scenarios:
 - system boot (so activation within a script in general)
 - manual call on command line (so activaton on user's direct request)

For the former one, we would like to select which VGs should be actually
activated. One can define the list of VGs directly to do that. But that
would require the same list to be provided in all the scripts.

The 'vgchange -aay' will check for the activation/auto_activation_volume_list
in adition and it will activate only those VGs/LVs that pass this
filter (assuming all to be activated if the list is not defined - the
same logic we already have for activation/volume_list).

Init/boot scripts should use this form of activation primarily
(which, anyway, becomes only a fallback now with autoactivation done
on PV appearance in tandem with lvmetad in place).
---
 WHATS_NEW        |    1 +
 tools/commands.h |    2 +-
 tools/vgchange.c |    6 ++++++
 3 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7e29cb0..fb3279e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Add --activate ay to vgchange.
   Add support for volume autoactivation using lvmetad.
   Add --activate synonym for --available arg and prefer --activate.
   Never issue discards when LV extents are being reconfigured, not deleted.
diff --git a/tools/commands.h b/tools/commands.h
index a8c6587..8bec092 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -742,7 +742,7 @@ xx(vgchange,
    "\t[-u|--uuid] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version]" "\n"
-   "\t{-a|--activate [e|l]{y|n}  |" "\n"
+   "\t{-a|--activate [a|e|l]{y|n}  |" "\n"
    "\t -c|--clustered {y|n} |" "\n"
    "\t -x|--resizeable {y|n} |" "\n"
    "\t -l|--logicalvolume MaxLogicalVolumes |" "\n"
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 29562a5..ebabb08 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -131,6 +131,12 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			continue;
 		}
 
+		if (activate == CHANGE_AAY) {
+			if (!lv_passes_auto_activation_filter(cmd, lv))
+				continue;
+			activate = CHANGE_ALY;
+		}
+
 		expected_count++;
 
 		if (activate == CHANGE_AN) {


