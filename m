From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:09:01 +0000 (UTC)
Subject: master - WHATS_NEW: PV_EXT_USED flag and related
Message-ID: <20160215120901.96EA560D80@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=698e0eb851b280796e3fbe17fbe9a9158b6344c7
Commit:        698e0eb851b280796e3fbe17fbe9a9158b6344c7
Parent:        8ad93874d63d67ea375b37b7014d782476dab88d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 15 13:07:35 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 13:07:35 2016 +0100

WHATS_NEW: PV_EXT_USED flag and related

---
 WHATS_NEW |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c7ffcf7..47eb735 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,10 @@
 Version 2.02.143 - 
 =====================================
+  Automatically change PV header extension to latest version if writing PV/VG.
+  Identify used PVs in pv_attr field by new 'u' character.
+  Add pv_in_use reporting field to report if PV is used or not.
+  Add pv_ext_vsn reporting field to report PV header extension version.
+  Add protective flag marking PVs as used even if no metadata available.
 
 Version 2.02.142 - 15th February 2016
 =====================================


