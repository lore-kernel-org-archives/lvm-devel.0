From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 15 Apr 2016 17:35:44 +0000 (UTC)
Subject: master - tests: fix check_lvmlockd_test
Message-ID: <20160415173544.BB21661033@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=662090e3587d248f1c53bd8dc2989ba0b1960085
Commit:        662090e3587d248f1c53bd8dc2989ba0b1960085
Parent:        6954de22e2281876506c0db1c98972242de977fb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 15 12:35:20 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 15 12:35:20 2016 -0500

tests: fix check_lvmlockd_test

---
 test/lib/flavour-udev-lvmlockd-test.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/flavour-udev-lvmlockd-test.sh b/test/lib/flavour-udev-lvmlockd-test.sh
index 17ef516..d2a7b4a 100644
--- a/test/lib/flavour-udev-lvmlockd-test.sh
+++ b/test/lib/flavour-udev-lvmlockd-test.sh
@@ -6,4 +6,4 @@ export LVM_TEST_LVMLOCKD_TEST=1
 export LVM_TEST_DEVDIR=/dev
 
 # FIXME:dct: add option to allow --test with sanlock
-LVM_TEST_LVMLOCKD_TEST_DLM=1
+export LVM_TEST_LVMLOCKD_TEST_DLM=1


