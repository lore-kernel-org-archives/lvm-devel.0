From: David Teigland <teigland@sourceware.org>
Date: Mon, 27 Feb 2017 18:08:55 -0500
Subject: master - man: mention regionsize default is in lvm.conf
Message-ID: <201702272308.v1RN8tLm030850@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f9d28f1aeccaa923dfe31fda982d2a5fd5ef0f2d
Commit:        f9d28f1aeccaa923dfe31fda982d2a5fd5ef0f2d
Parent:        998151e83e5f1673266ffad213a35b377c3a999b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 27 17:05:20 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 27 17:05:20 2017 -0600

man: mention regionsize default is in lvm.conf

---
 tools/args.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index dd25007..f4eec0b 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1230,7 +1230,9 @@ arg(resizefs_ARG, 'r', "resizefs", 0, 0, 0,
 arg(reset_ARG, 'R', "reset", 0, 0, 0, NULL)
 
 arg(regionsize_ARG, 'R', "regionsize", regionsize_VAL, 0, 0,
-    "Size of each raid or mirror synchronization region.\n")
+    "Size of each raid or mirror synchronization region.\n"
+    "lvm.conf activation/raid_region_size can be used to\n"
+    "configure a default.\n")
 
 arg(physicalextentsize_ARG, 's', "physicalextentsize", sizemb_VAL, 0, 0,
     "#vgcreate\n"


