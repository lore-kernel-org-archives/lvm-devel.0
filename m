From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 14 Aug 2013 08:18:09 +0000 (UTC)
Subject: master - WHATS_NEW: for 0da72743ca46ae9f8185cd12d5c78b3c2b801872
Message-ID: <20130814081809.634B560F92@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fcbb34bdccb21f0ed4c8fe990fdc68126f1cbf4f
Commit:        fcbb34bdccb21f0ed4c8fe990fdc68126f1cbf4f
Parent:        80bcdb93ffcd69e03923ceeac5afc018831d0cfc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 14 10:18:02 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 14 10:18:02 2013 +0200

WHATS_NEW: for 0da72743ca46ae9f8185cd12d5c78b3c2b801872

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 67c4b18..c7fda19 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Fix vgck to notice on-disk corruption even if lvmetad is used.
   Move mpath device filter before partitioned filter (which opens devices).
   Split partitioned filter out of lvm_type filter.
   Merge filter*.h into a single filter.h.


