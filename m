From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri,  5 Aug 2016 14:07:39 +0000 (UTC)
Subject: master - WHATS_NEW: add '--rebuild PV' option to lvchange to allow for PV selective rebuilds
Message-ID: <20160805140739.82BC160F13@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9aefe9aa7ace98fa2e1cb2867a8f895e9caf380d
Commit:        9aefe9aa7ace98fa2e1cb2867a8f895e9caf380d
Parent:        d2c3b23e6dc39565093256c97ff66984e8648bda
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Aug 5 16:07:14 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Aug 5 16:07:14 2016 +0200

WHATS_NEW: add '--rebuild PV' option to lvchange to allow for PV selective rebuilds

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3a64bbd..dce14a9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -4,6 +4,7 @@ Version 2.02.163 -
   Forbid stripe parameters with lvconvert --repair.
   Unify stripe size validation into get_stripe_params to catch missing cases.
   Further lvconvert validation logic refactoring.
+  Add "--rebuild PV" option to lvchange to allow for PV selective rebuilds.
 
 Version 2.02.162 - 28th July 2016
 =================================


