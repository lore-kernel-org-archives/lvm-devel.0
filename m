From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:54 +0000 (UTC)
Subject: master - vgchange: fix uint32 parsing of logicalvolume arg
Message-ID: <20170213181054.2EED760EFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8152e4a99ee075c84fab9ec46485b798a1a6525d
Commit:        8152e4a99ee075c84fab9ec46485b798a1a6525d
Parent:        2224b6a70158a820de2a9f1fd961a36b0188da51
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 6 16:10:09 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

vgchange: fix uint32 parsing of logicalvolume arg

---
 tools/args.h           |    4 ++--
 tools/command-lines.in |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 1d7d6f7..a481bc5 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -964,10 +964,10 @@ arg(stripesize_ARG, 'I', "stripesize", sizekb_VAL, 0, 0,
     "The amount of data that is written to one device before\n"
     "moving to the next in a striped LV.\n")
 
-arg(logicalvolume_ARG, 'l', "logicalvolume", number_VAL, 0, 0,
+arg(logicalvolume_ARG, 'l', "logicalvolume", uint32_VAL, 0, 0,
     "Sets the maximum number of LVs allowed in a VG.\n")
 
-arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", number_VAL, 0, 0,
+arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", uint32_VAL, 0, 0,
     "Sets the maximum number of LVs allowed in a VG.\n")
 
 arg(extents_ARG, 'l', "extents", numsignedper_VAL, 0, 0,
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 30573f4..ca5259f 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1339,7 +1339,7 @@ OO_VGCHANGE: --autobackup Bool, --ignoremonitoring, --ignoreskippedcluster,
 # because it can function as a required opt.
 
 OO_VGCHANGE_META: --addtag Tag, --deltag Tag,
---logicalvolume Number, --maxphysicalvolumes Uint32, --alloc Alloc, --uuid,
+--logicalvolume Uint32, --maxphysicalvolumes Uint32, --alloc Alloc, --uuid,
 --clustered Bool, --pvmetadatacopies MetadataCopiesPV, --vgmetadatacopies MetadataCopiesVG,
 --physicalextentsize SizeMB, --resizeable Bool, --systemid String, --locktype LockType,
 --profile String, --detachprofile, --metadataprofile String
@@ -1405,7 +1405,7 @@ ID: vgconvert_general
 ---
 
 vgcreate VG_new PV ...
-OO: --addtag Tag, --alloc Alloc, --autobackup Bool, --clustered Bool, --maxlogicalvolumes Number,
+OO: --addtag Tag, --alloc Alloc, --autobackup Bool, --clustered Bool, --maxlogicalvolumes Uint32,
 --maxphysicalvolumes Uint32, --metadataprofile String, --metadatatype MetadataType,
 --physicalextentsize SizeMB, --force, --zero Bool, --labelsector Number,
 --metadatasize SizeMB, --pvmetadatacopies MetadataCopiesPV, --vgmetadatacopies MetadataCopiesVG,
@@ -1539,7 +1539,7 @@ OO_VGSPLIT: --autobackup Bool
 
 # used only when the destination VG is new
 OO_VGSPLIT_NEW: --alloc Alloc, --clustered Bool,
---maxlogicalvolumes Number, --maxphysicalvolumes Uint32,
+--maxlogicalvolumes Uint32, --maxphysicalvolumes Uint32,
 --metadatatype MetadataType, --vgmetadatacopies MetadataCopiesVG
 
 vgsplit VG VG PV ...


