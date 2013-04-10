From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 10 Apr 2013 21:47:22 +0000 (UTC)
Subject: master - WHATS_NEW: Include entry for RAID status func improvements
Message-ID: <20130410214722.B2F37672@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95d28735ea3ad54be972707e40ee0211106ef1d1
Commit:        95d28735ea3ad54be972707e40ee0211106ef1d1
Parent:        38f8f4a958980c236bf19f6e58afd55fdcdd3312
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Apr 8 15:17:12 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Apr 8 15:17:12 2013 -0500

WHATS_NEW: Include entry for RAID status func improvements

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 525c173..c41dd04 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Improve RAID kernel status retrieval to include sync_action/mismatch_cnt.
   Add external origin support for lvcreate.
   Improve lvcreate, lvconvert and lvm man pages.
   Clean up format1 PV write to remove a need for an orphan VG for it to pass.


