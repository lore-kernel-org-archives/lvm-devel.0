From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 14:22:47 +0100
Subject: [PATCH 00/12] Misc updates
Message-ID: <cover.1321449480.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Some of patches that has accumulated in my tree
and they should be upstreamed and are unrelated
to thin coding.

Comments are enclosed with each patch.

"Do not zero full 16KB" should be examined closely.

"DEBUG Stack" is rather proposal not a final patch.


Zdenek Kabelac (12):
  Allow to activate snapshot
  Query before removing inactive snapshots
  Code reorder
  Unlock memory for vg_write
  Change default prefix.
  Do not zero full 16KB data
  Replace dynamic buffer allocations for PATH_MAX
  Check for DM_MAX_TYPE_NAME length
  Limit max stack size
  Remove constant expression check
  Remove fixmes
  DEBUG Stack detection code

 doc/example.conf.in           |    6 ++--
 lib/activate/activate.c       |    4 +-
 lib/activate/dev_manager.c    |   10 +++----
 lib/activate/fs.c             |   12 ++++----
 lib/commands/toolcontext.c    |    6 ++--
 lib/config/defaults.h         |    2 +-
 lib/filters/filter.c          |    3 --
 lib/format_text/format-text.c |    2 +-
 lib/metadata/lv_manip.c       |   12 ++++++++-
 lib/metadata/metadata.c       |   18 +++++++-----
 lib/mm/memlock.c              |   58 ++++++++++++++++++++++++++++++++++++++--
 libdm/ioctl/libdm-iface.c     |   43 ++++++++++++++++++++----------
 libdm/libdm-common.c          |    3 +-
 test/t-lvcreate-usage.sh      |    2 +-
 tools/lvchange.c              |   28 ++++++++++++++++---
 tools/toollib.c               |   30 +++++---------------
 16 files changed, 158 insertions(+), 81 deletions(-)

-- 
1.7.7.3


