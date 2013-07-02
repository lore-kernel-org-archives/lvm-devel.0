From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:00 +0000 (UTC)
Subject: master - lvm2app: Implementation of pv resize (v6)
Message-ID: <20130702192600.869F160D30@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d52b6be455126e7b6a46c39127ca343982955b19
Commit:        d52b6be455126e7b6a46c39127ca343982955b19
Parent:        4d5de8322b3a6050def60542b167b46d97b2824d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 13 14:39:56 2013 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:33 2013 -0500

lvm2app: Implementation of pv resize (v6)

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm2app.h |    2 --
 liblvm/lvm_pv.c  |   20 +++++++++++++++++---
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index b1d6abd..633b026 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1759,8 +1759,6 @@ pv_t lvm_pv_from_uuid(vg_t vg, const char *uuid);
  *
  * \memberof pv_t
  *
- * NOTE: This function is currently not implemented.
- *
  * \param   pv
  * Physical volume handle.
  *
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 3924af4..18b1069 100644
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


