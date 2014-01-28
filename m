From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 28 Jan 2014 08:16:06 -0600
Subject: [LVM PATCH 0/3] Another set of cache patches
Message-ID: <1390918569-22041-1-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This set does not yet complete the LVM cache and cache_pool segment types,
but it should give something to chew on while I prepare the final patches.

Jonathan Brassow (3):
  cache: New functions for gathering info on cache devices
  cache:  Allocation code changes necessary to support cache_pool
  cache/pool: Make the fns in pool_manip.c work with cache pools

 conf/example.conf.in             |    4 +
 lib/activate/activate.c          |  168 ++++++++++++++++++++++++++++++++++++++
 lib/activate/activate.h          |    6 ++
 lib/activate/dev_manager.c       |   51 +++++++++++-
 lib/activate/dev_manager.h       |    3 +
 lib/config/config_settings.h     |    1 +
 lib/config/defaults.h            |    2 +
 lib/metadata/lv_manip.c          |   39 +++++++--
 lib/metadata/metadata-exported.h |   11 +++
 lib/metadata/pool_manip.c        |   44 +++++++----
 10 files changed, 306 insertions(+), 23 deletions(-)

-- 
1.7.7.6


