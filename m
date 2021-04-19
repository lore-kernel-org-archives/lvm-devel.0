From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:00:53 +0000 (GMT)
Subject: main - tools: correct units description
Message-ID: <20210419130053.E79E2396903C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=82e3b2e0adda88cd5542c97486ba6e8da28d2a47
Commit:        82e3b2e0adda88cd5542c97486ba6e8da28d2a47
Parent:        7bde16f5e17e8379f47696c731849176cd2f83b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 16 21:29:10 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:40:14 2021 +0200

tools: correct units description

Option --units takes also [Number] to express size in configurable
units.
---
 tools/vals.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/vals.h b/tools/vals.h
index 098dc9e4e..addbea2f2 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -127,7 +127,7 @@ val(pextents_VAL, pextents_arg, "PExtents", "[+]Number[PERCENT]")
 val(nextents_VAL, nextents_arg, "NExtents", "[-]Number[PERCENT]")
 val(permission_VAL, permission_arg, "Permission", "rw|r")
 val(metadatatype_VAL, metadatatype_arg, "MetadataType", "lvm2")
-val(units_VAL, string_arg, "Units", "r|R|h|H|b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E")
+val(units_VAL, string_arg, "Units", "[Number]r|R|h|H|b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E")
 val(segtype_VAL, segtype_arg, "SegType", "linear|striped|snapshot|raid|mirror|thin|thin-pool|vdo|vdo-pool|cache|cache-pool|writecache")
 val(alloc_VAL, alloc_arg, "Alloc", "contiguous|cling|cling_by_tags|normal|anywhere|inherit")
 val(locktype_VAL, locktype_arg, "LockType", "sanlock|dlm|none")


