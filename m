From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 9 Sep 2019 13:20:24 -0400
Subject: 2019-09-05-add-io-manager - Merge branch '2019-09-05-add-io-manager' of git+ssh://sourceware.org/git/lvm2 into 2019-09-05-add-io-manager
Message-ID: <201909091720.x89HKOMS030001@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=510a6e86a354537c981386e7a46d5f2c26855660
Commit:        510a6e86a354537c981386e7a46d5f2c26855660
Parent:        e4693f7f8db38230362255ebc30d6b8a5bd40918 13c702f862008192a36ee171e546ba0d247bcf9f
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Sep 9 18:21:20 2019 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Sep 9 18:21:20 2019 +0100

Merge branch '2019-09-05-add-io-manager' of git+ssh://sourceware.org/git/lvm2 into 2019-09-05-add-io-manager


 lib/device/io-manager.c |   62 +++++++++++++++++++++++++---------------------
 lib/device/io-manager.h |    4 +-
 2 files changed, 36 insertions(+), 30 deletions(-)

diff --cc lib/device/io-manager.h
index 253b3ad,af33259..923d0be
--- a/lib/device/io-manager.h
+++ b/lib/device/io-manager.h
@@@ -61,11 -61,11 +61,11 @@@ struct io_engine 
  	// The path is there purely for logging.
  	bool (*get_size)(struct io_engine *e, const char *path, int fd, sector_t *size);
  	bool (*get_block_sizes)(struct io_engine *e, const char *path, int fd,
-                                 unsigned *physical, unsigned *logical);
+                                 unsigned *physical_block_size, unsigned *logical_block_size);
  };
  
 -struct io_engine *create_async_io_engine(bool use_o_direct);
 -struct io_engine *create_sync_io_engine(bool use_o_direct);
 +struct io_engine *create_async_io_engine(void);
 +struct io_engine *create_sync_io_engine(void);
  
  // Same as create_async_io_engine(), except writes are not acted upon.
  // Used when running with --test.
@@@ -198,11 -197,10 +198,11 @@@ bool io_invalidate_dev(struct io_manage
  bool io_invalidate_all(struct io_manager *iom);
  
  bool io_dev_size(struct io_dev *dev, uint64_t *sectors);
- bool io_dev_block_sizes(struct io_dev *dev, unsigned *physical, unsigned *block_size);
+ bool io_dev_block_sizes(struct io_dev *dev, unsigned *physical_block_size, unsigned *logical_block_size);
  
  // For testing and debug only
 -int io_get_fd(struct io_dev *dev);
 +void *io_get_dev_context(struct io_dev *dev);
 +int io_get_fd(void *dev_context);
  bool io_is_well_formed(struct io_manager *iom);
  
  //----------------------------------------------------------------


