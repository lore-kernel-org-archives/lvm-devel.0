From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  8 Jul 2013 17:15:52 +0200
Subject: [PATCH 0/7] pool metadata spare
Message-ID: <cover.1373296467.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Updated patch set for spare devices.
Using  _pmspare suffix instead of  lv flag.


Zdenek Kabelac (7):
  thin: add pool metadata spare lv support
  thin: report 'e' volume type pool metadata spare
  thin: removal of spare disables recovery
  thin: add lvchange spare lv manipulation
  thin: add spare lvcreate support
  thin: add lvconvert pool metadata spare
  thin: add vgchange spare support

 lib/config/defaults.h            |   1 +
 lib/format_text/flags.c          |   1 +
 lib/format_text/import_vsn1.c    |  12 +++
 lib/metadata/lv.c                |   1 +
 lib/metadata/lv_manip.c          |  26 ++++++
 lib/metadata/metadata-exported.h |   7 ++
 lib/metadata/metadata.c          |  21 +++++
 lib/metadata/thin_manip.c        | 170 +++++++++++++++++++++++++++++++++++++++
 lib/metadata/vg.h                |   2 +
 lib/misc/lvm-string.c            |   1 +
 man/lvchange.8.in                |   5 ++
 man/lvcreate.8.in                |  11 ++-
 man/lvs.8.in                     |   2 +-
 man/vgchange.8.in                |   5 ++
 tools/args.h                     |   1 +
 tools/commands.h                 |  22 +++--
 tools/lvchange.c                 |  79 +++++++++++++++++-
 tools/lvconvert.c                |  11 +++
 tools/lvcreate.c                 |  18 ++++-
 tools/vgchange.c                 |  25 +++++-
 20 files changed, 407 insertions(+), 14 deletions(-)

-- 
1.8.3.1


