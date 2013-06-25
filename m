From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 25 Jun 2013 13:56:00 +0200
Subject: [PATCH 0/6] spare LV support
Message-ID: <cover.1372161214.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Initial preparation for handling spare LVs within LV.
Spare LV is going to be used for thin pool recovery.
There is one spare LV per pool always sized as the
largest thin pool metadata LV in the VG.

Zdenek Kabelac (6):
  thin: add spare lv support
  thin: report spare as 'e' volume type
  thin: removal of spare disables recovery
  thin: lvchange spare lv manipulation
  thin: add spare lvcreate support
  thin: unfinished lvconvert

 lib/format_text/flags.c          |  1 +
 lib/format_text/import_vsn1.c    | 10 +++++
 lib/metadata/lv.c                |  1 +
 lib/metadata/lv_manip.c          | 19 +++++++++
 lib/metadata/metadata-exported.h |  4 ++
 lib/metadata/metadata.c          | 24 +++++++----
 lib/metadata/snapshot_manip.c    |  3 +-
 lib/metadata/vg.h                |  2 +
 tools/args.h                     |  1 +
 tools/commands.h                 | 18 +++++----
 tools/lvchange.c                 | 86 +++++++++++++++++++++++++++++++++++++++-
 tools/lvconvert.c                |  2 +
 tools/lvcreate.c                 | 83 +++++++++++++++++++++++++++++++++++++-
 13 files changed, 235 insertions(+), 19 deletions(-)

-- 
1.8.2.1


