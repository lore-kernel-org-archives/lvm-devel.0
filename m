From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:35:51 +0100
Subject: [PATCH 0/6] Code cleanups unrelated to replicator
Message-ID: <cover.1263389392.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac (6):
  Do not create generate lvol%d name
  Intialize cmd in the struct alloc_handle
  Cleanup compiler warning with passing NULL to execvp
  Cleanup compiler pointer cast warning
  Cleanup const compiler warning in devmapper
  Cleanup const compiler warning in _comp_area

 daemons/dmeventd/libdevmapper-event.c |    4 +++-
 lib/metadata/lv_manip.c               |   22 +++++-----------------
 libdm/libdevmapper.h                  |   18 +++++++++---------
 libdm/libdm-deptree.c                 |   22 +++++++++++-----------
 tools/dmsetup.c                       |   10 ++++++----
 5 files changed, 34 insertions(+), 42 deletions(-)


