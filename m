From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 29 Feb 2016 19:50:51 +0000 (UTC)
Subject: master - update WHATS_NEW
Message-ID: <20160229195051.E557D60F4A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b2d819eafac630cc683c5fdf02730a636dd9bff6
Commit:        b2d819eafac630cc683c5fdf02730a636dd9bff6
Parent:        e3b904fd08712cf71a2248f72dd2be5b42039282
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 29 13:50:02 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 29 13:50:02 2016 -0600

update WHATS_NEW

including changes not recorded for the previous release.
---
 WHATS_NEW |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 77b0a40..507e028 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,8 +1,12 @@
 Version 2.02.145 - 
 =====================================
+  Display [unknown] instead of blank for unknown VG names in pvs output.
 
 Version 2.02.144 - 26th February 2016
 =====================================
+  Use new PV processing code in pvcreate/vgcreate/vgextend/pvremove.
+  Add new PV processing code that prompts user without locks held.
+  Prevent lvmlockd blocking with new flag requiring sanlock 3.3.0.
   Only show (u)sed pv_attr char when PV is not (a)llocatable. (2.02.143)
   Update makefile to generate lcov output also for lvmpolld and lvmlockd.
   Fix SystemdService lvm2-lvmdbusd.service name.


