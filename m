From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 13 Nov 2014 16:53:35 +0000 (UTC)
Subject: master - lvm2api: use fully initilized struct
Message-ID: <20141113165335.D308C601FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7278556c768ae418b03873bd5d9e921e13ce79e8
Commit:        7278556c768ae418b03873bd5d9e921e13ce79e8
Parent:        49e3fd1ce8d0b1023f553673e76b49e65348878f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 13 17:42:09 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 13 17:49:41 2014 +0100

lvm2api: use fully initilized struct

Don't pass partially initialized struct.
---
 python/liblvm.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 1b0942d..3828f27 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -324,9 +324,10 @@ static PyObject *_liblvm_lvm_pv_remove(PyObject *self, PyObject *arg)
 static int _set_pv_numeric_prop(pv_create_params_t pv_params, const char *name,
 								unsigned long long value)
 {
-	struct lvm_property_value prop_value;
-	prop_value.is_integer = 1;
-	prop_value.value.integer = value;
+	struct lvm_property_value prop_value = {
+		.is_integer = 1,
+		.value.integer = value,
+	};
 
 	return lvm_pv_params_set_property(pv_params, name, &prop_value);
 }


