From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 23 Oct 2015 14:00:17 +0000 (UTC)
Subject: master - lvmcache: update cached info properly when moving from VG to orphan while lvmetad is used
Message-ID: <20151023140017.CDC58610F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a42c13ccf151c3afdeab362c8541b5d249fb01e
Commit:        3a42c13ccf151c3afdeab362c8541b5d249fb01e
Parent:        8b965bd3d5df808aef2012494602cc0cf73d7398
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 23 15:05:48 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 23 15:58:31 2015 +0200

lvmcache: update cached info properly when moving from VG to orphan while lvmetad is used

When lvmetad is used and lvmcache update function (lvmcache_update_vgname_and_id)
was called to update existing lvmcache records, a condition was met
which made to retun from the update function immediately, effectively
making it NOOP.

It seems there's no reason for such condition and lvmcache should be
update appropriately even when lvmetad used as lvmcache may be reused,
most notably in lvm shell.

It's possible this is a remnant of the lvmetad development code which
didn't get removed for some reason and the bug didn't get spotted
because lvm shell is not used often (the condition dates back to 2012
or so).

Example, lvmetad and lvm shell used:

lvm> pvs
  PV         VG   Fmt  Attr PSize   PFree
  /dev/sda   vg   lvm2 a--  124.00m 124.00m

Before this patch:
==================
lvm> vgremove vg
  Volume group "vg" successfully removed

lvm> pvs

With this patch applied:
========================

lvm> vgremove vg
  Volume group "vg" successfully removed

lvm> pvs
  PV         VG   Fmt  Attr PSize   PFree
  /dev/sda        lvm2 ---  128.00m 128.00m
---
 WHATS_NEW            |    1 +
 lib/cache/lvmcache.c |    4 ----
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6462e18..5911c64 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Fix lvmcache to move PV from VG to orphans if VG is removed and lvmetad used.
   Fix lvmcache to not cache even invalid info about PV which got removed.
   Support checking of memlock daemon counter.
   Allow all log levels to be used with the lvmetad -l option.
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 1bc4241..31f2aa9 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1542,10 +1542,6 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vg
 		vgid = vgname;
 	}
 
-	/* When using lvmetad, the PV could not have become orphaned. */
-	if (lvmetad_active() && is_orphan_vg(vgname) && info->vginfo)
-		return 1;
-
 	/* If PV without mdas is already in a real VG, don't make it orphan */
 	if (is_orphan_vg(vgname) && info->vginfo &&
 	    mdas_empty_or_ignored(&info->mdas) &&


