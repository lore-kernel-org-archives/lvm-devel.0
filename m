From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Jul 2013 19:39:15 +0000 (UTC)
Subject: master - WHATS_NEW: support for LV activation skip flag
Message-ID: <20130712193915.4589B612BC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a44ba94a5ab54aaad9fdc6c2e1d1eb4587fd651
Commit:        9a44ba94a5ab54aaad9fdc6c2e1d1eb4587fd651
Parent:        4e680ff3ab36816cbccce793cc69c2e0cae68330
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 12 19:52:32 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 12 21:37:58 2013 +0200

WHATS_NEW: support for LV activation skip flag

---
 WHATS_NEW |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b3b846c..1f1a984 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,11 @@
 Version 2.02.99 - 
 ===================================
+  Add activation/auto_set_activation_skip to control activation skip flagging.
+  Add 's(k)ip activation' bit to lvs -o lv_attr to indicate skip flag attached.
+  Add --ignoreactivationskip to lvcreate/vgchange/lvchange to ignore skip flag.
+  Add --setactivationskip to lvcreate/lvchange to set activation skip flag.
+  Automatically flag thin snapshots to be skipped during activation.
+  Add support for persistent flagging of LVs to be skipped during activation.
   Add --type profilable to lvm dumpconfig to show profilable config settings.
   Add --mergedconfig to lvm dumpconfig for merged --config/--profile/lvm.conf.
   Relase memory and unblock signals in lock_vol error path.


