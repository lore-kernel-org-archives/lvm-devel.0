From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 12 Feb 2010 22:54:53 -0500
Subject: [PATCH 3/3] Update simple lvm2app unit test for new size apis.
In-Reply-To: <1266033293-14492-2-git-send-email-dwysocha@redhat.com>
References: <1266033293-14492-1-git-send-email-dwysocha@redhat.com>
	<1266033293-14492-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1266033293-14492-3-git-send-email-dwysocha@redhat.com>
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
index 308c867..6e222da 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -450,8 +450,11 @@ static void _pvs_in_vg(char **argv, int argc)
 	}
 	printf("PVs in VG %s:\n", lvm_vg_get_name(vg));
 	dm_list_iterate_items(pvl, pvs) {
-		printf("%s (%s): mda_count=%"PRIu64"\n",
-		       lvm_pv_get_name(pvl->pv), lvm_pv_get_uuid(pvl->pv),
+		printf("%s (%s): size=%"PRIu64", free=%"PRIu64
+			", dev_size=%"PRIu64", mda_count=%"PRIu64"\n",
+			lvm_pv_get_name(pvl->pv), lvm_pv_get_uuid(pvl->pv),
+			lvm_pv_get_size(pvl->pv), lvm_pv_get_free(pvl->pv),
+			lvm_pv_get_dev_size(pvl->pv),
 			lvm_pv_get_mda_count(pvl->pv));
 	}
 }
-- 
1.6.0.6


