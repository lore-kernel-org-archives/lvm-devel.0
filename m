From: tasleson <tasleson@fedoraproject.org>
Date: Wed,  6 May 2015 13:53:15 +0000 (UTC)
Subject: master - python: Build correct python value for numerical property
Message-ID: <20150506135315.B099060C24@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c21f1ba07a4701b0653bc086673be43ede20efc1
Commit:        c21f1ba07a4701b0653bc086673be43ede20efc1
Parent:        91f737383c7c4be70689c9d6ce809de00dc1485e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon May 4 14:55:00 2015 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed May 6 08:51:04 2015 -0500

python: Build correct python value for numerical property

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
 python/liblvm.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

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


