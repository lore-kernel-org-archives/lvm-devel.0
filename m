From: David Teigland <teigland@sourceware.org>
Date: Tue, 18 Apr 2017 13:58:43 -0400
Subject: master - WHATS_NEW: configure option enable-lvmlockd
Message-ID: <201704181758.v3IHwh42001621@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2d9097e9ca2c07cff1870349bd15e30e151e709e
Commit:        2d9097e9ca2c07cff1870349bd15e30e151e709e
Parent:        a5256d1353ef60a3f29a7af1a9d1389bc7d64104
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 18 12:58:18 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 18 12:58:18 2017 -0500

WHATS_NEW: configure option enable-lvmlockd

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e59024b..39ad2af 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.171 - 
 ==================================
+  Change configure option names from enable-lockd to enable-lvmlockd.
   lvcreate - raise mirror/raid default regionsize to 2MiB
   Add missing configurable prefix to configuration file installation directory.
 


