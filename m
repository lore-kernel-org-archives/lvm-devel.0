From: Tony Asleson <tasleson@redhat.com>
Date: Wed,  8 May 2013 17:45:22 -0500
Subject: [PATCH 00/19] Looking for reviews
Message-ID: <1368053141-13836-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Many of these patches have been around for a while.
Looking for comments.  If I don't hear anything I
will assume everything is good and push them in the
next few days.

Thanks,
Tony

Tony Asleson (19):
  lvm2app: Add thin and thin pool lv creation V4
  lvm2app: Implementation of pv resize (v6)
  lvm2app: Move percent_of_extents to lvm-percent.[h|c]
  lvm2app: Rework argument handling for lv resize
  lvm2app: Move core lv re-size code (v2)
  lvm2app: Implement lv resize (v2)
  lvm2app: Add function to retrieve list of PVs
  lvm2app: Implement lvm_pv_remove
  python-lvm: Add bindings for lvm_pv_remove
  lvm2app: Set suppress to 1
  _get_pvs: Remove unused variable
  lib2app: Fix warnings in lvm_list_pvs_free
  lib2app: Added PV create.
  python-lvm: Add pvCreate python method
  lvm2app: Add method to retrieve attr from lv.
  python-lvm: Add method to retrieve lv attr.
  lvm2app: Add function to retrieve the origin.
  python-lvm: Added lv method getOrigin
  python-lvm: Bindings for thin pool, thin lv creation V3

 lib/metadata/lv_manip.c          | 734 ++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |  59 ++-
 lib/metadata/metadata.c          |  82 ++--
 lib/metadata/metadata.h          |   7 +
 lib/metadata/pv_manip.c          | 152 ++++++++
 lib/misc/lvm-percent.c           |   5 +
 lib/misc/lvm-percent.h           |  17 +
 lib/report/columns.h             |   2 +
 lib/report/properties.c          |  30 ++
 lib/report/properties.h          |   6 +
 lib/report/report.c              |   1 +
 lib/report/report.h              |   3 +-
 liblvm/lvm2app.h                 | 219 ++++++++++-
 liblvm/lvm_base.c                |   6 +
 liblvm/lvm_lv.c                  | 241 +++++++++++-
 liblvm/lvm_misc.c                |  16 +-
 liblvm/lvm_misc.h                |   6 +-
 liblvm/lvm_pv.c                  | 135 ++++++-
 liblvm/lvm_vg.c                  |   4 +-
 python/liblvm.c                  | 331 +++++++++++++++-
 tools/lvresize.c                 | 793 ++-------------------------------------
 tools/pvcreate.c                 |  11 +-
 tools/pvremove.c                 | 135 +------
 tools/reporter.c                 |   4 +
 tools/toollib.c                  |   6 -
 tools/tools.h                    |  16 -
 26 files changed, 2049 insertions(+), 972 deletions(-)

-- 
1.8.1.4


