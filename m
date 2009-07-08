From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 08 Jul 2009 12:34:16 -0400
Subject: [PATCH 0/2] error messages bound to command
In-Reply-To: <1246998001-17258-1-git-send-email-twoerner@redhat.com>
References: <1246998001-17258-1-git-send-email-twoerner@redhat.com>
Message-ID: <1247070856.2507.3.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2009-07-07 at 22:19 +0200, Thomas Woerner wrote:
> This patch series add functions to add an error message and the error code to 
> the command context. This is needed for liblvm to be able to have handle 
> specific error reporting.
> 
> The first patch add the needed functions and corrects some code to use a script to add the error code to all log_error and log_err functions. It replaces all 
> log_err calls with log_error. The result is the second patch.
> 
> The script:
> 
>     find . -name "*.[hc]" -exec perl -pi -e "s/log_error\(\"/log_error\(0, \"/g" {} \;
>     find . -name "*.[hc]" -exec perl -pi -e "s/log_err\(\"/log_error\(0, \"/g" {} \;
>     find . -name "*.[hc]" -exec perl -pi -e "s/log_error\(no_space\)/log_error\(0, no_space\)/g" {} \;
>     perl -pi -e "s/log_error\(bad,/log_error\(0, bad,/g" lib/format_text/import_vsn1.c
> 

I think the default code for log_error should be nonzero right?

