From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 16:35:16 +0000 (UTC)
Subject: master - prop: update FIELD macro to accomodate the differentiation of number, size and percent field values
Message-ID: <20140617163516.A1EF760D68@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d09590c4b601f261d164fd253c7f2b9864cbf7ab
Commit:        d09590c4b601f261d164fd253c7f2b9864cbf7ab
Parent:        94316dfe9d61a7b46c88458e4a8232667fde192a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 17 18:14:38 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 18:14:57 2014 +0200

prop: update FIELD macro to accomodate the differentiation of number, size and percent field values

The differentiation of the original number field into number, size and
percent field types has been introduced with recent changes for report
selection support.
---
 lib/properties/prop_common.h |    2 +-
 lib/report/properties.c      |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/properties/prop_common.h b/lib/properties/prop_common.h
index 6972f9f..6d4c2e4 100644
--- a/lib/properties/prop_common.h
+++ b/lib/properties/prop_common.h
@@ -128,6 +128,6 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 
 #define FIELD_MODIFIABLE 0x00000001
 #define FIELD(type, strct, field_type, head, field, width, fn, id, desc, settable) \
-	{ type, #id, settable, field_type == STR, field_type == NUM, { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
+	{ type, #id, settable, field_type == STR, ((field_type == NUM) || (field_type == SIZ) || (field_type == PCT)), { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
 
 #endif
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 0c49b0f..ce3ed53 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -343,6 +343,7 @@ struct lvm_property_type _properties[] = {
 #undef STR
 #undef NUM
 #undef SIZ
+#undef PCT
 #undef STR_LIST
 #undef FIELD
 


