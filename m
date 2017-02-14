From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 14 Feb 2017 16:21:49 +0000 (UTC)
Subject: master - man/help: use separator in units list
Message-ID: <20170214162149.238FA60209@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1dddb068c90d553957dd8668b76c3eb9734b2e95
Commit:        1dddb068c90d553957dd8668b76c3eb9734b2e95
Parent:        c0f2a59993e373781c6dd5568cd559547cfe49a1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 14 10:20:38 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 14 10:21:39 2017 -0600

man/help: use separator in units list

h|H|b|B|... instead of hHbB...
---
 tools/vals.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/vals.h b/tools/vals.h
index 38029aa..d9b0064 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -122,7 +122,7 @@ val(numsigned_VAL, int_arg_with_sign, "SNumber", "[+|-]Number")
 val(numsignedper_VAL, int_arg_with_sign_and_percent, "SNumberP", "[+|-]Number[%VG|%PVS|%FREE]")
 val(permission_VAL, permission_arg, "Permission", "rw|r")
 val(metadatatype_VAL, metadatatype_arg, "MetadataType", "lvm2|lvm1")
-val(units_VAL, string_arg, "Units", "hHbBsSkKmMgGtTpPeE")
+val(units_VAL, string_arg, "Units", "h|H|b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E")
 val(segtype_VAL, segtype_arg, "SegType", "linear|striped|snapshot|mirror|raid*|thin|cache|thin-pool|cache-pool")
 val(alloc_VAL, alloc_arg, "Alloc", "contiguous|cling|cling_by_tags|normal|anywhere|inherit")
 val(locktype_VAL, locktype_arg, "LockType", "sanlock|dlm|none")


