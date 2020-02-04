From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:23:22 -0500
Subject: master - WHATS_NEW: update
Message-ID: <17071.120020411231800495@us-mta-116.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9255c7148ac3d920aafe58f78a9672dd3a0967bd
Commit:        9255c7148ac3d920aafe58f78a9672dd3a0967bd
Parent:        aa7642a44441c63dd71184b70f5c3955696a5ad4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 4 17:21:13 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

WHATS_NEW: update

---
 WHATS_NEW | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 66ea748..b03eb97 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
 Version 2.03.08 - 
 ====================================
+  Add error handling for failing allocation in _reserve_area().
+  Fix memleak in syncing of internal cache.
+  Fix pvck dump_current_text memleak.
+  Fix lvmlockd result code on error path for _query_lock_lv().
   Accept more output lines from vdo_format.
   Prohibit reshaping of stacked raid LVs.
   Avoid running cache input arg validation when creating vdo pool.



