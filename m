From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:47:00 +0000 (UTC)
Subject: master - WHATS_NEW: reports and invisible devices
Message-ID: <20160113134700.059CD607C6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2d5c5e6c995b34ba36c026c8da7cdd316b69ee5
Commit:        d2d5c5e6c995b34ba36c026c8da7cdd316b69ee5
Parent:        efab21b4115d1cc79c3b02c64cd15f360176c3cb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 13 14:45:49 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 14:45:49 2016 +0100

WHATS_NEW: reports and invisible devices

---
 WHATS_NEW |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 93e0dd5..fb485b3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,8 @@
 Version 2.02.140 -
 ===================================
+  Add report/mark_invisible_devices to lvm.conf.
+  Use brackets consistently in report fields to mark invisible devices.
   Restore background polling processing during auto-activation (2.02.119).
-  Use brackets to signify LVs which are not visible when reporting lv_parent.
   Fix invalid memory read when reporting cache LV policy_name (2.02.126).
 
 Version 2.02.139 - 8th January 2016


