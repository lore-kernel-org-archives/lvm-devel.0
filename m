From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 25 Apr 2018 08:49:59 -0400
Subject: master - Merge remote-tracking branch 'sourceware/master' into upstream
Message-ID: <201804251249.w3PCnxEH028238@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=28a9fcd94b810cbd603b4fb0c5149bf96f6caeaa
Commit:        28a9fcd94b810cbd603b4fb0c5149bf96f6caeaa
Parent:        f2504257e463bf58d991f8d137923a1a48bf4404 dcb5434a7f4a3b736d72c7bebe276be6735142ce
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed Apr 25 09:18:42 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed Apr 25 09:18:42 2018 +0100

Merge remote-tracking branch 'sourceware/master' into upstream


 .gitignore                            |   44 ++
 Makefile.in                           |   23 +-
 aclocal.m4                            |  222 ++++---
 conf/example.conf.in                  |   16 -
 configure                             |   23 +-
 configure.in                          |   25 -
 daemons/clvmd/Makefile.in             |    2 +-
 daemons/clvmd/lvm-functions.c         |    3 +-
 doc/aio_design.txt                    |  215 ------
 include/.symlinks.in                  |    1 +
 include/configure.h.in                |   19 +-
 lib/Makefile.in                       |    1 +
 lib/activate/activate.c               |   82 +++-
 lib/cache/lvmcache.c                  | 1076 ++++++++++++++----------------
 lib/cache/lvmcache.h                  |   40 +-
 lib/cache/lvmetad.c                   |  485 ++++++++++----
 lib/commands/toolcontext.c            |   23 +-
 lib/commands/toolcontext.h            |    5 +-
 lib/config/config.c                   |  166 ++---
 lib/config/config.h                   |    8 +-
 lib/config/config_settings.h          |   17 +-
 lib/config/defaults.h                 |    4 -
 lib/device/bcache.c                   | 1182 +++++++++++++++++++++++++++++++++
 lib/device/bcache.h                   |  164 +++++
 lib/device/dev-cache.c                |   52 +--
 lib/device/dev-cache.h                |   14 +-
 lib/device/dev-io.c                   |  628 +++---------------
 lib/device/dev-luks.c                 |    2 +-
 lib/device/dev-md.c                   |    2 +-
 lib/device/dev-swap.c                 |    3 +-
 lib/device/dev-type.c                 |    8 +-
 lib/device/device.h                   |  105 +---
 lib/filters/filter-composite.c        |    4 +-
 lib/filters/filter-persistent.c       |   21 +-
 lib/filters/filter.h                  |    2 +-
 lib/format1/disk-rep.c                |   11 +-
 lib/format1/format1.c                 |    2 +-
 lib/format1/lvm1-label.c              |   20 +-
 lib/format_pool/disk_rep.c            |    5 +-
 lib/format_pool/format_pool.c         |    2 +-
 lib/format_pool/pool_label.c          |   13 +-
 lib/format_text/archive.c             |    6 +-
 lib/format_text/archiver.c            |   12 +-
 lib/format_text/export.c              |   21 +-
 lib/format_text/format-text.c         |  907 ++++++++++----------------
 lib/format_text/import-export.h       |   16 +-
 lib/format_text/import.c              |  281 ++++-----
 lib/format_text/import_vsn1.c         |   60 +-
 lib/format_text/layout.h              |   12 +-
 lib/format_text/text_label.c          |  205 ++-----
 lib/label/label.c                     |  998 +++++++++++++++++++++-------
 lib/label/label.h                     |   33 +-
 lib/metadata/lv_manip.c               |    2 +-
 lib/metadata/metadata-exported.h      |   13 +
 lib/metadata/metadata-liblvm.c        |    7 +-
 lib/metadata/metadata.c               |  429 +++++++------
 lib/metadata/metadata.h               |   17 +-
 lib/metadata/vg.c                     |    5 -
 lib/misc/lvm-globals.c                |   23 -
 lib/misc/lvm-globals.h                |    4 -
 libdm/libdm-config.c                  |   10 +-
 liblvm/Makefile.in                    |    2 +-
 liblvm/lvm_vg.c                       |    3 +-
 make.tmpl.in                          |   65 ++-
 man/Makefile.in                       |   81 ++--
 old-tests/config/.gitignore           |    1 -
 old-tests/config/Makefile             |    5 -
 old-tests/config/config_t.c           |   37 -
 old-tests/config/empty_array.conf     |    1 -
 old-tests/config/vg0                  |  169 -----
 old-tests/datastruct/hash_t.c         |  106 ---
 old-tests/dev-mgr/dev_cache_t.c       |   54 --
 old-tests/device/Makefile.in          |   29 -
 old-tests/device/dev_cache_t.c        |   70 --
 old-tests/device/fill_device.c        |   27 -
 old-tests/device/random.c             |  116 ----
 old-tests/device/random.h             |   32 -
 old-tests/filters/Makefile.in         |   35 -
 old-tests/filters/pfilter_t.c         |  121 ----
 old-tests/filters/rfilter_t.c         |   92 ---
 old-tests/filters/sample.cfg          |   21 -
 old-tests/format1/Makefile.in         |   52 --
 old-tests/format1/get_pvs_t.c         |   73 --
 old-tests/format1/get_vgs_t.c         |   69 --
 old-tests/format1/pretty_print.c      |   86 ---
 old-tests/format1/pretty_print.h      |   28 -
 old-tests/format1/read_pv_t.c         |   75 ---
 old-tests/format1/read_vg_t.c         |   75 ---
 old-tests/format1/write_vg_t.c        |   77 ---
 old-tests/mm/Makefile.in              |   33 -
 old-tests/mm/dbg_malloc_t.c           |  156 -----
 scripts/Makefile.in                   |    2 +-
 test/Makefile.in                      |    2 +-
 test/lib/flavour-ndev-cluster.sh      |    1 -
 test/lib/flavour-ndev-vanilla.sh      |    1 -
 test/lib/flavour-udev-cluster.sh      |    1 -
 test/lib/flavour-udev-vanilla.sh      |    1 -
 test/shell/lvconvert-mirror-updown.sh |   25 +-
 test/shell/lvconvert-mirror.sh        |  129 ++--
 test/shell/mda-rollback.sh            |    3 +
 test/shell/vgck.sh                    |    8 +-
 test/shell/vgsplit-usage.sh           |    2 +
 test/unit/Makefile.in                 |   53 +-
 test/unit/bcache_t.c                  |  636 ++++++++++++++++++
 test/unit/run.c                       |    1 +
 test/unit/units.h                     |    1 +
 tools/Makefile.in                     |   75 ++-
 tools/command.c                       |   15 +-
 tools/commands.h                      |   18 +-
 tools/lvchange.c                      |    4 +
 tools/lvconvert.c                     |    7 +
 tools/lvmcmdline.c                    |   19 +-
 tools/lvmdiskscan.c                   |    7 +-
 tools/polldaemon.c                    |   20 +-
 tools/pvck.c                          |    2 +
 tools/pvscan.c                        |   53 ++-
 tools/toollib.c                       |  181 ++++--
 tools/tools.h                         |   10 +-
 tools/vgcfgrestore.c                  |    2 +
 tools/vgchange.c                      |   17 +-
 tools/vgcreate.c                      |   27 +-
 tools/vgimportclone.c                 |    1 -
 tools/vgmerge.c                       |    3 +
 tools/vgrename.c                      |    5 -
 tools/vgsplit.c                       |    3 +
 unit-tests/datastruct/Makefile.in     |   32 -
 unit-tests/datastruct/TESTS           |    1 -
 unit-tests/datastruct/bitset_t.c      |  133 ----
 unit-tests/mm/Makefile.in             |   31 -
 unit-tests/mm/TESTS                   |    1 -
 unit-tests/mm/check_results           |   31 -
 unit-tests/mm/pool_valgrind_t.c       |  181 -----
 unit-tests/regex/Makefile.in          |   37 -
 unit-tests/regex/TESTS                |    3 -
 unit-tests/regex/dev_patterns         |    2 -
 unit-tests/regex/devices.list         |  880 ------------------------
 unit-tests/regex/matcher_t.c          |  156 -----
 unit-tests/regex/matcher_t.expected   |   16 -
 unit-tests/regex/matcher_t.expected2  |    1 -
 unit-tests/regex/matcher_t.expected3  |    3 -
 unit-tests/regex/nonprint_input       |    4 -
 unit-tests/regex/nonprint_regexes     |    3 -
 unit-tests/regex/parse_t.c            |  118 ----
 unit-tests/regex/random_regexes       |  100 ---
 144 files changed, 5487 insertions(+), 7173 deletions(-)

