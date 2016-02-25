From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 25 Feb 2016 16:51:52 +0000 (UTC)
Subject: master - tests: add dmstats create tests
Message-ID: <20160225165152.5785060204@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d3b132d9ac845e31c316ad4b908466bb3837a4d
Commit:        3d3b132d9ac845e31c316ad4b908466bb3837a4d
Parent:        11fd7b7c645c0462cac95687c098019cf779cd58
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Dec 11 17:16:23 2015 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Feb 25 16:40:59 2016 +0000

tests: add dmstats create tests

Add tests for the "dmstats create" command:

  * simple whole-device region
  * region using --start/--len options
  * region using --segments option
  * region with precise timestamps (--precise)
  * region with histogram bounds (--bounds)
---
 test/shell/dmstats-create.sh |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/test/shell/dmstats-create.sh b/test/shell/dmstats-create.sh
index cb1671a..d5db79f 100644
--- a/test/shell/dmstats-create.sh
+++ b/test/shell/dmstats-create.sh
@@ -15,6 +15,13 @@
 aux driver_at_least 4 33 || skip
 
 # ensure we can create devices (uses dmsetup, etc)
-#aux prepare_devs 5
+aux prepare_devs 1
+
+# basic dmstats create commands
+
+dmstats create "$dev1"
+dmstats create --start 0 --len 1 "$dev1"
+dmstats create --segments "$dev1"
+dmstats create --precise "$dev1"
+dmstats create --bounds 10ms,20ms,30ms "$dev1"
 
-# FIXME: some actual tests here.


