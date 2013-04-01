From: Tony Asleson <tasleson@redhat.com>
Date: Mon,  1 Apr 2013 16:34:55 -0500
Subject: [PATCH 1/7] lvm2app: Implementation of pv resize (v6)
Message-ID: <1364852101-14961-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm2app.h |  2 --
 liblvm/lvm_pv.c  | 20 +++++++++++++++++---
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 93a78c3..935c53b 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1626,8 +1626,6 @@ pv_t lvm_pv_from_uuid(vg_t vg, const char *uuid);
  *
  * \memberof pv_t
  *
- * NOTE: This function is currently not implemented.
- *
  * \param   pv
  * Physical volume handle.
  *
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 90edaed..bf9f630 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -123,7 +123,21 @@ pv_t lvm_pv_from_uuid(vg_t vg, const char *uuid)
 
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
-	/* FIXME: add pv resize code here */
-	log_error("NOT IMPLEMENTED YET");
-	return -1;
+	uint64_t size = new_size >> SECTOR_SHIFT;
+
+	if (new_size % SECTOR_SIZE) {
+		log_errno(EINVAL, "Size not a multiple of 512");
+		return -1;
+	}
+
+	if (!vg_check_write_mode(pv->vg)) {
+		return -1;
+	}
+
+	if (!pv_resize(pv, pv->vg, size)) {
+		log_error("PV re-size failed!");
+		return -1;
+	} else {
+		return 0;
+	}
 }
-- 
1.8.1.4


