From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 22 Apr 2015 15:32:06 +0000 (UTC)
Subject: master - man: Escape single quotes in an example to avoid groff's unicode conversion.
Message-ID: <20150422153206.E1362603B4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=92607ecfe62c2590c7816d53c709d3b96faa2357
Commit:        92607ecfe62c2590c7816d53c709d3b96faa2357
Parent:        33429ea0833c958f2f548c231b301243e06e81bd
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 22 17:27:43 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Apr 22 17:31:11 2015 +0200

man: Escape single quotes in an example to avoid groff's unicode conversion.

---
 man/lvmcache.7.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index c77633a..493d6a9 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -274,7 +274,7 @@ can be changed using commands like these:
 
 .nf
 # lvchange \-\-cachepolicy mq vg/lv1
-# lvchange \-\-cachesettings 'migration_threshold=2048 random_threshold=4' \\
+# lvchange \-\-cachesettings \(aqmigration_threshold=2048 random_threshold=4\(aq \\
      vg/lv1
 .fi
 


