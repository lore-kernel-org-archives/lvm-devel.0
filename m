From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 17 Feb 2017 21:34:10 +0000 (UTC)
Subject: master - man/help: show recently added r|R unit
Message-ID: <20170217213410.E3E4560E29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10cb8e0ec08d430d697fb8a58caaefb5aea32928
Commit:        10cb8e0ec08d430d697fb8a58caaefb5aea32928
Parent:        3cf394389896a1bd6b3780671e6a6654a925bdd3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 17 14:02:13 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 17 14:44:11 2017 -0600

man/help: show recently added r|R unit

---
 tools/args.h |   11 +++++++----
 tools/vals.h |    2 +-
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 149b5f6..1f3ace7 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -672,10 +672,13 @@ arg(unconfigured_ARG, '\0', "unconfigured", 0, 0, 0,
     "Internal option used for generating config file during build.\n")
 
 arg(units_ARG, '\0', "units", units_VAL, 0, 0,
-    "All sizes are output in these units: (h)uman-readable, (b)ytes, (s)ectors,\n"
-    "(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.\n"
-    "Capitalise to use multiples of 1000 (S.I.) instead of 1024. Can also specify\n"
-    "custom units e.g. --units 3M.\n")
+    "All sizes are output in these units:\n"
+    "human-(r)eadable with rounding,\n"
+    "(h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,\n"
+    "(g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.\n"
+    "Capitalise to use multiples of 1000 (S.I.) instead of 1024.\n"
+    "Custom units can be specified, e.g. --units 3M.\n"
+    "r|R rounds numbers and displays the '<' prefix before rounded values.\n")
 
 arg(unquoted_ARG, '\0', "unquoted", 0, 0, 0,
     "When used with --nameprefixes, output values in the field=value\n"
diff --git a/tools/vals.h b/tools/vals.h
index d9b0064..88c446e 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -122,7 +122,7 @@ val(numsigned_VAL, int_arg_with_sign, "SNumber", "[+|-]Number")
 val(numsignedper_VAL, int_arg_with_sign_and_percent, "SNumberP", "[+|-]Number[%VG|%PVS|%FREE]")
 val(permission_VAL, permission_arg, "Permission", "rw|r")
 val(metadatatype_VAL, metadatatype_arg, "MetadataType", "lvm2|lvm1")
-val(units_VAL, string_arg, "Units", "h|H|b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E")
+val(units_VAL, string_arg, "Units", "r|R|h|H|b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E")
 val(segtype_VAL, segtype_arg, "SegType", "linear|striped|snapshot|mirror|raid*|thin|cache|thin-pool|cache-pool")
 val(alloc_VAL, alloc_arg, "Alloc", "contiguous|cling|cling_by_tags|normal|anywhere|inherit")
 val(locktype_VAL, locktype_arg, "LockType", "sanlock|dlm|none")


