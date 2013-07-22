From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 22 Jul 2013 13:57:26 +0000 (UTC)
Subject: master - tests: comment about pvscan --cache return value
Message-ID: <20130722135726.6811960ECB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ca81a091c5a79bee0ec46c21aea643907ab2ca7
Commit:        6ca81a091c5a79bee0ec46c21aea643907ab2ca7
Parent:        081308af30b32b86b690c727125f0615e5a7a7fb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 22 15:57:18 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 22 15:57:18 2013 +0200

tests: comment about pvscan --cache return value

---
 test/shell/lvmetad-pvscan-filter.sh |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-filter.sh b/test/shell/lvmetad-pvscan-filter.sh
index 5dd66c4..5aed532 100644
--- a/test/shell/lvmetad-pvscan-filter.sh
+++ b/test/shell/lvmetad-pvscan-filter.sh
@@ -20,7 +20,12 @@ min=$(($(stat --printf=0x%T "$dev2")))
 
 aux hide_dev $dev2
 not pvscan --cache $dev2 2>&1 | grep "not found"
-# pvscan with --major/--minor does not fail (for udev's sake?)
+# pvscan with --major/--minor does not fail: lvmetad needs to
+# be notified about device removal on REMOVE uevent, hence
+# this should not fail so udev does not grab a "failed" state
+# incorrectly. We notify device addition and removal with
+# exactly the same command "pvscan --cache" - in case of removal,
+# this is detected by nonexistence of the device itself.
 pvscan --cache --major $maj --minor $min 2>&1 | grep "not found"
 aux unhide_dev $dev2
 


