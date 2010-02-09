From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  9 Feb 2010 17:32:03 -0500
Subject: [PATCH 00/21] Add infrastructure for metadata balancing.
Message-ID: <1265754744-17319-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patchset is a third round of the metadata balancing support,
and builds on the second round of patches already submitted.
It adds the infrastructure to set a bit inside the mda header on
a per-PV basis, control it from pvchange, display the number
of mdas with this bit set on a particular PV or VG, and adds
VG 'min' / 'max' parameters to control the per-PV bits.

Changes from the second round include:
1) Define the vg-level parameters which control metadata balancing:
  a) vg_mda_balance_max: a number indicating the maximum number of
     PVs to contain enabled metadata areas; range is 
     vg_mda_balance_min:# of PVs in VG
  b) vg_mda_balance_min: a number indicating the minimum number of
     PVs to contain enabled metadata areas; range 1:vg_mda_balance_max
2) Add metadata_balance_{min|max} to struct volume_group, and store
these parameters on disk in vg metadata.
3) Update vgchange to take metadatabalance{min|max} parameters.
4) Various small bugs fixed in the second round of patches.

Still TODO:
1) Implement the disable of mdas properly by disabling certain metadata_area_ops
functions.  I began this work, then ran into some lvmcache issues that need
to be resolved.  Code is isolated to one patch (not included in this set).
2) Implement the setting of the disable bit on various PVs when the
metadatabalance{min|max} parameters are given to vgchange.  Should be fairly
straightforward - setting a lower 'max' value might cause metadata disable
bits set on PVs, and setting a higher 'min' value may cause metadata disable
bits cleared on PVs.
3) Consider renaming the 'disable' to 'enable' as this is more consistent
with the 'min' and 'max' parameters


