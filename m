From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Mar 2013 14:30:29 +0000 (UTC)
Subject: master - vgextend: do not allow PV with 0 MDAs to be added while already in a VG
Message-ID: <20130319143029.3561E1472@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e5e2dd4ee684137485a86c00e8ff29e7f169e14
Commit:        7e5e2dd4ee684137485a86c00e8ff29e7f169e14
Parent:        59878d0129f63c3e8c1c4bc9715a400dc8fa808a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 19 14:13:44 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 19 14:57:36 2013 +0100

vgextend: do not allow PV with 0 MDAs to be added while already in a VG

If extending a VG and including a PV with 0 MDAs that was already
a part of a VG, the vgextend allowed that PV to be added and we
ended up *with one PV in two VGs*!

The vgextend code used the 'pv_by_path' fn that returned a PV for
a given path. However, when the PV did not have any metadata areas,
the fn just returned a PV without any reference to existing VG.
Consequently, any checks for the existing VG failed.

[0] raw/~ # pvcreate --metadatacopies 0 /dev/sda
  Physical volume "/dev/sda" successfully created

[0] raw/~ # pvcreate --metadatacopies 1 /dev/sdb
  Physical volume "/dev/sdb" successfully created

[0] raw/~ # vgcreate vg1 /dev/sda /dev/sdb
  Volume group "vg1" successfully created

[0] raw/~ # pvcreate --metadatacopies 1 /dev/sdc
  Physical volume "/dev/sdc" successfully created

[0] raw/~ # vgcreate vg2 /dev/sdc
  Volume group "vg2" successfully created

Before this patch (incorrect):
[0] raw/~ # vgextend vg2 /dev/sda
  Volume group "vg2" successfully extended

With this patch (correct):
[0] raw/~ # vgextend vg2 /dev/sda
  Physical volume '/dev/sda' is already in volume group 'vg1'
  Unable to add physical volume '/dev/sda' to volume group 'vg2'.
---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index fdf47db..775e40d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -629,7 +629,7 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 {
 	struct physical_volume *pv;
 
-	if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_name)))
+	if (!(pv = find_pv_by_name(vg->cmd, pv_name, 1)))
 		stack;
 	if (!pv && !pp) {
 		log_error("%s not identified as an existing "


