From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 23 Oct 2015 14:00:15 +0000 (UTC)
Subject: master - pvremove: make sure even invalid info is removed from lvmcache on pvremove
Message-ID: <20151023140015.B507C610F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b965bd3d5df808aef2012494602cc0cf73d7398
Commit:        8b965bd3d5df808aef2012494602cc0cf73d7398
Parent:        1a7bea0f0f187a3d3332dda2cca2ecd0300b8031
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 23 14:11:16 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 23 15:48:06 2015 +0200

pvremove: make sure even invalid info is removed from lvmcache on pvremove

The lvmcache info might be resued, most notably in lvm shell.
We need to be sure that even lvmcache_info marked as invalid
is removed from the lvmcache so it does not confuse any subsequent
code/commands executed later on.

Problematic example with the lvm shell:

lvm> pvs
  PV         VG   Fmt  Attr PSize   PFree
  /dev/sda        lvm2 ---  128.00m 128.00m

Before this patch (/dev/sda still displayed in a way):
======================================================

lvm> pvremove /dev/sda
  Labels on physical volume "/dev/sda" successfully wiped

(without lvmetad)
lvm> pvs
  No physical volume label read from /dev/sda

(with lvmetad)
lvm> pvs
  PV         VG   Fmt  Attr PSize   PFree
  /dev/sda        lvm2 ---  128.00m 128.00m

With this patch applied:
========================

lvm> pvremove /dev/sda
  Labels on physical volume "/dev/sda" successfully wiped

(without lvmetad)
lvm> pvs

(with lvmetad)
lvm> pvs
---
 WHATS_NEW               |    1 +
 lib/metadata/pv_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8ffbeca..6462e18 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Fix lvmcache to not cache even invalid info about PV which got removed.
   Support checking of memlock daemon counter.
   Allow all log levels to be used with the lvmetad -l option.
   Add optional shutdown when idle support for lvmetad.
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index ce7f661..e48fe42 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -781,7 +781,7 @@ int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		goto out;
 	}
 
-	info = lvmcache_info_from_pvid(dev->pvid, 1);
+	info = lvmcache_info_from_pvid(dev->pvid, 0);
 
 	if (!dev_test_excl(dev)) {
 		/* FIXME Detect whether device-mapper is still using the device */


