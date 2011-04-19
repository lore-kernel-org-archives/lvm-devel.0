From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Apr 2011 14:55:23 +0200
Subject: [PATCH 0/5] Fixes
Message-ID: <cover.1303215346.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Mostly minor sign cast warning fixes 
and not yet confirmed setvbuf update.

Zdenek Kabelac (5):
  change API to use unsigned for #copies
  Cast to 'int'
  Fix sign warning
  Ignore dm_snprintf result
  Set our own in/out buffers

 daemons/clvmd/lvm-functions.c                      |    2 +-
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    4 +-
 lib/commands/toolcontext.c                         |   30 +++++++++++++++++++-
 lib/commands/toolcontext.h                         |    4 ++-
 lib/filters/filter.h                               |    2 +-
 lib/log/log.c                                      |    4 +-
 lib/metadata/metadata-exported.h                   |    2 +-
 lib/metadata/metadata.c                            |    2 +-
 liblvm/lvm_base.c                                  |    2 +-
 tools/lvmcmdline.c                                 |    2 +-
 10 files changed, 42 insertions(+), 12 deletions(-)

-- 
1.7.4.4


