From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 11 Apr 2013 21:04:02 +0000 (UTC)
Subject: master - WHATS_NEW: Add WHATS_NEW entry for previous commit.
Message-ID: <20130411210402.3BBE81B9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=719e908bc010455fc14589d941b949c5f3c92806
Commit:        719e908bc010455fc14589d941b949c5f3c92806
Parent:        faeea370571b6525d9d95d2904aaacbdb9552e00
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Apr 11 16:03:24 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Apr 11 16:03:24 2013 -0500

WHATS_NEW:  Add WHATS_NEW entry for previous commit.

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 43c39d6..11e838e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Revert change that allowed identical table reload for RAID.
   New lvchange arg, '--syncaction' allows scrubbing of RAID LVs.
   Improve RAID kernel status retrieval to include sync_action/mismatch_cnt.
   Add external origin support for lvcreate.


