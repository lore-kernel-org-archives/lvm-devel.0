From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  4 Aug 2014 15:06:41 +0000 (UTC)
Subject: master - WHATS_NEW: lvscan --cache SEGV fix
Message-ID: <20140804150641.6D3F060701@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46262f163b2a6c802f91076c2675bda4be5d8a2d
Commit:        46262f163b2a6c802f91076c2675bda4be5d8a2d
Parent:        0208665209c4e8f02841a426e6073a48195f56c1
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Aug 4 17:05:08 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Aug 4 17:05:08 2014 +0200

WHATS_NEW: lvscan --cache SEGV fix

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ff30039..8397d30 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.109 - 
 =================================
+  Fix a segfault in lvscan --cache when devices were already missing.
   Fix incorrect persistent .cache after vgcreate with PV creation. (2.02.108)
   Display actual size changed when resizing LV.
   Allow approximate allocation with +%FREE in lvextend.


