From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 22 Apr 2013 11:08:29 +0200
Subject: [PATCH 0/2] Cluster snapshot fixes
Message-ID: <cover.1366621483.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Small patch series tries to address problem with snapshot in cluster.
1st. patch is fixing the problem of incorrect MDA caching in clvmd.
2nd. is 'possibly' correcting exclusive locking of COW volume.

Zdenek Kabelac (2):
  clvmd: avoid precheck of dev existance
  snapshot: rework creation and removal of snapshots

 daemons/clvmd/lvm-functions.c |  7 +------
 lib/metadata/lv_manip.c       | 15 +++++----------
 lib/metadata/snapshot_manip.c | 33 ++++++++++++++++++++++++---------
 3 files changed, 30 insertions(+), 25 deletions(-)

-- 
1.8.2


