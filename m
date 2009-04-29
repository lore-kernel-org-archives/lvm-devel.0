From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 29 Apr 2009 15:55:31 -0400
Subject: [PATCH 5/8] Add list structure definitions for liblvm objects.
In-Reply-To: <1241034934-25639-5-git-send-email-dwysocha@redhat.com>
References: <1241034934-25639-1-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-2-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-3-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-4-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1241034934-25639-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

- pv_t, vg_t, lv_t, lvseg_t, pvseg_t
- include libdevmapper.h: needed for struct dm_list

These list structures will be needed in later APIs to return a list of
handles to one object, given another object.  For example, lvm_lvs_in_vg()
will return a list of LV handles (lv_t's) given a VG handle (vg_t).  We
need a structure to do this so we define the LV structure, as well as the
other structures at this point.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm.h |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index 55dcb68..b345b36 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -15,6 +15,7 @@
 #define _LIB_LVM_H
 
 #include "lvm-version.h"
+#include "libdevmapper.h"
 
 #include <stdint.h>
 
@@ -32,6 +33,32 @@ typedef struct logical_volume lv_t;
 typedef struct pv_segment pvseg_t;
 typedef struct lv_segment lvseg_t;
 
+typedef struct lvm_lvseg_list {
+	struct dm_list list;
+	lvseg_t *lvseg;
+} lvseg_list_t;
+
+typedef struct lvm_pvseg_list {
+	struct dm_list list;
+	pvseg_t *pvseg;
+} pvseg_list_t;
+
+typedef struct lvm_vg_list {
+	struct dm_list list;
+	vg_t *vg;
+} vg_list_t;
+
+typedef struct lvm_pv_list {
+	struct dm_list list;
+	pv_t *pv;
+} pv_list_t;
+
+typedef struct lvm_lv_list {
+	struct dm_list list;
+	lv_t *lv;
+} lv_list_t;
+
+
 struct lvm; /* internal data */
 
 /**
-- 
1.6.0.6


