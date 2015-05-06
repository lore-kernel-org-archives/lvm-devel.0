From: tasleson <tasleson@fedoraproject.org>
Date: Wed,  6 May 2015 13:53:17 +0000 (UTC)
Subject: master - python: Check for NULL value before constructing string property
Message-ID: <20150506135317.D03CF60C24@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8c11c7df0f1d582494922cbadb717296c02e05b
Commit:        e8c11c7df0f1d582494922cbadb717296c02e05b
Parent:        c21f1ba07a4701b0653bc086673be43ede20efc1
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon May 4 15:19:48 2015 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed May 6 08:51:04 2015 -0500

python: Check for NULL value before constructing string property

When retrieving a property value that is a string, if the character pointer in C
was NULL, we would segfault.  This change checks for non-null before creating a
python string representation.  In the case where the character pointer is NULL
we will return a python 'None' for the value.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index f4a7a2d..089abb3 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -877,7 +877,11 @@ static PyObject *get_property(struct lvm_property_value *prop)
 			PyTuple_SET_ITEM(pytuple, 0, Py_BuildValue("K", prop->value.integer));
 		}
 	} else {
-		PyTuple_SET_ITEM(pytuple, 0, PYSTRTYPE_FROMSTRING(prop->value.string));
+		if ( prop->value.string ) {
+			PyTuple_SET_ITEM(pytuple, 0, PYSTRTYPE_FROMSTRING(prop->value.string));
+		} else {
+			PyTuple_SET_ITEM(pytuple, 0, Py_None);
+		}
 	}
 
 	if (prop->is_settable)


