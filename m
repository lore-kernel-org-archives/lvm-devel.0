From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 20 Feb 2017 23:06:40 +0000 (UTC)
Subject: master - man/help: print general raid type as "raid"
Message-ID: <20170220230640.733F061383@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e13639053b0d413624fb10baab535fde2c2c5bd5
Commit:        e13639053b0d413624fb10baab535fde2c2c5bd5
Parent:        d22cccdf631576d4fd0504ffd17812d778f9d37b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 20 15:41:24 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 20 15:41:24 2017 -0600

man/help: print general raid type as "raid"

Instead of printing "raid*".  There are already
notes mentioning that "raid" refers to "raid<N>"
---
 tools/vals.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/vals.h b/tools/vals.h
index 88c446e..4dc3a61 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -123,7 +123,7 @@ val(numsignedper_VAL, int_arg_with_sign_and_percent, "SNumberP", "[+|-]Number[%V
 val(permission_VAL, permission_arg, "Permission", "rw|r")
 val(metadatatype_VAL, metadatatype_arg, "MetadataType", "lvm2|lvm1")
 val(units_VAL, string_arg, "Units", "r|R|h|H|b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E")
-val(segtype_VAL, segtype_arg, "SegType", "linear|striped|snapshot|mirror|raid*|thin|cache|thin-pool|cache-pool")
+val(segtype_VAL, segtype_arg, "SegType", "linear|striped|snapshot|mirror|raid|thin|cache|thin-pool|cache-pool")
 val(alloc_VAL, alloc_arg, "Alloc", "contiguous|cling|cling_by_tags|normal|anywhere|inherit")
 val(locktype_VAL, locktype_arg, "LockType", "sanlock|dlm|none")
 val(readahead_VAL, readahead_arg, "Readahead", "auto|none|NumberSectors")


