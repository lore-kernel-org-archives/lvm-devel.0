From: David Teigland <teigland@sourceware.org>
Date: Wed, 12 Apr 2017 14:52:42 -0400
Subject: master - WHATS_NEW: add items since last release
Message-ID: <201704121852.v3CIqggx006495@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b121a1f6ff5dafc860f60d351284bd917e6042f
Commit:        4b121a1f6ff5dafc860f60d351284bd917e6042f
Parent:        61cfe2d55b145e16f841cc1e23a3939b7fd91d6d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 12 13:45:37 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 12 13:45:37 2017 -0500

WHATS_NEW: add items since last release

---
 WHATS_NEW |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 85636e8..a597c42 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,14 @@
 Version 2.02.170 - 
 ==================================
+  Add lvconvert pool creation rule disallowing options with poolmetadata.
+  Fix lvconvert when the same LV is incorrectly reused in options.
+  Fix lvconvert VG name validation in option values.
+  Fix missing lvmlockd LV locks in lvchange and lvconvert.
+  Fix dmeventd setup for lvchange --poll.
+  Fix use of --poll and --monitor with lvchange and vgchange.
+  Disallow lvconvert of hidden LV to a pool.
+  Ignore --partial option when not used for activation.
+  Allow --activationmode option with lvchange --refresh.
   Better message on lvconvert --regionsize
   Allow valid lvconvert --regionsize change
   Add raid10 alias raid10_near


