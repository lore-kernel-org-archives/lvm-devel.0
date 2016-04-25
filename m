From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 25 Apr 2016 09:48:54 +0000 (UTC)
Subject: master - cleanup: do not mention segment in warning message if device not found for a PV when checking used/assumed devs for an LV
Message-ID: <20160425094854.E35B261072@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=379874a2d0ff51cdbfbc1cc723b41e06bcdfd277
Commit:        379874a2d0ff51cdbfbc1cc723b41e06bcdfd277
Parent:        9d976c0002f06e97c50bca7dad35d647848ed60f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Apr 25 11:41:36 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Apr 25 11:44:24 2016 +0200

cleanup: do not mention segment in warning message if device not found for a PV when checking used/assumed devs for an LV

[0] fedora/~ # pvs --config 'devices/filter=["a|/dev/sda|", "r|.*|"]'
  WARNING: Device for PV Qcxpcy-XgtP-UD3s-PmG0-qLyE-Z0ho-DYsxoz not found or rejected by a filter.
  WARNING: Device for PV Qcxpcy-XgtP-UD3s-PmG0-qLyE-Z0ho-DYsxoz not found or rejected by a filter.
  WARNING: Couldn't find device for segment belonging to fedora/root while checking used and assumed devices.
  WARNING: Couldn't find device for segment belonging to fedora/swap while checking used and assumed devices.
  PV         VG     Fmt  Attr PSize   PFree
  /dev/sda          lvm2 ---  128.00m 128.00m
  [unknown]  fedora lvm2 a-m   19.49g      0

Probably not worth mentioning "segments" here, just state that devices
for an LV can't be all found during the check - it's less mysterious for
user then:

[0] fedora/~ # pvs --config 'devices/filter=["a|/dev/sda|", "r|.*|"]'
  WARNING: Device for PV Qcxpcy-XgtP-UD3s-PmG0-qLyE-Z0ho-DYsxoz not found or rejected by a filter.
  WARNING: Device for PV Qcxpcy-XgtP-UD3s-PmG0-qLyE-Z0ho-DYsxoz not found or rejected by a filter.
  WARNING: Couldn't find all devices for LV fedora/root while checking used and assumed devices.
  WARNING: Couldn't find all devices for LV fedora/swap while checking used and assumed devices.
  PV         VG     Fmt  Attr PSize   PFree
  /dev/sda          lvm2 ---  128.00m 128.00m
  [unknown]  fedora lvm2 a-m   19.49g      0
---
 lib/metadata/metadata.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1ceed68..6d101e0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4631,8 +4631,8 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 			if (seg_type(seg, s) == AREA_PV) {
 				if (!(dev = seg_dev(seg, s))) {
 					if (!warned_about_no_dev) {
-						log_warn("WARNING: Couldn't find device for segment belonging "
-							 "to %s while checking used and assumed devices.",
+						log_warn("WARNING: Couldn't find all devices for LV %s "
+							 "while checking used and assumed devices.",
 							  display_lvname(lv));
 						warned_about_no_dev = 1;
 					}


