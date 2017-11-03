From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 3 Nov 2017 00:43:23 -0400
Subject: master - pre-release
Message-ID: <201711030443.vA34hN4K005195@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=29300e72eebe974d90ebd2b55925bd728f81a326
Commit:        29300e72eebe974d90ebd2b55925bd728f81a326
Parent:        4129cf5090cd329dceee03df127d6d3644bbaa66
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Nov 3 02:28:55 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Nov 3 02:28:55 2017 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    6 +++---
 WHATS_NEW_DM |    4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index e6f3580..933eaeb 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.176(2)-git (2017-10-06)
+2.02.176(2)-git (2017-11-03)
diff --git a/VERSION_DM b/VERSION_DM
index cb4da47..bddf7fb 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.145-git (2017-10-06)
+1.02.145-git (2017-11-03)
diff --git a/WHATS_NEW b/WHATS_NEW
index ac4053a..3f71bdd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,7 @@
-Version 2.02.176 -
-===================================
+Version 2.02.176 - 3rd November 2017
+====================================
   Keep Install section only in lvm2-{lvmetad,lvmpolld}.socket systemd unit.
-  liblvm: Fix segfault in lvm_pv_remove. (2.02.173)
+  Fix segfault in lvm_pv_remove in liblvm. (2.02.173)
   Do not allow storing VG metadata with LV without any segment.
   Fix printed message when thin snapshot was already merged.
   Remove created spare LV when creation of thin-pool failed.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 12cd7f8..bcb3229 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.145 - 
-===================================
+Version 1.02.145 - 3rd November 2017
+====================================
   Keep Install section only in dm-event.socket systemd unit.
   Issue a specific error with dmsetup status if device is unknown.
   Fix RT_LIBS reference in generated libdevmapper.pc for pkg-config


