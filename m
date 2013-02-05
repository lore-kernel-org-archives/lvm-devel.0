From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  5 Feb 2013 14:56:01 +0100
Subject: [PATCH 0/6] Thin external origin support
Message-ID: <cover.1360072297.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Pach set adds support for external origin usage for thin volumes.
Usage might be observed in the 'tests:' patch 6.

I've tried to combine as many usage patterns as I could think of,
but if someone sees still some missing behavior, report please.

Patch set does not provide yet for 'lvcreate -s' usage.

Zdenek Kabelac (6):
  thin: add support for external origin
  thin: external origin cannot be changed
  thin: report external origin
  thin: removal of external origin
  thin: lvconvert support for external origin
  tests: lvconvert external origin

 lib/activate/activate.c               |   6 +-
 lib/activate/dev_manager.c            |  40 ++++++++
 lib/format_text/flags.c               |   3 +-
 lib/metadata/lv.c                     |   9 +-
 lib/metadata/lv_manip.c               |  62 ++++++++----
 lib/metadata/merge.c                  |   7 +-
 lib/metadata/metadata-exported.h      |   5 +-
 lib/metadata/metadata.h               |   5 +-
 lib/metadata/thin_manip.c             |  50 ++++++++++
 lib/report/report.c                   |   3 +
 lib/thin/thin.c                       |  33 ++++++-
 man/lvconvert.8.in                    |  32 +++++++
 test/shell/lvconvert-thin-external.sh |  82 ++++++++++++++++
 tools/args.h                          |   3 +-
 tools/commands.h                      |   7 +-
 tools/lvchange.c                      |   6 ++
 tools/lvconvert.c                     | 173 ++++++++++++++++++++++++++++++++--
 tools/lvresize.c                      |   9 ++
 18 files changed, 497 insertions(+), 38 deletions(-)
 create mode 100644 test/shell/lvconvert-thin-external.sh

-- 
1.8.1.2


