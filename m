From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  5 Jul 2016 13:45:14 +0000 (UTC)
Subject: master - Merge branch 'master' of ssh://git.fedorahosted.org/git/lvm2
Message-ID: <20160705134514.5150B6096F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7cec710e37271999950d67faaf802e1598278fac
Commit:        7cec710e37271999950d67faaf802e1598278fac
Parent:        6c86d942193e35077537753de91970afbcb0acdd eac0706761e628532ffcd27f3e4d7fa559a5f818
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jun 29 16:34:42 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jun 29 16:34:42 2016 +0200

Merge branch 'master' of ssh://git.fedorahosted.org/git/lvm2


 VERSION                           |    2 +-
 VERSION_DM                        |    2 +-
 WHATS_NEW                         |   16 +-
 WHATS_NEW_DM                      |    5 +-
 daemons/lvmdbusd/background.py    |   83 +--
 daemons/lvmdbusd/cmdhandler.py    |   59 ++-
 daemons/lvmdbusd/job.py           |    2 +-
 daemons/lvmdbusd/lv.py            |   36 +-
 daemons/lvmdbusd/lvmdb.py         |  171 +++++-
 daemons/lvmdbusd/main.py          |    6 +-
 daemons/lvmdbusd/objectmanager.py |    2 +-
 daemons/lvmdbusd/request.py       |    7 +-
 daemons/lvmdbusd/vg.py            |   19 +-
 daemons/lvmetad/lvmetad-core.c    |    9 +-
 daemons/lvmlockd/lvmlockd-core.c  |    1 +
 lib/cache/lvmetad.c               |  147 +++++-
 lib/cache/lvmetad.h               |   11 +-
 lib/config/defaults.h             |    3 +-
 lib/format_text/archiver.c        |    1 +
 lib/locking/locking.h             |    6 +-
 lib/metadata/lv.c                 |   30 +-
 lib/metadata/lv_manip.c           |    3 +-
 lib/metadata/metadata-exported.h  |    1 -
 lib/metadata/metadata.c           |   50 +-
 lib/metadata/metadata.h           |    4 +
 lib/metadata/pv_manip.c           |    2 +-
 lib/metadata/raid_manip.c         | 1097 ++++++++++++++++++++++++++++++++++---
 lib/metadata/replicator_manip.c   |    1 +
 lib/metadata/segtype.c            |   13 +
 lib/metadata/segtype.h            |    2 +
 lib/metadata/takeover_matrix.h    |  120 ++++
 lib/metadata/vg.c                 |    1 +
 lib/metadata/vg.h                 |    1 +
 lib/misc/util.h                   |    2 +
 libdm/libdm-file.c                |    6 +-
 liblvm/lvm_pv.c                   |    5 +-
 liblvm/lvm_vg.c                   |    7 +-
 test/dbus/lvmdbustest.py          |    6 +-
 tools/lvconvert.c                 |    7 +-
 tools/pvchange.c                  |    2 +-
 tools/pvcreate.c                  |    2 +-
 tools/pvdisplay.c                 |    2 +-
 tools/pvremove.c                  |    2 +-
 tools/pvscan.c                    |    4 +-
 tools/reporter.c                  |    2 +-
 tools/toollib.c                   |   10 +-
 tools/vgcfgrestore.c              |   10 +-
 tools/vgcreate.c                  |   10 +-
 tools/vgextend.c                  |    2 +-
 tools/vgimportclone.c             |    4 +-
 tools/vgrename.c                  |    6 +-
 tools/vgscan.c                    |    2 +-
 tools/vgsplit.c                   |    6 +
 53 files changed, 1720 insertions(+), 290 deletions(-)


