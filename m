From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 11 Oct 2007 18:30:58 -0400
Subject: [RFC LVM2] (0/6) Stacking LVs
Message-ID: <470EA422.6000003@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I'm working on to extend LVM2 to allow an LV with both striped
and mirrored. (e.g. RAID10, RAID0+1)

I think the current direction toward such combination is
stacking LVs internally.
Attached patches allow such stacking by letting lvcreate/lvconvert
to take tagged LVs as source of the extent allocation.
So you can make striped LV on mirrored LVs, mirrored LV on striped LVs,
mirrored mirror log, etc.

The patches are still rough-edge.
I would like to hear comments if this approach is acceptable or not.
Especially, I'm curious about:
  - How much flexibility should the LVM2 allow for stacking?
    Current patch allows basically any combination of
    linear/striped/mirror.
  - Do we explicitly mark the LVs which can be used for stacking?
    Current version implicitly uses LVs if they are specified by
    tag in lvcreate/lvconvert/lvextend command line.
    However, I wonder explicit marking (e.g. lvchange --allocatable y)
    might be safer and allows cleaner implementation.
  - Should we introduce a new structure about free space management?
    Current version uses 'struct physical_volume' as such structure.

The patch set contains 6 patches:
  1) Adding 'const' to the accessor functions of struct physical volume
  2) Adding 'pv_dev_name()' to access the device name of PV
  3) Splitting the allocation/initialization part from _pv_create
  4) Modifying struct lv_segment_area so that AREA_LV segment can
     have a pointer to pv_segment
  5) Allowing striped-LV segment merging
  6) Allowing allocation from tagged LVs

>From 1) to 3) are cosmetic changes.
4) changes the layout of struct lv_segment_area and accessor macros.
5) becomes necessary if we have striped LV over mirrorred LVs
and extend the striped LV.
These are preparation patches and should not affect the current LVM2
functionality.

6) is the core part of the feature.
Attaching struct physical_volume to struct logical_volume when
the LV is used as an allocation source for other LV.

The other things we need may:
  - enhancements to the allocation logic
  - snapshot
      * Currently, snapshot implementation is in strange state.
          o If you do 'lvcreate -s -n lv1 lv0',
            in on-disk metadata, 'lv0' is the origin and
            'lv1' is the cow area. 'snapshotX' is the snapshot.
            While in device-mapper, 'lv1' is the snapshot
            and 'lv1-cow' is the cow.
          o If you resize 'lv1', it resizes the cow area.
            If you change 'lv1' to read-only, it changes the snapshot
            read-only.
        So, what if we would like to add mirror to the snapshot,
        for example?

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


