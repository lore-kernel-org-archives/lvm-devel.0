From: tasleson <tasleson@fedoraproject.org>
Date: Wed,  6 May 2015 13:53:20 +0000 (UTC)
Subject: master - lvm2app: Correct missing string properties
Message-ID: <20150506135320.0C8D060FDD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc5190de74893ede7d3170b861ce8ae9327ecfae
Commit:        dc5190de74893ede7d3170b861ce8ae9327ecfae
Parent:        e8c11c7df0f1d582494922cbadb717296c02e05b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon May 4 15:20:55 2015 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed May 6 08:51:04 2015 -0500

lvm2app: Correct missing string properties

Synopsis: STR_LIST needs to be treated as STR for properties.

For any lvm property that was internally 'typed' as a string list we were failing
to return a string in the property API.  This was due to the fact that for the
properties to work the value needs to either be evaulated as a string or a
number.  This change corrects the macro used to build the memory array of
structures so that the string bitfield is set as needed to ensure that the value
is a string.

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


