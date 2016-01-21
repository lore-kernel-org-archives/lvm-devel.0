From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Jan 2016 12:29:52 +0000 (UTC)
Subject: master - toollib: restore command break support
Message-ID: <20160121122952.54929614E8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=347575df1d801425b1f1f8ed7106ffe74ce6c8c7
Commit:        347575df1d801425b1f1f8ed7106ffe74ce6c8c7
Parent:        c701d9cc8c9c559622c8ce27aa9c7f28169b4dfc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 21 13:19:27 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 21 13:29:07 2016 +0100

toollib: restore command break support

Fix regression caused by c9f021de0b4d2c873ef5b97d17c602d0380359fd.
This commit actually transfered real-action (e.g. device removal)
into the next loop which has however missed to check for break.
So add check for break also there.
---
 WHATS_NEW       |    1 +
 tools/toollib.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fe1da46..6342041 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.141 - 
 ====================================
+  Restore support for command breaking in process_each_lv_in_vg() (2.02.118).
   Use correct mempool when process_each_lv_in_vg() (2.02.118).
   Fix lvm.8 man to show again prohibited suffixes.
   Fix configure to set proper use_blkid_wiping if autodetected as disabled.
diff --git a/tools/toollib.c b/tools/toollib.c
index e681afe..c89d8e5 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2416,6 +2416,10 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	dm_list_iterate_items(lvl, &final_lvs) {
+		if (sigint_caught()) {
+			ret_max = ECMD_FAILED;
+			goto_out;
+		}
 		/*
 		 *  FIXME: Once we have index over vg->removed_lvs, check directly
 		 *         LV presence there and remove LV_REMOVE flag/lv_is_removed fn


