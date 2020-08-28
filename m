From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:21 +0000 (GMT)
Subject: master - WHATS_NEW: update
Message-ID: <20200828195921.11E6E3840C13@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f0614e7cf05df969f9789f0746b820ce5cbb33a2
Commit:        f0614e7cf05df969f9789f0746b820ce5cbb33a2
Parent:        b722ce2f1000da1ed321d43ef4858d1dd5d567d8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 21:42:12 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:03 2020 +0200

WHATS_NEW: update

---
 WHATS_NEW | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index cdc491c83..d433ddf9a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.03.11 - 
 ==================================
+  Preserve uint32_t for seqno handling.
+  Switch from mmap to plain read when loading regular files.
   Fix missing device closing on wiping error path.
   Update lvmvdo man page and better explain DISCARD usage.
 


