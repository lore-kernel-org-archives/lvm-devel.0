From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 23 Mar 2016 09:52:54 +0000 (UTC)
Subject: master - properties: use proper 'get' variant for unimplemented _pv_major_get and _pv_minor_get fns
Message-ID: <20160323095254.BE31A607A3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6d383a6da5cd7f5acddb314e1419243447e7be8
Commit:        c6d383a6da5cd7f5acddb314e1419243447e7be8
Parent:        1056894f1f1d48eb295d283859473cd9bc6b9df5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 23 10:52:46 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 23 10:52:46 2016 +0100

properties: use proper 'get' variant for unimplemented _pv_major_get and _pv_minor_get fns

---
 lib/report/properties.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 7c9bb0c..234712c 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -194,9 +194,9 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _pv_ext_vsn_set prop_not_implemented_set
 #define _pv_in_use_get prop_not_implemented_get
 #define _pv_in_use_set prop_not_implemented_set
-#define _pv_major_get prop_not_implemented_set
+#define _pv_major_get prop_not_implemented_get
 #define _pv_major_set prop_not_implemented_set
-#define _pv_minor_get prop_not_implemented_set
+#define _pv_minor_get prop_not_implemented_get
 #define _pv_minor_set prop_not_implemented_set
 
 #define _vg_permissions_set prop_not_implemented_set


