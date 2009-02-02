From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  2 Feb 2009 15:50:05 -0500
Subject: [PATCH 09/13] Add lvm_lvs_in_vg() API.
In-Reply-To: <1233607809-1087-9-git-send-email-dwysocha@redhat.com>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-7-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-8-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-9-git-send-email-dwysocha@redhat.com>
Message-ID: <1233607809-1087-10-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add exported lvm_lv_list structure along with the API.  Note that this
struct is very similar to struct lv_list.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index b274762..4d25d25 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -84,4 +84,11 @@ int lvm_vg_get_attr_value(vg_t *vg, const char *attr_name,
 
 vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode);
 void lvm_vg_close(vg_t *vg);
+
+struct lvm_lv_list {
+	struct dm_list list;
+	lv_t *lv;
+};
+struct dm_list *lvm_lvs_in_vg(vg_t *vg);
+
 #endif
-- 
1.5.5.1


