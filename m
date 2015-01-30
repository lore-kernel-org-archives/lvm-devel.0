From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 10:21:48 +0000 (UTC)
Subject: master - properties: also recognize LVSINFO, LVSSTATUS and LVSINFOSTATUS as subtypes of LVS
Message-ID: <20150130102148.418746138D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8650404df1884f1e040aad4343c8db0eac71e125
Commit:        8650404df1884f1e040aad4343c8db0eac71e125
Parent:        531cc58d899b7dd1421bfe83f5503aa266390334
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 30 11:13:49 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 11:13:49 2015 +0100

properties: also recognize LVSINFO, LVSSTATUS and LVSINFOSTATUS as subtypes of LVS

LVSINFO, LVSSTATUS and LVSINFOSTATUS is the same as LVS, just with some
extra info/status decoration attached to it. Recognize this when looking
for properties for lvm2app. This fixes lvm_lv_get_property lvm2app call
for fields which already use LVS{INFO,STATUS,INFOSTATUS} - currently,
this is lv_attr field which was converted to LVSINFOSTATUS from
pure LVS type.
---
 lib/report/properties.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 8866928..c1c9563 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -476,7 +476,7 @@ int lvseg_get_property(const struct lv_segment *lvseg,
 int lv_get_property(const struct logical_volume *lv,
 		    struct lvm_property_type *prop)
 {
-	return prop_get_property(_properties, lv, prop, LVS);
+	return prop_get_property(_properties, lv, prop, LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS);
 }
 
 int vg_get_property(const struct volume_group *vg,
@@ -500,7 +500,7 @@ int pv_get_property(const struct physical_volume *pv,
 int lv_set_property(struct logical_volume *lv,
 		    struct lvm_property_type *prop)
 {
-	return prop_set_property(_properties, lv, prop, LVS);
+	return prop_set_property(_properties, lv, prop, LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS);
 }
 
 int vg_set_property(struct volume_group *vg,


