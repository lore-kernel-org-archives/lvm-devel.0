From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 18 May 2016 14:21:07 +0000 (UTC)
Subject: master - WHATS_NEW: include recent changes
Message-ID: <20160518142107.1360C60614@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e694e0896bd4d320f5d5017411763583698b28dc
Commit:        e694e0896bd4d320f5d5017411763583698b28dc
Parent:        591ef307b30c2d828b2a0c59918203f970974bbb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 18 09:20:37 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 18 09:20:52 2016 -0500

WHATS_NEW: include recent changes

---
 WHATS_NEW |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 618e3dc..9b9265c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,11 @@
 Version 2.02.155 - 
 ================================
+  Fix liblvm2app error handling when setting up context.
+  Delay liblvm2app init in python code until it is needed.
+  Simplify thread locking in lvmetad to fix locking problems.
+  Allow pvremove -ff to remove a duplicate PV.
+  Fix lvm2-activation-generator to read lvm.conf without full command setup.
+  Allow a minimal context to be used in lvm2app for reading lvm.conf.
 
 Version 2.02.154 - 14th May 2016
 ================================


