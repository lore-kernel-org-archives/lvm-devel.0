From: Tony Asleson <tasleson@redhat.com>
Date: Tue,  5 May 2015 14:25:30 -0500
Subject: [PATCH 4/5] lvm2app: Correct missing string properties
In-Reply-To: <1430853931-20572-1-git-send-email-tasleson@redhat.com>
References: <1430853931-20572-1-git-send-email-tasleson@redhat.com>
Message-ID: <1430853931-20572-5-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We were not handling the case correctly where the return value was a
string list instead of simply being a string.

https://bugzilla.redhat.com/show_bug.cgi?id=1139920

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/properties/prop_common.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/properties/prop_common.h b/lib/properties/prop_common.h
index 0b1678d..9cc963a 100644
--- a/lib/properties/prop_common.h
+++ b/lib/properties/prop_common.h
@@ -132,6 +132,6 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 
 #define FIELD_MODIFIABLE 0x00000001
 #define FIELD(type, strct, field_type, head, field, width, fn, id, desc, settable) \
-	{ type, #id, settable, field_type == STR, ((field_type == NUM) || (field_type == BIN) || (field_type == SIZ) || (field_type == PCT) || (field_type == SNUM)), ((field_type == SNUM) || (field_type == PCT)), { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
+	{ type, #id, settable, (field_type == STR || field_type == STR_LIST), ((field_type == NUM) || (field_type == BIN) || (field_type == SIZ) || (field_type == PCT) || (field_type == SNUM)), ((field_type == SNUM) || (field_type == PCT)), { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
 
 #endif
-- 
1.7.1


