From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  9 Jun 2015 17:46:08 +0000 (UTC)
Subject: master - Add support for raid0/raid0_meta raid types
Message-ID: <20150609174608.891E761260@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b46743be20680b252ce4291d707905db5a4df5dc
Commit:        b46743be20680b252ce4291d707905db5a4df5dc
Parent:        fd29c7f3a171174dcd47eb8b23ff42a145cdacc6 cb5156ce1f909abfde91e51a46b95eaca45f46ce
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jun 9 19:45:10 2015 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jun 9 19:45:10 2015 +0200

Add support for raid0/raid0_meta raid types

Supports creation of raid types raid0 and raid0_meta
with 'lvcreate --type (raid0|raid0_meta) ...' based on
functionality available in dm-raid target version 1.0.7

The raid0 type provides access via the MD raid0
personality without metadata devices

The raid0_meta type provides access via the MD raid0
personality _with_ metadata devices, i.e. it reserves
space for rmeta devices which is e.g. useful for future
functional enhancements supporting conversions between
raid0 and raid4/5/6/10 to ensure metadata space
on raid0_meta creation.

Conversion between striped/raid0/raid0_meta
LVs with striped LVs being restricted to one
stripe zone (i.e. no varying stripes) is possible
with 'lvconvert --type (striped|raid0|raid0_meta) ...'

lvconvert-striped-raid0.sh provides various tests"

 WHATS_NEW                        |    1 +
 lib/activate/dev_manager.c       |   14 +-
 lib/config/defaults.h            |    2 +
 lib/format_text/export.c         |    6 +-
 lib/metadata/lv.c                |    1 +
 lib/metadata/lv.h                |    4 +-
 lib/metadata/lv_manip.c          |  362 ++++++----
 lib/metadata/merge.c             |    2 +-
 lib/metadata/metadata-exported.h |   12 +-
 lib/metadata/raid_manip.c        | 1483 +++++++++++++++++++++++++++++++-------
 lib/metadata/segtype.h           |  133 +++-
 lib/raid/raid.c                  |  213 +++---
 lib/uuid/uuid.c                  |    2 +-
 libdm/libdm-deptree.c            |   70 ++-
 tools/lvchange.c                 |    2 +-
 tools/lvconvert.c                |   60 +-
 tools/lvcreate.c                 |   75 ++-
 17 files changed, 1834 insertions(+), 608 deletions(-)


