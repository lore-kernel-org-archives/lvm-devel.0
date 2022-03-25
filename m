From: David Teigland <teigland@sourceware.org>
Date: Fri, 25 Mar 2022 22:26:26 +0000 (GMT)
Subject: main - fix args entry for nolocking
Message-ID: <20220325222626.5FFD13858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=86a0a652a9eedd932c7428ed82656f3fd40d13f8
Commit:        86a0a652a9eedd932c7428ed82656f3fd40d13f8
Parent:        f1578b4a5d0bf49ab2b07c86c982cfa5aaa60a84
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 25 17:25:29 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 25 17:25:29 2022 -0500

fix args entry for nolocking

typo in previous commit
---
 tools/args.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/args.h b/tools/args.h
index ecb650234..03fe24556 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -499,7 +499,7 @@ arg(nohistory_ARG, '\0', "nohistory", 0, 0, 0,
     "metadata/record_lvs_history is enabled.\n")
 
 arg(nolocking_ARG, '\0', "nolocking", 0, 0, 0,
-    "Disable locking. Use with caution, concurrent commands may produce\n")
+    "Disable locking. Use with caution, concurrent commands may produce\n"
     "incorrect results.\n")
 
 arg(norestorefile_ARG, '\0', "norestorefile", 0, 0, 0,

