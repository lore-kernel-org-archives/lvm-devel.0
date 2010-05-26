From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 26 May 2010 10:02:02 -0400
Subject: [PATCH 00/18] Add infrastructure for metadata balancing, v4.
Message-ID: <1274882540-6181-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patchset is a fourth round of the metadata balancing support,
and builds on the third round of patches already submitted (2/9/2010).
It adds the infrastructure to set a bit inside the mda header on
a per-PV basis, control it from pvchange, display the number
of mdas with this bit set on a particular PV or VG, but skips
the VG-based parameters to control the per-PV bits.  The vg-based
parameters and control is best dealt with in another patchset.

Changes from the third round start around patch 9 and include:
1) Renamed 'disable' to 'ignore' everywhere, per the last review,
and incorporate review comments.
2) Separate 'metadata_area_ignored' list on the 'fid' structure.
This seemed to simplify and isolate the ignored code from existing
code and should be less risky than checking for a flag in the
vg_write() path.
3) MDA ignore/unignore now implemented.  If the bit is set on disk,
at _text_read() time we treat it as a PV with 0 mdas.  This means
that when we _vg_read() and construct the VG, we will adjust the
lvmcache and mda lists based on another PVs metadata.
4) Added various helper functions to refactor and simplify code.
These include fid_add_mda() and fid_add_mdas(), and
mdas_empty_or_ignored(), and a location specific mda copy
constructor.
5) Various bugs fixed from the third round of patches.

Still TODO:
1) Submit vg-based parameters and control.  For now we can control on
a per-PV basis and this should be adequate for the first release.


