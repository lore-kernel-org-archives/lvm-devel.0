From: Tony Asleson <tasleson@redhat.com>
Date: Tue,  5 May 2015 14:25:29 -0500
Subject: [PATCH 3/5] python: Check for value before constructing string property
In-Reply-To: <1430853931-20572-1-git-send-email-tasleson@redhat.com>
References: <1430853931-20572-1-git-send-email-tasleson@redhat.com>
Message-ID: <1430853931-20572-4-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In the case where there is no value we were segfaulting.  In this
case we will return None.

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
-- 
1.7.1


