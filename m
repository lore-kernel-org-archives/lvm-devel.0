From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 14 Nov 2013 08:42:57 -0600
Subject: [PATCH 00/13] liblvm patch series for review
Message-ID: <1384440190-5759-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch contains a number of library updates for review.  Main points of
interest include:

* Name corrections for python bindings, so that the names actually match how
  you reference class name spaces in python.

* Add checks so if a user recycles the library handle
  any left over references to old libraries are caught.

* Re-factor vg reduce to have one code path, addresses:
  https://bugzilla.redhat.com/show_bug.cgi?id=989174

* Add ability to create PV with arguments to configure:
  - size
  - pvmetadatacopies
  - pvmetadatasize
  - data_alignment
  - data_alignment_offset
  - zero

* Update unit tests and _enable_ them.

* Add VG/LV name validation function ref. bug: 
  https://bugzilla.redhat.com/show_bug.cgi?id=883689

* Reset buffer after retrieving error message in library.

* Add LVM2APP_DEBUG env variable for debug messages to stderr.

* Remove the forward struct declaration.  This isn't needed for
  implementing opaque data pointers.


Tony Asleson (13):
  python-lvm: Correct names
  python-lvm: Robustness improvements.
  vgreduce: Move _vgreduce_single functionality
  metadata.c: Call refactored vgreduce_single
  python-lvm: Test case change for vg.reduce
  lvm2app: Add ability to create PV with args
  python-lvm: Add addl. PV create arguments
  python-lvm: Update and enable unit test case
  lvm2app: Add VG/LV name validation
  python-lvm: VG/LV name validation.
  lvm2app: Reset buffer after retrieving error message
  lvm2app: Add LVM2APP_DEBUG env variable for debug
  lvm2app: Remove forward declarations.

 lib/log/log.c                    |  18 +++
 lib/log/log.h                    |   2 +
 lib/log/lvm-logging.h            |   1 +
 lib/metadata/metadata-exported.h |   5 +
 lib/metadata/metadata.c          |  67 ++++----
 lib/metadata/vg.c                |  93 +++++++++++
 lib/misc/lvm-string.c            |  68 ++++++--
 lib/misc/lvm-string.h            |   1 +
 liblvm/lvm2app.h                 | 117 ++++++++++++--
 liblvm/lvm_base.c                |  24 ++-
 liblvm/lvm_lv.c                  |   8 +-
 liblvm/lvm_misc.c                |  10 ++
 liblvm/lvm_misc.h                |   9 +-
 liblvm/lvm_prop.c                |  31 ++++
 liblvm/lvm_prop.h                |  14 ++
 liblvm/lvm_prop_fields.h         |   7 +
 liblvm/lvm_pv.c                  | 136 ++++++++++++++--
 liblvm/lvm_vg.c                  |  25 ++-
 python/liblvm.c                  | 329 +++++++++++++++++++++++----------------
 test/api/pytest.sh               |   4 -
 test/api/python_lvm_unit.py      | 101 +++++++++++-
 tools/toollib.c                  |   6 -
 tools/vgreduce.c                 |  81 +---------
 23 files changed, 855 insertions(+), 302 deletions(-)

-- 
1.8.2.1


