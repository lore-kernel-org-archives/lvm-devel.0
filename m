From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 16 Aug 2011 09:11:35 -0500
Subject: [PATCH 0 of 5] LVM RAID: feature additions
Message-ID: <1313503895.11617.10.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The forthcoming 5 patches include enhancements to the LVM handling of
RAID1.  (RAID1 is a new segment type for LVM that is different from the
existing "mirror" segment type.  It utilizes the MD RAID1 personality.)
Enhancements include:
- splitmirrors: Can split off an image from a mirror to form an
independent LV.  (Can only split off a linear volume right now.)
- trackchanges: Can split off an image with 'trackchanges' that allows
for a read-only copy to be split off that can be reintegrated later -
resync'ing only those areas that have changed
- merge: Can merge back an LV that was split with the 'trackchanges'
option.
- up-convert: Can add RAID1 images to an existing RAID1 array.  (Does
not yet allow linear -> RAID1 conversion.)

This patch set also includes some code clean-up to better obey the
implicit LVM rules surrounding suspend/resume and activate/deactivate.

 brassow



