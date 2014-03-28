From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 28 Mar 2014 09:42:10 +0000 (UTC)
Subject: master - pvchange: populate lvmcache for --all
Message-ID: <20140328094210.E939C613AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88a9705222d728d0989c1b4d9aac89ce22c0284b
Commit:        88a9705222d728d0989c1b4d9aac89ce22c0284b
Parent:        3d0ba79f86a209335a3e391352aa7de685e4992b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 28 10:35:50 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 28 10:41:58 2014 +0100

pvchange: populate lvmcache for --all

When running pvchange --all  learn about available VGs from lvmetad.
---
 WHATS_NEW        |    1 +
 tools/pvchange.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8013f1e..626a5b8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Obtain list of known VGs for pvchange --all when using lvmetad.
   Add man page for lvm dumpconfig.
   Drop unused cmd pointer for internal function for_each_sub_lv().
   Validate name for renamed sub LVs.
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 5c05db6..f87cd8c 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -225,6 +225,10 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 			return ECMD_FAILED;
 		}
 
+		/* populate lvmcache */
+		if (!lvmetad_vg_list_to_lvmcache(cmd))
+			stack;
+
 		if ((vgnames = get_vgnames(cmd, 1)) &&
 		    !dm_list_empty(vgnames)) {
 			dm_list_iterate_items(sll, vgnames) {


