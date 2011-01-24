From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 24 Jan 2011 12:03:51 +0100
Subject: [PATCH 00/17] Add interface to support adding and removing metadata areas on demand (v2)
Message-ID: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset provides a possibility to add new metadata areas on demand
as well as removing them. Now, we can add a new metadata area independently
of the PV initialisation so if there's a place we can even add metadata area
additionally. The same applies for metadata removal functionality. This is
only internal interface for now, but we should be able to provide external
hooks in lvm2 commands if desired.

The patchset also tries to cleanup existing pv_setup/pv_write code. It also
uses the new interface to allow resizing a PV with more copies of metadata
areas on disk which was not allowed before because of missing metadata
handling part in the interface.

To support all these changes, a definition of format_instance for PVs is
now supported. This structure holds all the information we need.

This patchset should be applicable to 4dff097f6617ef746cd75250f74425825082a8ce.
The tests seems to be passing, just one is still failing - it's lvm2 format
handling: t-pv-create-usage.sh: "PV segment pe_count mismatch: 33 != 32".

Peter Rajnoha (17):
  Add pvid parameter to create_instance function.
  Add supporting functions for metadata areas stored in format
    instance.
  Add struct format_instance *fid field to struct physical_volume.
  Add format_instance support for pv_read.
  Add attach_existing_mdas parameter to create_instance fn.
  Remove useless mdas parameter from PV read functions.
  Add pv_add_metadata_area fn to support adding metadata areas on
    demand.
  Add pv_remove_metadata_area fn to support removing metadata areas on 
       demand.
  Add pv_initialise fn to format_handler interface.
  Add pe_start_locked parameter to pv_create fn.
  Refactor pv_setup to not include the PV initialisation code.
  Remove unused _mda_setup code.
  Cleanup pv_write code to use recent changes in metadata handling    
    interface.
  Use new metadata handling interface to provide better support for PV 
       resize.
  Change vg_convert code to actually work with recent changes in
    metadata     handling interface.
  Fix pvchange -u to work with recent changes in metadata handling    
    interface.
  Fix pvchange --metadataignore to work with recent changes in metadata
        handling interface.

 lib/cache/lvmcache.c             |    4 +-
 lib/format1/format1.c            |   38 +-
 lib/format_pool/format_pool.c    |   28 +-
 lib/format_text/archive.c        |    2 +-
 lib/format_text/archiver.c       |   15 +-
 lib/format_text/format-text.c    | 1027 ++++++++++++++++++++++----------------
 lib/format_text/format-text.h    |    8 +
 lib/metadata/metadata-exported.h |   23 +-
 lib/metadata/metadata.c          |  357 +++++++++++---
 lib/metadata/metadata.h          |   71 ++-
 lib/metadata/pv.c                |   20 +-
 lib/metadata/pv.h                |    2 +
 lib/metadata/pv_manip.c          |   70 ++-
 tools/pvchange.c                 |    5 +-
 tools/pvremove.c                 |   10 +-
 tools/pvresize.c                 |   57 +--
 tools/toollib.c                  |   14 +-
 tools/vgconvert.c                |   93 +---
 tools/vgreduce.c                 |    2 +-
 19 files changed, 1120 insertions(+), 726 deletions(-)

-- 
1.7.3.4


