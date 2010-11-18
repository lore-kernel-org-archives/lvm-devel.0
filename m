From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 18 Nov 2010 22:32:14 +0100
Subject: [PATCH 00/11] Add interface to support adding and removing metadata areas on demand
Message-ID: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
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

(This patchset should be applicable to 4f2136c6545532afe149657f923fb982d2660415.
There's still one thing that is failing which I need to inspect - it's lvm1
format handling and failing t-pv-create-usage.sh: "PV segment pe_count mismatch: 33 != 32".
But anyway, here it is... I'll provide an update if I find anything.)

Peter Rajnoha (11):
  Add mda_slots field for PV info in the cache.
  Add pe_start_locked flag in struct physical_volume to retain
    pe_start.
  Add pv_add_metadata_area to format_handler interface.
  Add pv_remove_metadata_area to format_handler interface.
  Add pv_initialise to format_handler interface.
  Refactor pv_setup to not include the initialisation only code.
  Remove unused _mda_setup.
  Cleanup pv_write to use recent changes in metadata handling
    interface.
  Remove useless mdas parameter in code creating new PVs.
  Make existing lvmcache_update_pvid public.
  Use new metadata interface to provide better support for PV resize.

 lib/cache/lvmcache.c             |   18 +-
 lib/cache/lvmcache.h             |    3 +
 lib/format1/disk-rep.c           |    7 +
 lib/format1/disk-rep.h           |    1 +
 lib/format1/format1.c            |   64 ++-
 lib/format1/format1.h            |    1 +
 lib/format1/lvm1-label.c         |    5 +
 lib/format_pool/disk_rep.c       |    4 +
 lib/format_pool/disk_rep.h       |    1 +
 lib/format_pool/format_pool.c    |   22 +-
 lib/format_pool/format_pool.h    |    1 +
 lib/format_text/archiver.c       |    5 +-
 lib/format_text/format-text.c    |  912 ++++++++++++++++++++++----------------
 lib/format_text/format-text.h    |   11 +-
 lib/format_text/text_label.c     |   26 +-
 lib/metadata/metadata-exported.h |   12 +-
 lib/metadata/metadata.c          |   80 ++--
 lib/metadata/metadata.h          |   49 ++-
 lib/metadata/pv.h                |    1 +
 lib/metadata/pv_manip.c          |   70 +++-
 tools/pvchange.c                 |   10 +-
 tools/pvresize.c                 |   57 +---
 tools/vgconvert.c                |   12 +-
 tools/vgreduce.c                 |    2 +-
 24 files changed, 803 insertions(+), 571 deletions(-)

-- 
1.7.3.2


