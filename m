From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 9 Feb 2010 19:07:36 -0500 (EST)
Subject: a bug in snapshots
Message-ID: <Pine.LNX.4.64.1002091904560.14493@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

Try to make a snapshot that is so big that it spans more than one physical 
volume. Then, type "lvs" command. You get these errors:

[slunicko:/usr/src/LVM2.2.02.60]# lvs
  Number of segments in active LV lvol1 does not match metadata
  Number of segments in active LV lvol1 does not match metadata
  Number of segments in active LV lvol1 does not match metadata
  Number of segments in active LV lvol1 does not match metadata
  LV    VG   Attr   LSize  Origin Snap%  Move Log Copy%  Convert
  lvol0 vg1  owi-a- 16.00m
  lvol1 vg1  Swi-I- 60.00m lvol0  100.00
  m     vg1  -wi-a- 64.00m

This bug was introduced in LVM2.2.02.59 with this change:

--- ./LVM2.2.02.58/lib/activate/dev_manager.c   2010-01-13 
02:55:44.000000000 +0100
+++ ./LVM2.2.02.59/lib/activate/dev_manager.c   2010-01-15 
23:58:25.000000000 +0100
@@ -584,7 +593,7 @@ int dev_manager_snapshot_percent(struct
         * Try and get some info on this device.
         */
        log_debug("Getting device status percentage for %s", name);
-       if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
+       if (!(_percent(dm, name, dlid, "snapshot", 0, lv, percent,
                       percent_range, NULL)))
                return_0;


Mikulas


