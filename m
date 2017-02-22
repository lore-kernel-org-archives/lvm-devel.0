From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Feb 2017 14:41:07 +0000 (UTC)
Subject: master - WHATS_NEW: add entry
Message-ID: <20170222144107.E742360D19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6716f5a2f46f034f24d01918cc1dc78cd7bac9be
Commit:        6716f5a2f46f034f24d01918cc1dc78cd7bac9be
Parent:        263050bc073e509f84de4c4da160887f412376fc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 22 15:20:23 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 22 15:20:52 2017 +0100

WHATS_NEW: add entry

---
 WHATS_NEW       |    1 +
 tools/toollib.c |    1 -
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c8b7fdc..b0768cd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Fix regression of accepting options --type and -m with lvresize (2.02.158).
   Add lvconvert --swapmetadata, new specific way to swap pool metadata LVs.
   Add lvconvert --startpoll, new specific way to start polling conversions.
   Add lvconvert --mergethin, new specific way to merge thin snapshots.
diff --git a/tools/toollib.c b/tools/toollib.c
index 842f67c..0e45d80 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5755,4 +5755,3 @@ bad:
 out:
 	return 0;
 }
-


