From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 29 Jul 2015 08:22:48 +0000 (UTC)
Subject: master - cache: fix regression causing some PVs to bypass filters
Message-ID: <20150729082248.CBA0A601F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf700151eba483aeedbf790fd66ce1c44e19c707
Commit:        cf700151eba483aeedbf790fd66ce1c44e19c707
Parent:        af1c7bf0c71f9cc132e9cf211eb1512078af0081
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 29 09:43:03 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 29 10:19:12 2015 +0200

cache: fix regression causing some PVs to bypass filters

This is a regression introduced by commit
6c0e44d5a2e82aa160d48e83992e7ca342bc4bdf which changed
the way dev_cache_get fn works - before this patch, when a
device was not found, it fired a full rescan to correct the
cache. However, the change coming with that commit missed
this full_rescan call, causing the lvmcache to still contain
info about PVs which should be filtered now.

Such situation may have happened by coincidence of using
old persistent cache (/etc/lvm/cache/.cache) which does not
reflect the actual state anymore, a device name/symlink which
now points to a device which should be filtered and a fact we
keep info about usable DM devices in .cache no matter what
the filter setting is.

This bug could be hidden though by changes introduced in
commit f1a000a477558e157532d5f2cd2f9c9139d4f87c as it
calls full_rescan earlier before this problem is hit.
But we need to fix this anyway for the dev_cache_get
to be correct if we happen to use the same code path
again somewhere sometime.

For example, simple reproducer was (before commit
1a000a477558e157532d5f2cd2f9c9139d4f87c):

- /dev/sda contains a PV header with UUID y5PzRD-RBAv-7sBx-V3SP-vDmy-DeSq-GUh65M

- lvm.conf: filter = [ "r|.*|" ]

- rm -f .cache (to start with clean state)

- dmsetup create test --table "0 8388608 linear /dev/sda 0" (8388608 is
  just the size of the /dev/sda device I use in the reproducer)

- pvs (this will create .cache file which contains
  "/dev/disk/by-id/lvm-pv-uuid-y5PzRD-RBAv-7sBx-V3SP-vDmy-DeSq-GUh65M"
  as well as "/dev/mapper/test" and the target node "/dev/dm-1" - all the
  usable DM mappings (and their symlinks) get into the .cache file even
  though the filter "is set to "ignore all" - we do this - so far it's OK)

- dmsetup remove test (so we end up with /dev/disk/by-id/lvm-pv-uuid-...
  pointing to the /dev/sda now since it's the underlying device
  containing the actual PV header)

- now calling "pvs" with such .cache file and we get:
$ pvs
  PV                                                                 VG  Fmt  Attr PSize PFree
  /dev/disk/by-id/lvm-pv-uuid-y5PzRD-RBAv-7sBx-V3SP-vDmy-DeSq-GUh65M vg  lvm2 a--  4.00g    0

Even though we have set filter = [ "r|.*|" ] in the lvm.conf file!
---
 WHATS_NEW              |    1 +
 lib/device/dev-cache.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index df2a730..436d1d9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.127 - 
 =================================
+  Fix regression in cache causing some PVs to bypass filters (2.02.105).
 
 Version 2.02.126 - 24th July 2015
 =================================
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d854e2b..e58ac0f 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -945,7 +945,7 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f)
 		if (d)
 			dm_hash_remove(_cache.names, name);
 		log_sys_very_verbose("stat", name);
-		return NULL;
+		d = NULL;
 	}
 
 	if (d && (buf.st_rdev != d->dev)) {


