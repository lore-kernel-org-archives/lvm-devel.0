From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 29 Apr 2016 18:52:24 +0000 (UTC)
Subject: master - raid: Use inherited tags when wiping rmeta.
Message-ID: <20160429185224.5328661057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c76df666c903b59f069292c4c1507b1ac37a5590
Commit:        c76df666c903b59f069292c4c1507b1ac37a5590
Parent:        e3efcdc9f5d98807ff9887aa602aff1bdc870cbd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 29 19:49:21 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 29 19:49:21 2016 +0100

raid: Use inherited tags when wiping rmeta.

If there's an activation volume_filter, it might not be possible
to activate the rmeta LVs to wipe them.  At least inherit any
LV tags from the parent LV while attempting this.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   13 +++++++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 55ecb68..a712c5f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.152 - 
 ==================================
+  Use any inherited tags when wiping metadata sub LVs to ensure activation.
   Add str_list_wipe.
   Improve support for interrupting procesing of volumes during lvchange.
   Use failed command return code when lvchanging read-only volume.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4bce808..cd0a78c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3834,6 +3834,16 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 				return 0;
 			}
 			lv_set_visible(meta_lv);
+
+			/*
+			 * Copy any tags from the new LV to the metadata LV so
+			 * it can be activated temporarily.
+			 */
+			if (!str_list_dup(meta_lv->vg->vgmem, &meta_lv->tags, &lv->tags)) {
+				log_error("Failed to copy tags onto LV %s to clear metadata.", display_lvname(meta_lv));
+				return 0;
+			}
+
 			clear_metadata = 1;
 		}
 
@@ -3882,6 +3892,9 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 				return 0;
 			}
 			lv_set_hidden(meta_lv);
+
+			/* Wipe any temporary tags required for activation. */
+			str_list_wipe(&meta_lv->tags);
 		}
 	}
 


