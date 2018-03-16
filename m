From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 16 Mar 2018 10:59:01 -0400
Subject: master - lvcreate: remove RaidLV on creation failure
Message-ID: <201803161459.w2GEx1cZ025072@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d68d71013fb261c87f1d3a26ebf098644055c6d1
Commit:        d68d71013fb261c87f1d3a26ebf098644055c6d1
Parent:        9553dc77611e787999923a4cfeb223360ce00672
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 16 15:47:12 2018 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 16 15:57:53 2018 +0100

lvcreate: remove RaidLV on creation failure

In case a newly created RaidLV is blacklisted using config
\"activation { volume list = [ ... ] }\" (i.e. its SubLVs stay inactive),
the metadata SubLVs can't get wiped thus failing the creation.

As a result, the RaidLV together with its SubLVs
is left behind in an inconsistent state.

Fix by removing the RaidLV and provide a hint about volume_list reasoning.

Resolves: rhbz1161347
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index da5f5f4..2ec7f7e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Remove RaidLV on creation failure when rmeta devices can't be activated.
   Add prioritized_section() to restore cookie boundaries (2.02.177).
   Enhance error messages when read error happens.
   Enhance mirror log initialization for old mirror target.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9566f3e..da5e355 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4100,9 +4100,16 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 				str_list_wipe(&meta_lv->tags);
 			}
 
-			if (fail)
+			if (fail) {
 				/* Fail, after trying to deactivate all we could */
+				struct volume_group *vg = lv->vg;
+
+				if (!lv_remove(lv))
+					log_error("Failed to remove LV");
+				else if (!vg_write(vg) || !vg_commit(vg))
+					log_error("Failed to commit VG %s", vg->name);
 				return_0;
+			}
 		}
 
 		for (s = 0; s < seg->area_count; s++)
@@ -7155,7 +7162,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 	}
 
 	if (!lv_is_active_locally(lv)) {
-		log_error("Volume \"%s/%s\" is not active locally.",
+		log_error("Volume \"%s/%s\" is not active locally (volume_list activation filter?).",
 			  lv->vg->name, lv->name);
 		return 0;
 	}