In your patches you have:
+       if (lvm_error(cmd) != 0) {
+               log_error(0, "Failed to create command context");

Maybe make it -1 for now?

> testsuite: pass
> 
> twoerner (2):
>   Add cmd logging for liblvm error reporting: All logging functions
>     have an additional argument: The error code This makes the
>     functions incompatible with the old ones.
>   Add error code for all log_err and log_error calls. Replace log_err
>     with log_error.
> 
>  daemons/clvmd/clvmd-cman.c            |    8 +-
>  daemons/clvmd/clvmd-command.c         |    2 +-
>  daemons/clvmd/clvmd-gulm.c            |    4 +-
>  daemons/clvmd/clvmd.c                 |   26 ++--
>  daemons/clvmd/lvm-functions.c         |   15 ++-
>  daemons/dmeventd/libdevmapper-event.c |   50 ++++----
>  lib/activate/activate.c               |   26 ++--
>  lib/activate/dev_manager.c            |   64 +++++-----
>  lib/activate/fs.c                     |   24 ++--
>  lib/cache/lvmcache.c                  |   70 +++++-----
>  lib/commands/toolcontext.c            |  119 +++++++++--------
>  lib/commands/toolcontext.h            |    6 +
>  lib/config/config.c                   |   38 +++---
>  lib/device/dev-cache.c                |   50 ++++----
>  lib/device/dev-io.c                   |   22 ++--
>  lib/device/dev-md.c                   |    8 +-
>  lib/device/device.c                   |   12 +-
>  lib/display/display.c                 |    4 +-
>  lib/error/errseg.c                    |    2 +-
>  lib/filters/filter-composite.c        |    4 +-
>  lib/filters/filter-md.c               |    2 +-
>  lib/filters/filter-persistent.c       |    6 +-
>  lib/filters/filter-regex.c            |    4 +-
>  lib/filters/filter-sysfs.c            |   10 +-
>  lib/filters/filter.c                  |   10 +-
>  lib/format1/disk-rep.c                |   30 ++--
>  lib/format1/format1.c                 |   22 ++--
>  lib/format1/import-export.c           |   22 ++--
>  lib/format1/import-extents.c          |   24 ++--
>  lib/format1/layout.c                  |   10 +-
>  lib/format1/lvm1-label.c              |    4 +-
>  lib/format_pool/disk_rep.c            |    4 +-
>  lib/format_pool/format_pool.c         |   20 ++--
>  lib/format_pool/import_export.c       |   14 +-
>  lib/format_pool/pool_label.c          |    4 +-
>  lib/format_text/archive.c             |   16 +-
>  lib/format_text/archiver.c            |   32 +++---
>  lib/format_text/export.c              |   12 +-
>  lib/format_text/flags.c               |    8 +-
>  lib/format_text/format-text.c         |   96 +++++++-------
>  lib/format_text/import.c              |    2 +-
>  lib/format_text/import_vsn1.c         |  120 ++++++++--------
>  lib/format_text/tags.c                |    2 +-
>  lib/format_text/text_label.c          |   16 +-
>  lib/label/label.c                     |   14 +-
>  lib/locking/cluster_locking.c         |   20 ++--
>  lib/locking/external_locking.c        |    4 +-
>  lib/locking/file_locking.c            |    6 +-
>  lib/locking/locking.c                 |   18 ++--
>  lib/locking/no_locking.c              |    2 +-
>  lib/log/log.c                         |   44 ++++++-
>  lib/log/log.h                         |   16 +-
>  lib/log/lvm-logging.h                 |   11 +-
>  lib/metadata/lv_manip.c               |  176 ++++++++++++------------
>  lib/metadata/merge.c                  |   46 +++---
>  lib/metadata/metadata.c               |  238 ++++++++++++++++----------------
>  lib/metadata/mirror.c                 |  156 +++++++++++-----------
>  lib/metadata/pv_manip.c               |   32 +++---
>  lib/metadata/pv_map.c                 |    4 +-
>  lib/metadata/segtype.c                |    2 +-
>  lib/metadata/snapshot_manip.c         |    6 +-
>  lib/mirror/mirrored.c                 |   34 +++---
>  lib/misc/lvm-exec.c                   |    8 +-
>  lib/misc/lvm-file.c                   |   16 +-
>  lib/misc/lvm-string.c                 |    2 +-
>  lib/misc/sharedlib.c                  |    4 +-
>  lib/mm/memlock.c                      |    4 +-
>  lib/report/report.c                   |   58 ++++----
>  lib/snapshot/snapshot.c               |   14 +-
>  lib/striped/striped.c                 |    8 +-
>  lib/uuid/uuid.c                       |    8 +-
>  lib/zero/zero.c                       |    2 +-
>  libdm/ioctl/libdm-iface.c             |   94 +++++++-------
>  libdm/libdevmapper.h                  |    4 +-
>  libdm/libdm-common.c                  |   39 +++---
>  libdm/libdm-deptree.c                 |  154 +++++++++++-----------
>  libdm/libdm-file.c                    |    2 +-
>  libdm/libdm-report.c                  |  104 +++++++-------
>  libdm/misc/dm-logging.h               |    2 +-
>  libdm/mm/dbg_malloc.c                 |   10 +-
>  libdm/mm/pool-debug.c                 |    8 +-
>  libdm/mm/pool-fast.c                  |    6 +-
>  libdm/mm/pool.c                       |    6 +-
>  libdm/regex/matcher.c                 |    4 +-
>  libdm/regex/parse_rx.c                |   10 +-
>  liblvm/Makefile.in                    |    2 +
>  liblvm/lvm.h                          |    3 +
>  liblvm/lvm_base.c                     |   19 +++-
>  old-tests/datastruct/hash_t.c         |    4 +-
>  old-tests/dev-mgr/dev_cache_t.c       |    6 +-
>  old-tests/device/dev_cache_t.c        |    6 +-
>  old-tests/device/random.c             |    4 +-
>  old-tests/filters/pfilter_t.c         |    4 +-
>  old-tests/filters/rfilter_t.c         |    2 +-
>  tools/dmsetup.c                       |   42 +++---
>  tools/lvchange.c                      |  100 +++++++-------
>  tools/lvconvert.c                     |  112 ++++++++--------
>  tools/lvcreate.c                      |  156 +++++++++++-----------
>  tools/lvdisplay.c                     |    6 +-
>  tools/lvm.c                           |   10 +-
>  tools/lvmcmdlib.c                     |    8 +-
>  tools/lvmcmdline.c                    |   57 +++++----
>  tools/lvmdiskscan.c                   |   10 +-
>  tools/lvremove.c                      |    2 +-
>  tools/lvrename.c                      |   18 ++--
>  tools/lvresize.c                      |   68 +++++-----
>  tools/lvscan.c                        |    2 +-
>  tools/polldaemon.c                    |   16 +-
>  tools/pvchange.c                      |   47 +++----
>  tools/pvcreate.c                      |   58 ++++----
>  tools/pvdisplay.c                     |   10 +-
>  tools/pvmove.c                        |   66 +++++-----
>  tools/pvremove.c                      |   20 ++--
>  tools/pvresize.c                      |   28 ++--
>  tools/pvscan.c                        |    4 +-
>  tools/reporter.c                      |   10 +-
>  tools/stub.h                          |    8 +-
>  tools/toollib.c                       |  116 ++++++++--------
>  tools/vgcfgbackup.c                   |    8 +-
>  tools/vgcfgrestore.c                  |   10 +-
>  tools/vgchange.c                      |   66 +++++-----
>  tools/vgconvert.c                     |   38 +++---
>  tools/vgcreate.c                      |   14 +-
>  tools/vgdisplay.c                     |    8 +-
>  tools/vgexport.c                      |    6 +-
>  tools/vgextend.c                      |    6 +-
>  tools/vgimport.c                      |    8 +-
>  tools/vgmerge.c                       |    6 +-
>  tools/vgreduce.c                      |   58 ++++----
>  tools/vgremove.c                      |    4 +-
>  tools/vgrename.c                      |   14 +-
>  tools/vgscan.c                        |    4 +-
>  tools/vgsplit.c                       |   28 ++--
>  133 files changed, 1910 insertions(+), 1832 deletions(-)
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


