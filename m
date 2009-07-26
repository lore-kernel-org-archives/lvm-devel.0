From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 26 Jul 2009 15:13:06 -0400
Subject: [PATCH 4/4] Update test/api/test.c to display lvm_lv_is_active and lvm_lv_is_suspended.
In-Reply-To: <1248635586-8139-4-git-send-email-dwysocha@redhat.com>
References: <1248635586-8139-1-git-send-email-dwysocha@redhat.com>
	<1248635586-8139-2-git-send-email-dwysocha@redhat.com>
	<1248635586-8139-3-git-send-email-dwysocha@redhat.com>
	<1248635586-8139-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1248635586-8139-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index a97a192..90aff67 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -315,9 +315,12 @@ static void _lvs_in_vg(char **argv, int argc)
 	}
 	printf("LVs in VG %s:\n", lvm_vg_get_name(vg));
 	dm_list_iterate_items(lvl, lvs) {
-		printf("%s/%s (%s): size=%"PRIu64"\n", lvm_vg_get_name(vg),
+		printf("%s/%s (%s): size=%"PRIu64", %sACTIVE / %sSUSPENDED\n",
+			lvm_vg_get_name(vg),
 			lvm_lv_get_name(lvl->lv), lvm_lv_get_uuid(lvl->lv),
-			lvm_lv_get_size(lvl->lv));
+			lvm_lv_get_size(lvl->lv),
+			lvm_lv_is_active(lvl->lv) ? "" : "IN",
+			lvm_lv_is_suspended(lvl->lv) ? "" : "NOT ");
 	}
 }
 
-- 
1.6.0.6


