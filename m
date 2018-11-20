From: David Teigland <teigland@sourceware.org>
Date: Tue, 20 Nov 2018 10:05:58 -0500
Subject: 2018-06-01-stable - WHATS_NEW: sync io
Message-ID: <201811201505.wAKF5wAn000306@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe1cabfa3469b5a5ac673385785b031d6a702bb4
Commit:        fe1cabfa3469b5a5ac673385785b031d6a702bb4
Parent:        cb5405ded86209979eef54433d0b90942b2f976a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 16 16:01:48 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 20 09:04:37 2018 -0600

WHATS_NEW: sync io

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 98b4c8f..b60612f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.183 - 
 ====================================
+  Use sync io if async io_setup fails, or use_aio=0 is set in config.
   Avoid opening devices to get block size by using existing open fd.
 
 Version 2.02.182 - 30th October 2018


