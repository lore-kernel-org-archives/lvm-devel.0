From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 29 Oct 2013 12:52:05 +0000 (UTC)
Subject: master - WHATS_NEW: commit 9d06212
Message-ID: <20131029125205.E01A961141@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db05a0cf6fde3be23ea1123a76477576923af8cc
Commit:        db05a0cf6fde3be23ea1123a76477576923af8cc
Parent:        f1a42aa8ec4c6d693b57832a8575ee68b9e71b12
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 29 13:49:55 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 29 13:49:55 2013 +0100

WHATS_NEW: commit 9d06212

Other changes in previous commits 9d06212 and f1a42aa are changes
in the code that was not yet released as part of upcoming v104.
---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 63f97da..b8c1f15 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104 -
 ===================================
+  Respect DM_UDEV_DISABLE_OTHER_RULES_FLAG in lvmetad udev rules.
   Fix clvmd message verification to not reject REMOTE flag. (2.02.100)
   Compare equality of double values with DBL_EPSILON predefined constant.
   Use additional gcc warning flags by default.


