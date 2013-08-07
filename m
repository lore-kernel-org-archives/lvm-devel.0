From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  7 Aug 2013 22:51:53 +0000 (UTC)
Subject: master - WHATS_NEW: update WHATS_NEW for previous commit
Message-ID: <20130807225153.0B539611AC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68c2d352ec2746ab278856388c6203c604f6248a
Commit:        68c2d352ec2746ab278856388c6203c604f6248a
Parent:        c95f17ea64e3faee3d36be95544c907b5e89c073
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Aug 7 17:51:21 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Aug 7 17:51:21 2013 -0500

WHATS_NEW: update WHATS_NEW for previous commit

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4515be7..acab587 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Fix issue preventing PV creation on mirror LVs
   When converting mirrors, default segtype should be the same unless specified.
   Make "raid1" the default mirror segment type.
   Fix clogd descriptor leak when daemonizing.


