From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  6 Aug 2013 12:00:15 +0000 (UTC)
Subject: master - lvmetad: fix mda offset/size overflow if >= 4g (32bit)
Message-ID: <20130806120015.8AF1260314@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=34d207d9b37edc2499dfff2c4809fecf72926416
Commit:        34d207d9b37edc2499dfff2c4809fecf72926416
Parent:        41e64b72ab50153494fd2925fbb760331014fd70
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 6 13:37:42 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 6 13:37:42 2013 +0200

lvmetad: fix mda offset/size overflow if >= 4g (32bit)

When reading an info about MDAs from lvmetad, we need to use 64 bit
int to read the value of the offset/size, otherwise the value is
overflows and then it's used throughout!

This is dangerous if we're trying to write such metadata area then,
mostly visible if we're using 2 mdas where the 2nd one is at the end
of the underlying device and hence the value of the mda offset is
high enough to cause problems:

(the offset trimmed to value of 0 instead of 4096m, so we write
at the very start of the disk (or elsewhere if the offset has
some other value!)

[1] raw/~ # lvcreate -s -l 100%FREE vg --virtualsize 4097m
  Logical volume "lvol0" created

[1] raw/~ # pvcreate --metadatacopies 2 /dev/vg/lvol0
  Physical volume "/dev/vg/lvol0" successfully created

[1] raw/~ # hexdump -n 512 /dev/vg/lvol0
0000000 0000 0000 0000 0000 0000 0000 0000 0000
*
0000200

[1] raw/~ # pvchange -u /dev/vg/lvol0
  Physical volume "/dev/vg/lvol0" changed
  1 physical volume changed / 0 physical volumes not changed

[1] raw/~ # hexdump -n 512 /dev/vg/lvol0
0000000 d43e d2a5 4c20 4d56 2032 5b78 4135 7225
0000010 4e30 3e2a 0001 0000 0000 0000 0000 0000
0000020 0000 0010 0000 0000 0000 0000 0000 0000
0000030 0000 0000 0000 0000 0000 0000 0000 0000
*
0000200

=======

(the offset overflows to undefined values which is far behind
the end of the disk)

[1] raw/~ # lvcreate -s -l 100%FREE vg --virtualsize 100g
  Logical volume "lvol0" created

[1] raw/~ # pvcreate --metadatacopies 2 /dev/vg/lvol0
  Physical volume "/dev/vg/lvol0" successfully created

[1] raw/~ # pvchange -u /dev/vg/lvol0
  /dev/vg/lvol0: lseek 18446744073708503040 failed: Invalid argument
  /dev/vg/lvol0: lseek 18446744073708503040 failed: Invalid argument
  Failed to store physical volume "/dev/vg/lvol0"
  0 physical volumes changed / 1 physical volume not changed
---
 lib/format_text/format-text.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index b210603..950e0d5 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1688,12 +1688,12 @@ static int _mda_import_text_raw(struct lvmcache_info *info, const struct dm_conf
 
 	cn = cn->child;
 	device = lvmcache_device(info);
-	size = dm_config_find_int(cn, "size", 0);
+	size = dm_config_find_int64(cn, "size", 0);
 
 	if (!device || !size)
 		return 0;
 
-	offset = dm_config_find_int(cn, "start", 0);
+	offset = dm_config_find_int64(cn, "start", 0);
 	ignore = dm_config_find_int(cn, "ignore", 0);
 
 	lvmcache_add_mda(info, device, offset, size, ignore);


