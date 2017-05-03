From: David Teigland <teigland@sourceware.org>
Date: Wed, 3 May 2017 17:44:26 -0400
Subject: master - man vgexport: reference to vgimport
Message-ID: <201705032144.v43LiQFj008870@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=20026c9c223550633da73c5978686db389f19a17
Commit:        20026c9c223550633da73c5978686db389f19a17
Parent:        f2d943a4b60465f9fe06a6742bd2789372c0d15b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 3 16:44:01 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 3 16:44:01 2017 -0500

man vgexport: reference to vgimport

---
 man/vgexport.8_des |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/vgexport.8_des b/man/vgexport.8_des
index f9fa49c..66d3af3 100644
--- a/man/vgexport.8_des
+++ b/man/vgexport.8_des
@@ -1,6 +1,6 @@
 vgexport makes inactive VGs unknown to the system. In this state, all the
 PVs in the VG can be moved to a different system, from which
-\fBvgimport\fP can then be run.
+\fBvgimport\fP(8) can then be run.
 
 Most LVM tools ignore exported VGs.
 