diff --cc .gitignore
index 28846b1,0ac0a32..7e031bf
--- a/.gitignore
+++ b/.gitignore
@@@ -32,6 -31,50 +32,50 @@@ make.tmp
  /tags
  /tmp/
  
 +
  tools/man-generator
  tools/man-generator.c
+ 
+ test/lib/lvchange
+ test/lib/lvconvert
+ test/lib/lvcreate
+ test/lib/lvdisplay
+ test/lib/lvextend
+ test/lib/lvmconfig
+ test/lib/lvmdiskscan
+ test/lib/lvmsadc
+ test/lib/lvmsar
+ test/lib/lvreduce
+ test/lib/lvremove
+ test/lib/lvrename
+ test/lib/lvresize
+ test/lib/lvs
+ test/lib/lvscan
+ test/lib/pvchange
+ test/lib/pvck
+ test/lib/pvcreate
+ test/lib/pvdisplay
+ test/lib/pvmove
+ test/lib/pvremove
+ test/lib/pvresize
+ test/lib/pvs
+ test/lib/pvscan
+ test/lib/vgcfgbackup
+ test/lib/vgcfgrestore
+ test/lib/vgchange
+ test/lib/vgck
+ test/lib/vgconvert
+ test/lib/vgcreate
+ test/lib/vgdisplay
+ test/lib/vgexport
+ test/lib/vgextend
+ test/lib/vgimport
+ test/lib/vgimportclone
+ test/lib/vgmerge
+ test/lib/vgmknodes
+ test/lib/vgreduce
+ test/lib/vgremove
+ test/lib/vgrename
+ test/lib/vgs
+ test/lib/vgscan
+ test/lib/vgsplit
 -


