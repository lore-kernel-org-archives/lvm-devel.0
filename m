From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:55 +0000 (GMT)
Subject: stable-2.02 - WHATS_NEW: update
Message-ID: <20201016191055.177E3396EC06@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6b97921ee849914e1476d718208ac449cf3c982e
Commit:        6b97921ee849914e1476d718208ac449cf3c982e
Parent:        6de0f5eab9e78ab1b9f5b3acd7d8b8ceddc1213f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 21:42:12 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:06 2020 +0200

WHATS_NEW: update

---
 WHATS_NEW | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7f5fad9ae..2640924f5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.188 - 
 ==================================
+  Preserve uint32_t for seqno handling.
+  Switch from mmap to plain read when loading regular files.
   Fix running out of free buffers for async writing for larger writes.
   Fix conversion to raid from striped lagging type.
   Fix conversion to 'mirrored' mirror log with larger regionsize.


