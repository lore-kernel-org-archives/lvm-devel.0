From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 25 Apr 2014 19:57:27 +0000 (UTC)
Subject: master - WHATS_NEW: Add message for commit 9ac858f
Message-ID: <20140425195727.6BE106092B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=76687f4cacd6ca3f8953d4ee915efc159838cd91
Commit:        76687f4cacd6ca3f8953d4ee915efc159838cd91
Parent:        9ac858fe6b56318cee821e86e4a5edede75d5134
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Apr 25 14:55:32 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Apr 25 14:55:32 2014 -0500

WHATS_NEW: Add message for commit 9ac858f

WHATS_NEW for commit:
9ac858f vgsplit: Make vgsplit work on mirrors with leg and log on same PV
---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1615f37..af9f6c3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Make vgsplit work on mirrors with logs that share PVs with images.
   Use devices/ignore_suspended_devices=0 by default if not defined in lvm.conf.
   Use proper libmem mempool for allocation of unknown segment name.
   Add --readonly to reporting and display tools for lock-free metadata access.


