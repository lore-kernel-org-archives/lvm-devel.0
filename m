From: David Teigland <teigland@sourceware.org>
Date: Wed, 22 May 2019 12:58:00 -0400
Subject: master - tests: pvscan-cache try to fix teardown problems
Message-ID: <201905221658.x4MGw00b010729@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2036608423117626eb1905b38e09c767983b2ef4
Commit:        2036608423117626eb1905b38e09c767983b2ef4
Parent:        78afe75b08c01e70d52e42b62acf0d6eab7874dc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 22 11:55:48 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 22 11:55:48 2019 -0500

tests: pvscan-cache try to fix teardown problems

teardown after the test was failing, probably because
of uncoordinated udev actions running on the test
system.  Try to avoid this by doing some work before
teardown.
---
 test/shell/pvscan-cache.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvscan-cache.sh b/test/shell/pvscan-cache.sh
index e0576f9..8788594 100644
--- a/test/shell/pvscan-cache.sh
+++ b/test/shell/pvscan-cache.sh
@@ -75,4 +75,7 @@ aux enable_dev "$dev2"
 pvscan --cache
 check pv_field "$dev1" vg_name "$vg1"
 
+vgchange -an $vg1
+lvremove $vg1/$lv1
+
 vgremove -ff $vg1


