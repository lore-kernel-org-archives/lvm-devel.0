From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 Jan 2011 12:17:30 +0100
Subject: [PATCH 2/8] Add default error path for get_property
In-Reply-To: <cover.1294398815.git.zkabelac@redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>
Message-ID: <6bbe3896c9173603df3be06a3e60dd79f339e028.1294398815.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Set invalid property value for error path when none of handlers is set.
Fixes use of uninitialized prop variable as we return 'v' by value.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 liblvm/lvm_misc.c |   26 +++++++++++---------------
 1 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index 62fef61..e5464fe 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -52,33 +52,29 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 	struct lvm_property_type prop;
 	struct lvm_property_value v;
 
+	memset(&v, 0, sizeof(v));
 	prop.id = name;
+
 	if (pv) {
-		if (!pv_get_property(pv, &prop)) {
-			v.is_valid = 0;
+		if (!pv_get_property(pv, &prop))
 			return v;
-		}
 	} else if (vg) {
-		if (!vg_get_property(vg, &prop)) {
-			v.is_valid = 0;
+		if (!vg_get_property(vg, &prop))
 			return v;
-		}
 	} else if (lv) {
-		if (!lv_get_property(lv, &prop)) {
-			v.is_valid = 0;
+		if (!lv_get_property(lv, &prop))
 			return v;
-		}
 	} else if (lvseg) {
-		if (!lvseg_get_property(lvseg, &prop)) {
-			v.is_valid = 0;
+		if (!lvseg_get_property(lvseg, &prop))
 			return v;
-		}
 	} else if (pvseg) {
-		if (!pvseg_get_property(pvseg, &prop)) {
-			v.is_valid = 0;
+		if (!pvseg_get_property(pvseg, &prop))
+			return v;
+	} else {
+			log_errno(EINVAL, "Invalid query for property.");
 			return v;
-		}
 	}
+
 	v.is_settable = prop.is_settable;
 	v.is_string = prop.is_string;
 	v.is_integer = prop.is_integer;
-- 
1.7.3.4


