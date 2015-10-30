From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:06:03 +0000 (UTC)
Subject: master - New entries for pvs related fixes.
Message-ID: <20151030140603.4C6FE603AC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17196103e018a34eda016f6bdcd74395210cb114
Commit:        17196103e018a34eda016f6bdcd74395210cb114
Parent:        ccfc09f79b8d7ba15798a2b6f76545bb7fa3681e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 30 09:05:21 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 30 09:05:21 2015 -0500

New entries for pvs related fixes.

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 00e807e..415efc7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.133 - 
 ======================================
+  Fix missing PVs from pvs output if vgremove is run concurrently.
+  Remove unwanted error message when running pvs/vgs/lvs and vgremove at once.
   Check newly created VG's metadata do not overlap in metadata ring buffer.
   Check metadata area size is at least the minimum size defined for the format.
   Thin pool targets uses low_water_mark from profile.


