From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 11 Aug 2011 09:33:39 +0200
Subject: [PATCH 0/5] ShareVG
Message-ID: <cover.1313047685.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

New version of shared VG.
Upon review the order in patch has been a bit modified.
I've moded holder counter from vg to vginfo which simplified patch.
It's now better vissible 1-to-1 mapping between vg and vginfo.
Updated some comments.
Renamed verify_vg_crc to detect_internal_vg_cache_corruption.

Added udev patch to this patch set so it's not forgotten.

Patch was not yet well tested - I'll try to do more testing in 
the afternoon. But test-suite has passed.

Zdenek Kabelac (5):
  Add cache_vg
  Pool locking code
  Lock memory for shared VG
  Add detect_internal_vg_cache_corruption option
  Do not decode DM flags for device removal

 WHATS_NEW                  |    1 +
 doc/example.conf.in        |    5 ++
 lib/cache/lvmcache.c       |   50 +++++++++++++++++++--
 lib/cache/lvmcache.h       |    7 +++
 lib/commands/toolcontext.c |    4 ++
 lib/config/defaults.h      |    1 +
 lib/metadata/metadata.c    |   22 +++++++++
 lib/metadata/vg.c          |    9 ++++
 lib/metadata/vg.h          |    1 +
 lib/misc/lvm-globals.c     |   12 +++++
 lib/misc/lvm-globals.h     |    2 +
 libdm/libdevmapper.h       |   16 +++++++
 libdm/mm/pool-debug.c      |   30 ++++++++++++
 libdm/mm/pool-fast.c       |   66 ++++++++++++++++++++++++++-
 libdm/mm/pool.c            |  107 +++++++++++++++++++++++++++++++++++++++++++-
 make.tmpl.in               |    4 ++
 test/lib/aux.sh            |    1 +
 udev/10-dm.rules.in        |   12 +++---
 18 files changed, 337 insertions(+), 13 deletions(-)

-- 
1.7.6


