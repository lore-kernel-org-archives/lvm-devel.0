From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri,  5 Aug 2016 14:32:09 +0000 (UTC)
Subject: master - WHATS_NEW: fixup order
Message-ID: <20160805143209.4259A6073F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=802bd34562f810b9f183c5b20cd24fc5675e2f98
Commit:        802bd34562f810b9f183c5b20cd24fc5675e2f98
Parent:        8f25ad6416ee6edb2648ddd207a39819a6f99c1e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Aug 5 16:31:46 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Aug 5 16:31:46 2016 +0200

WHATS_NEW: fixup order

---
 WHATS_NEW |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dce14a9..df1a434 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,10 +1,10 @@
 Version 2.02.163 - 
 =================================
+  Add "--rebuild PV" option to lvchange to allow for PV selective rebuilds.
   Preserve existing mirror region size when using --repair.
   Forbid stripe parameters with lvconvert --repair.
   Unify stripe size validation into get_stripe_params to catch missing cases.
   Further lvconvert validation logic refactoring.
-  Add "--rebuild PV" option to lvchange to allow for PV selective rebuilds.
 
 Version 2.02.162 - 28th July 2016
 =================================


