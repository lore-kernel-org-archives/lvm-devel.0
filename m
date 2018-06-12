From: David Teigland <teigland@sourceware.org>
Date: Tue, 12 Jun 2018 13:46:02 -0400
Subject: master - tests: lvmetad-pvscan-cache expect command to fail
Message-ID: <201806121746.w5CHk2Kl014423@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=885e57cb2723b8f58e8bced534b81d536a1a16a4
Commit:        885e57cb2723b8f58e8bced534b81d536a1a16a4
Parent:        7824bb710d376804a7b821730aaa8ff1a65cae21
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 12 12:44:23 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 12 12:44:23 2018 -0500

tests: lvmetad-pvscan-cache expect command to fail

---
 test/shell/lvmetad-pvscan-cache.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
index e57030d..367220e 100644
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -37,8 +37,8 @@ check lv_field $vg1/$lv1 lv_active ""
 
 # Check that an LV cannot be activated by pvscan while VG is exported
 vgexport $vg1
-pvscan --cache -aay "$dev1"
-pvscan --cache -aay "$dev2"
+not pvscan --cache -aay "$dev1"
+not pvscan --cache -aay "$dev2"
 vgimport $vg1
 check lv_exists $vg1
 check lv_field $vg1/$lv1 lv_active ""


