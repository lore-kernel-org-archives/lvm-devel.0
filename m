From: David Teigland <teigland@sourceware.org>
Date: Thu, 13 Jun 2019 18:44:51 -0400
Subject: master - WHATS_NEW for recent changes
Message-ID: <201906132244.x5DMipLi008677@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a4dbbefaff74b6507c82dc1b938b0312c2dda576
Commit:        a4dbbefaff74b6507c82dc1b938b0312c2dda576
Parent:        208a09745db480d77120d0cd83743732fc216918
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 13 17:44:14 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 13 17:44:14 2019 -0500

WHATS_NEW for recent changes

---
 WHATS_NEW |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 81cfdd3..60e5128 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,12 @@
 Version 2.03.05 - 
 ================================
+  Fix command definition for pvchange -a.
+  Add vgck --updatemetadata command that will repair metadata problems.
+  Improve VG reading to work if one good copy of metadata is found.
+  Report/display/scan commands that read VGs will no longer write/repair.
+  Move metadata repairs from VG reading to VG writing.
+  Add config setting md_component_checks to control MD component checks.
+  Add end of device MD component checks when dev has no udev info.
 
 Version 2.03.04 - 10th June 2019
 ================================


