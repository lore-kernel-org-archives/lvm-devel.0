From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  5 Jul 2016 13:45:16 +0000 (UTC)
Subject: master - Merge branch 'master' of ssh://git.fedorahosted.org/git/lvm2
Message-ID: <20160705134516.661F960DAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b1b32c900adb69a780bfaf673bc63189e7c86541
Commit:        b1b32c900adb69a780bfaf673bc63189e7c86541
Parent:        7cec710e37271999950d67faaf802e1598278fac e5d1f3d6c5433e8b118e572a507f121c45729715
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Jul 4 22:29:52 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Jul 4 22:29:52 2016 +0200

Merge branch 'master' of ssh://git.fedorahosted.org/git/lvm2


 WHATS_NEW                                     |    3 +
 WHATS_NEW_DM                                  |    1 +
 daemons/cmirrord/functions.c                  |    6 +
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |  112 ++-
 daemons/lvmetad/lvmetad-core.c                |    2 +-
 daemons/lvmpolld/lvmpolld-cmd-utils.c         |    2 +-
 lib/activate/dev_manager.c                    |   10 +-
 lib/cache/lvmcache.c                          |    3 +-
 lib/cache/lvmetad.c                           |    2 +-
 lib/display/display.c                         |    2 +-
 lib/format_pool/import_export.c               |    2 +-
 lib/format_text/archiver.c                    |    1 -
 lib/metadata/lv_manip.c                       |   33 +-
 lib/metadata/raid_manip.c                     |  461 +++++++--
 lib/metadata/segtype.c                        |    4 +
 lib/metadata/segtype.h                        |    6 +-
 lib/metadata/takeover_matrix.h                |    4 +-
 lib/metadata/thin_manip.c                     |    2 +-
 lib/metadata/vg.c                             |    4 +-
 lib/raid/raid.c                               |   31 +-
 lib/thin/thin.c                               |    4 +-
 libdm/libdm-deptree.c                         |   16 +-
 man/dmstats.8.in                              |    5 -
 test/Makefile.in                              |    1 +
 test/lib/aux.sh                               |    4 +-
 test/lib/mke2fs.conf                          |   45 +
 test/shell/lvconvert-cache.sh                 |    2 +-
 test/shell/lvconvert-mirror.sh                |   21 +-
 test/shell/thin-autoumount-dmeventd.sh        |   34 +-
 test/shell/thin-foreign-dmeventd.sh           |  108 ++
 test/shell/thin-overprovisioning.sh           |    4 +
 tools/dmsetup.c                               |   16 +-
 tools/lvchange.c                              |  212 ++--
 tools/lvconvert.c                             | 1299 +++++++++++++++++++++----
 tools/lvcreate.c                              |   18 +-
 tools/toollib.c                               |    2 +-
 36 files changed, 1974 insertions(+), 508 deletions(-)


