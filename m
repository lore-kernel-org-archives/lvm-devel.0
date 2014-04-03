From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu,  3 Apr 2014 21:58:37 +0000 (UTC)
Subject: master - RAID: Improve an error message
Message-ID: <20140403215837.E8C3660FC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c6468f91d9b7a93a85726dfb1b397b555502c1c
Commit:        6c6468f91d9b7a93a85726dfb1b397b555502c1c
Parent:        f242c0611d142c9e79328d4e927c0c55d08564d1
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Apr 3 16:57:41 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Apr 3 16:57:41 2014 -0500

RAID: Improve an error message

When down-converting a RAID1 LV, if the user specifies too few devices,
they will get a confusing message.
Ex:
[root]# lvcreate -m 2 --type raid1 -n raid -L 500M taft
  Logical volume "raid" created

[root]# lvconvert -m 0 taft/raid /dev/sdd1
  Unable to extract enough images to satisfy request
  Failed to extract images from taft/raid

This patch makes the error message a bit clearer by telling the user
the count they are trying to remove and the number of devices they
supplied.

[root at bp-01 lvm2]# lvcreate --type raid1 -m 3 -L 200M -n lv vg
  Logical volume "lv" created

[root at bp-01 lvm2]# lvconvert -m -3 vg/lv /dev/sdb1
  Unable to remove 3 images:  Only 1 device given.
  Failed to extract images from vg/lv

[root at bp-01 lvm2]# lvconvert -m -3 vg/lv /dev/sd[bc]1
  Unable to remove 3 images:  Only 2 devices given.
  Failed to extract images from vg/lv

[root at bp-01 lvm2]# lvconvert -m -3 vg/lv /dev/sd[bcd]1
[root at bp-01 lvm2]# lvs -a -o name,attr,devices vg
  LV   Attr       Devices
  lv   -wi-a----- /dev/sde1(1)

This patch doesn't work in all cases.  The user can specify the right
number of devices, but not a sufficient amount of devices from the LV.
This will produce the old error message:
[root at bp-01 lvm2]# lvconvert -m -3 vg/lv /dev/sd[bcf]1
  Unable to extract enough images to satisfy request
  Failed to extract images from vg/lv
However, I think this error message is sufficient for this case.
---
 lib/metadata/raid_manip.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d1759ae..f1cb012 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -840,6 +840,12 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 	log_verbose("Extracting %u %s from %s/%s", extract,
 		    (extract > 1) ? "images" : "image",
 		    lv->vg->name, lv->name);
+	if (dm_list_size(target_pvs) < extract) {
+		log_error("Unable to remove %d images:  Only %d device%s given.",
+			  extract, dm_list_size(target_pvs),
+			  (dm_list_size(target_pvs) == 1) ? "" : "s");
+		return 0;
+	}
 
 	lvl_array = dm_pool_alloc(lv->vg->vgmem,
 				  sizeof(*lvl_array) * extract * 2);


