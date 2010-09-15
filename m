From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 15 Sep 2010 11:36:00 -0400
Subject: [PATCH 08/19] Add GET_STR_PROPERTY_FN macro.
In-Reply-To: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284564971-26060-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 9e3cad3..5f8f2ee 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -29,6 +29,15 @@ static int _ ## NAME ## _get (void *obj, struct lvm_property_type *prop) \
 	return 1; \
 }
 
+#define GET_STR_PROPERTY_FN(NAME, VALUE) \
+static int _ ## NAME ## _get (void *obj, struct lvm_property_type *prop) \
+{ \
+	struct volume_group *vg = (struct volume_group *)obj; \
+\
+	prop->v.s_val = (char *)VALUE;	\
+	return 1; \
+}
+
 static int _not_implemented(void *obj, struct lvm_property_type *prop)
 {
 	log_errno(ENOSYS, "Function not implemented");
-- 
1.7.2.1


