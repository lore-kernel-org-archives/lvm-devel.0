From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 24 Oct 2012 02:40:04 +0000 (UTC)
Subject: master - WHATS_NEW: Entry for commit e1917809477c4850cc1094121001d61a2b70ef26
Message-ID: <20121024024004.75949A0D90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b873fc54baf12891158017cd732e01a7f19b3ac3
Commit:        b873fc54baf12891158017cd732e01a7f19b3ac3
Parent:        e1917809477c4850cc1094121001d61a2b70ef26
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Oct 23 21:38:37 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Oct 23 21:38:37 2012 -0500

WHATS_NEW:  Entry for commit e1917809477c4850cc1094121001d61a2b70ef26

WHATS_NEW commit for 'lvs' output change to add RAID 4/5/6 sync %age
to s/Copy%/Cpy%Sync/ output.
---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2c4e516..ffbf4ef 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Change lvs heading Copy% to Cpy%Sync and print RAID4/5/6 sync% there too.
   Fix clvmd support for option -d and properly use its argument.
   Support use of option --yes for lvchange --persistent.
   Fix memory leak on error path for pvcreate with invalid uuid.


