From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 31 Jan 2014 18:03:06 -0600
Subject: [LVM PATCH 0/6] Next set of LVM cache patches
Message-ID: <1391212992-3439-1-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These patches add the ability to create and remove cache pools and
cache LVs.  Yet to be addressed is reporting code (i.e. 'lvs'), man
page updates, arguments for cache pool tunables (i.e. changing policies,
cache mode, etc), profiles, and converting.

I'd still like to work on patch 5 a bit yet, but comments are welcome on
these patches while I do that.

Jonathan Brassow (6):
  pool: Make another thin pool fn generic for cache usage also
  cache: Add functions that create/remove cache LVs
  cache: Code changes to allow creation of cache pools
  cache: Code changes to allow removal of cachepool LVs
  cache: Code to allow the creation of cache LVs
  cache: Code that allows removal of cache LVs

 conf/example.conf.in             |   11 ++
 lib/Makefile.in                  |    1 +
 lib/activate/dev_manager.c       |   11 ++-
 lib/config/config_settings.h     |    3 +
 lib/config/defaults.h            |    3 +-
 lib/format_text/flags.c          |    4 +
 lib/metadata/cache_manip.c       |  219 +++++++++++++++++++++++++++++
 lib/metadata/lv_manip.c          |  284 +++++++++++++++++++++++++++++++------
 lib/metadata/merge.c             |   60 +++++++--
 lib/metadata/metadata-exported.h |   12 ++-
 libdm/libdevmapper.h             |    5 +
 tools/args.h                     |    1 +
 tools/commands.h                 |    7 +-
 tools/lvcreate.c                 |  196 ++++++++++++++++++++++++--
 14 files changed, 738 insertions(+), 79 deletions(-)
 create mode 100644 lib/metadata/cache_manip.c

-- 
1.7.7.6


