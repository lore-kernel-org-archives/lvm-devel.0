From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Mon,  8 Aug 2016 14:01:32 +0000 (UTC)
Subject: master - WHATS_NEW: reject --nosync option for RAID6 LVs in lvcreate
Message-ID: <20160808140132.D75E3605B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f90c954b72a5bad8cdeddebea4b3dc5981322c7
Commit:        6f90c954b72a5bad8cdeddebea4b3dc5981322c7
Parent:        c55134aa48644143ba398fdae30f47cb73b72ef9
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Aug 8 16:00:49 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Aug 8 16:00:49 2016 +0200

WHATS_NEW: reject --nosync option for RAID6 LVs in lvcreate

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f438fc8..b51cb79 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,7 @@
 Version 2.02.163 - 
 =================================
   Limit use of --corelog and --mirrorlog to mirrors in lvconvert.
+  Reject --nosync option for RAID6 LVs in lvcreate.
   Do not refresh whole cmd context if profile dropped after processing LVM cmd.
   Support straightforward lvconvert between striped and raid4 LVs.
   Support straightforward lvconvert between raid1 and mirror LVs.


