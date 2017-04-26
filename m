From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Wed, 26 Apr 2017 16:50:41 -0400
Subject: master - typo: s/extends/extents/ in lvmthin man page
Message-ID: <201704262050.v3QKofGO032215@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=78a0b4a08a7178250b9d0b3be7f975440975d9d4
Commit:        78a0b4a08a7178250b9d0b3be7f975440975d9d4
Parent:        0f31f10ac5881b2780b0083f5e45fed59aeb8013
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Apr 26 15:49:28 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Apr 26 15:49:28 2017 -0500

typo: s/extends/extents/ in lvmthin man page

bug 1439905
---
 man/lvmthin.7_main |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index a6c8123..c5efa9c 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -1016,7 +1016,7 @@ Possible discard behaviors:
 ignore: Ignore any discards that are received.
 
 nopassdown: Process any discards in the thin pool itself and allow
-the no longer needed extends to be overwritten by new data.
+the no longer needed extents to be overwritten by new data.
 
 passdown: Process discards in the thin pool (as with nopassdown), and
 pass the discards down the the underlying device.  This is the default


