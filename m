From: Tony Asleson <tasleson@redhat.com>
Date: Tue,  5 May 2015 16:34:16 -0500
Subject: [PATCH 2/5] python: Build correct python value for numerical property
In-Reply-To: <1430861659-2755-1-git-send-email-tasleson@redhat.com>
References: <1430861659-2755-1-git-send-email-tasleson@redhat.com>
Message-ID: <1430861659-2755-3-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

With the lvm2app C API adding the ability to determine when a property is
signed we can then use this information to construct the correct representation
of the number for python which will maintain value and sign.  Previously, we
only represented the numbers in python as positive integers.

Python long type exceeds the range for unsigned and signed integers, we just
need to use the appropriate parsing code to build correctly.

Python part of the fix for:
https://bugzilla.redhat.com/show_bug.cgi?id=838257

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 6151745..f4a7a2d 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -870,10 +870,15 @@ static PyObject *get_property(struct lvm_property_value *prop)
 	if (!(pytuple = PyTuple_New(2)))
 		return NULL;
 
-	if (prop->is_integer)
-		PyTuple_SET_ITEM(pytuple, 0, Py_BuildValue("K", prop->value.integer));
-	else
+	if (prop->is_integer) {
+		if (prop->is_signed) {
+			PyTuple_SET_ITEM(pytuple, 0, Py_BuildValue("L", prop->value.signed_integer));
+		} else {
+			PyTuple_SET_ITEM(pytuple, 0, Py_BuildValue("K", prop->value.integer));
+		}
+	} else {
 		PyTuple_SET_ITEM(pytuple, 0, PYSTRTYPE_FROMSTRING(prop->value.string));
+	}
 
 	if (prop->is_settable)
 		setable = Py_True;
-- 
1.8.2.1


