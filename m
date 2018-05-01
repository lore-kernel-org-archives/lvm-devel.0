From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 1 May 2018 05:50:19 -0400
Subject: master - Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
Message-ID: <201805010950.w419oJ5D002629@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c863c9581dead8f41e30c66df38017bef2229a90
Commit:        c863c9581dead8f41e30c66df38017bef2229a90
Parent:        7aba7fe68b6da2ca8ec7b01f5730396d64426fb0 c1cd18f21ef233fa19e948cf130e97c005a349ad
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue May 1 10:48:42 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue May 1 10:48:42 2018 +0100

Merge branch 'master' of git+ssh://sourceware.org/git/lvm2


 configure.ac                      |   58 ---
 daemons/clvmd/clvmd-command.c     |    1 -
 daemons/clvmd/lvm-functions.c     |   10 -
 daemons/clvmd/lvm-functions.h     |    1 -
 daemons/lvmetad/lvmetad-client.h  |    1 -
 daemons/lvmetad/lvmetad-core.c    |    9 +-
 lib/Makefile.in                   |   29 --
 lib/activate/activate.c           |   13 -
 lib/activate/activate.h           |    1 -
 lib/cache/lvmcache.c              |   10 +-
 lib/cache/lvmetad.c               |   23 +-
 lib/commands/toolcontext.c        |   22 -
 lib/config/config_settings.h      |   20 +-
 lib/display/display.c             |    9 +-
 lib/format1/.exported_symbols     |    1 -
 lib/format1/Makefile.in           |   33 --
 lib/format1/disk-rep.c            |  761 -------------------------------------
 lib/format1/disk-rep.h            |  250 ------------
 lib/format1/format1.c             |  631 ------------------------------
 lib/format1/format1.h             |   29 --
 lib/format1/import-export.c       |  680 ---------------------------------
 lib/format1/import-extents.c      |  377 ------------------
 lib/format1/layout.c              |  172 ---------
 lib/format1/lvm1-label.c          |  129 -------
 lib/format1/lvm1-label.h          |   23 --
 lib/format1/vg_number.c           |   60 ---
 lib/format_pool/.exported_symbols |    1 -
 lib/format_pool/Makefile.in       |   30 --
 lib/format_pool/disk_rep.c        |  409 --------------------
 lib/format_pool/disk_rep.h        |  156 --------
 lib/format_pool/format_pool.c     |  338 ----------------
 lib/format_pool/format_pool.h     |   28 --
 lib/format_pool/import_export.c   |  285 --------------
 lib/format_pool/pool_label.c      |  104 -----
 lib/format_pool/pool_label.h      |   23 --
 lib/format_pool/sptype_names.h    |   42 --
 lib/format_text/export.c          |    2 -
 lib/format_text/format-text.c     |    4 +-
 lib/format_text/import_vsn1.c     |    9 +-
 lib/locking/locking.c             |   40 --
 lib/metadata/lv_manip.c           |   26 --
 lib/metadata/metadata-exported.h  |   10 +-
 lib/metadata/metadata.c           |   27 +-
 lib/metadata/segtype.h            |    2 +-
 lib/metadata/snapshot_manip.c     |   11 -
 lib/metadata/vg.c                 |   17 +-
 lib/metadata/vg.h                 |    1 -
 lib/report/report.c               |    4 +-
 lib/striped/striped.c             |    2 +-
 man/vgconvert.8_des               |    7 +-
 test/lib/aux.sh                   |    4 -
 test/shell/format-lvm1.sh         |   38 --
 test/shell/lvm1-basic.sh          |   36 --
 test/shell/snapshot-lvm1.sh       |   35 --
 tools/args.h                      |    3 +-
 tools/lvconvert.c                 |    5 -
 tools/lvmcmdline.c                |   58 +---
 tools/pvscan.c                    |    5 +-
 tools/stub.h                      |    1 -
 tools/toollib.c                   |   29 +--
 tools/vals.h                      |    4 +-
 tools/vgchange.c                  |   10 -
 tools/vgconvert.c                 |   53 +--
 tools/vgscan.c                    |    4 +-
 64 files changed, 62 insertions(+), 5154 deletions(-)


