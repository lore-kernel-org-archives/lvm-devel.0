From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 29 Aug 2014 11:12:34 +0000 (UTC)
Subject: master - WHATS_NEW
Message-ID: <20140829111234.F25CE60FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca32920b1646b5d124c729e1ed7a83ce277d4803
Commit:        ca32920b1646b5d124c729e1ed7a83ce277d4803
Parent:        3c8fa2aa01dd6639b146e537ddcc2709752678d2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 29 13:00:16 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 29 13:10:20 2014 +0200

WHATS_NEW

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 79e32e7..6758389 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.111 - 
 ===================================
+  Pass properly sized char buffers for sscanf when initializing clvmd.
   Reinstate nosync logic when extending mirror. (2.02.110)
   Fix total area extent calculation when allocating cache pool. (2.02.110)
 


