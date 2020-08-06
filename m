From: Tony Asleson <tasleson@sourceware.org>
Date: Thu,  6 Aug 2020 20:44:16 +0000 (GMT)
Subject: master - WHATS_NEW: Add writecache lvmdbusd
Message-ID: <20200806204416.8F4D53857C45@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4f44841045ec9420a4bb9a141fab55cb95260b45
Commit:        4f44841045ec9420a4bb9a141fab55cb95260b45
Parent:        d4d060acd5e35ca052dd4ba0743732ed4fb46f86
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Aug 6 15:42:49 2020 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Aug 6 15:42:49 2020 -0500

WHATS_NEW: Add writecache lvmdbusd

---
 WHATS_NEW | 1 +
 1 file changed, 1 insertion(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 562b1765b..87779c3e7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.10 - 
 =================================
+  Add writecache support to lvmdbusd.
   Fix conversion to raid from striped lagging type.
   Fix conversion to 'mirrored' mirror log with larger regionsize.
   Zero pool metadata on allocation (disable with allocation/zero_metadata=0).


