From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 25 Feb 2015 20:59:20 +0000 (UTC)
Subject: master - WHATS_NEW: vgimport with lvmetad
Message-ID: <20150225205920.C39D360D6F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bbaabb8a59980995dfa94948589034c6a93b9f5a
Commit:        bbaabb8a59980995dfa94948589034c6a93b9f5a
Parent:        2c50cbe8cbd5197793abb6f43f42b53980cdc65e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 25 12:30:00 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 25 14:59:24 2015 -0600

WHATS_NEW: vgimport with lvmetad

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c119f3e..f4c4cde 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Rescan devices before vgimport with lvmetad so exported VG is seen.
   Fix hang by adjusting cluster mirror regionsize, avoiding CPG msg limit.
   Do not crash when --cachepolicy is given without --cachesettings.
   Add NEEDS_FOREIGN_VGS flag to vgimport so --foreign is always supplied.


