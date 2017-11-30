From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 30 Nov 2017 07:31:05 -0500
Subject: master - Update WHATS_NEW
Message-ID: <201711301231.vAUCV5HN030734@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94d3878efb7cec344681bf4a2b28774ffebda3ba
Commit:        94d3878efb7cec344681bf4a2b28774ffebda3ba
Parent:        b8caca46527cd5e858b0218734ba9a1f24200d6e
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Nov 30 13:30:28 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Nov 30 13:30:28 2017 +0100

Update WHATS_NEW

---
 WHATS_NEW |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4ff8dcb..32ed3c9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -8,7 +8,13 @@ Version 2.02.177 -
   Make a pvmove LV locking holder.
   Do not change critical section counter on resume path without real resume.
   Enhance activation code to automatically suspend pvmove participants.
+  Prevent conversion of thin volumes to snapshot origin when lvmlockd is used.
+  Correct the steps to change lock type in lvmlockd man page.
+  Retry lock acquisition on recognized sanlock errors.
+  Fix lock manager error codes in lvmlockd.
   Remove unnecessary single read from lvmdiskscan.
+  Check raid reshape flags in vg_validate().
+  Add support for pvmove of cache and snapshot origins.
   Avoid using precommitted metadata for suspending pvmove tree.
   Ehnance pvmove locking.
   Deactivate activated LVs on error path when pvmove activation fails.


