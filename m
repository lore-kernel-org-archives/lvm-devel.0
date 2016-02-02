From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Feb 2016 12:57:35 +0000 (UTC)
Subject: master - metadata: format: also delete bootloader areas from lvmcache when reading lvm1 and pool label
Message-ID: <20160202125735.66D9860E20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1498bc8cc442ebafea95e5dd8af69cdcd43619c2
Commit:        1498bc8cc442ebafea95e5dd8af69cdcd43619c2
Parent:        ec43f55445966b5075fa8083921d182a0a138326
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 2 13:54:19 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 2 13:57:19 2016 +0100

metadata: format: also delete bootloader areas from lvmcache when reading lvm1 and pool label

lvm1 and pool format do not support bootloader areas and we need to
remove any existing associated bootloader areas when we read lvm1 and
pool labels.

This has its importance if we're converting from one format to another
and we're reusing lvmcache in long-running commands (e.g. clvmd or lvm
shell) and we need to make lvmcache consistent and valid for current format.
---
 lib/format1/lvm1-label.c   |    1 +
 lib/format_pool/disk_rep.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 6f8ee54..b600bd7 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -81,6 +81,7 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 
 	lvmcache_set_device_size(info, ((uint64_t)xlate32(pvd->pv_size)) << SECTOR_SHIFT);
 	lvmcache_del_mdas(info);
+	lvmcache_del_bas(info);
 	lvmcache_make_valid(info);
 
 	return 1;
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index 75d5299..688c521 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -105,6 +105,7 @@ int read_pool_label(struct pool_list *pl, struct labeller *l,
 
 	lvmcache_set_device_size(info, ((uint64_t)xlate32_be(pd->pl_blocks)) << SECTOR_SHIFT);
 	lvmcache_del_mdas(info);
+	lvmcache_del_bas(info);
 	lvmcache_make_valid(info);
 
 	pl->dev = dev;


