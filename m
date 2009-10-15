From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 15 Oct 2009 15:19:08 -0500
Subject: [PATCH] Enable (already implemented?) snapshots of mirrors
Message-ID: <1255637948.16495.26.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I just wanted to get a feel for where things were at WRT snapshots of
mirrors.  Pulling out the prevention check (patch provided below),
things seem to work just fine.  Is there something I am missing?

[root at bp-01 LVM2]# lvs -a
  LV            VG         Attr   LSize   Origin Snap%  Move Log     Copy%  Convert
  LogVol00      VolGroup00 -wi-ao 139.09g
  LogVol01      VolGroup00 -wi-ao   9.81g
  lv            vg         mwi-a- 500.00m                    lv_mlog 100.00
  [lv_mimage_0] vg         iwi-ao 500.00m
  [lv_mimage_1] vg         iwi-ao 500.00m
  [lv_mlog]     vg         lwi-ao   4.00m
[root at bp-01 LVM2]# lvcreate -s vg/lv_mimage_0 -L 500M -n snap
  Snapshots of mirror images is not supported
[root at bp-01 LVM2]# lvcreate -s vg/lv_mlog -L 500M -n snap
  Snapshots of mirror logs is not supported
[root at bp-01 LVM2]# lvcreate -s vg/lv -L 500M -n snap
  Logical volume "snap" created
[root at bp-01 LVM2]# lvs
  LV       VG         Attr   LSize   Origin Snap%  Move Log     Copy%  Convert
  LogVol00 VolGroup00 -wi-ao 139.09g
  LogVol01 VolGroup00 -wi-ao   9.81g
  lv       vg         mwi-a- 500.00m                    lv_mlog   0.00
  snap     vg         swi-a- 500.00m lv       0.00
[root at bp-01 LVM2]# mkfs.ext3 /dev/vg/lv
mke2fs 1.39 (29-May-2006)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
128016 inodes, 512000 blocks
25600 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=67633152
63 block groups
8192 blocks per group, 8192 fragments per group
2032 inodes per group
Superblock backups stored on blocks:
        8193, 24577, 40961, 57345, 73729, 204801, 221185, 401409

Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: lvs
done

This filesystem will be automatically checked every 22 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.
[root at bp-01 LVM2]# lvs
  LV       VG         Attr   LSize   Origin Snap%  Move Log     Copy%  Convert
  LogVol00 VolGroup00 -wi-ao 139.09g
  LogVol01 VolGroup00 -wi-ao   9.81g
  lv       vg         mwi-a- 500.00m                    lv_mlog   0.00
  snap     vg         swi-a- 500.00m lv       4.89

 brassow

Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -2990,11 +2990,12 @@ int lv_create_single(struct volume_group
 					  "supported yet");
 				return 0;
 			}
-			if (org->status & MIRROR_IMAGE ||
-			    org->status & MIRROR_LOG ||
-			    org->status & MIRRORED) {
-				log_error("Snapshots and mirrors may not yet "
-					  "be mixed.");
+			if ((org->status & MIRROR_IMAGE) ||
+			    (org->status & MIRROR_LOG)) {
+				log_error("Snapshots of mirror %ss "
+					  "are not supported",
+					  (org->status & MIRROR_LOG) ?
+					  "log" : "image");
 				return 0;
 			}
 



