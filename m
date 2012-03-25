From: Milan Broz <mbroz@redhat.com>
Date: Sun, 25 Mar 2012 22:56:02 +0200
Subject: [PATCH 0/4] pvmove cluster fixes
Message-ID: <cover.1332708600.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Various locking changes in previous releases, mainly commit

commit bd86888d7406cdb8ba20ff3d3b807fabcc7ba0db
    Pass exclusive LV locks to all nodes in the cluster.
    This was the intended behaviour, as described in the lvchange man page, so you
    have complete control through volume_list in lvm.conf, but the code seems to
    have been treating -ae as local-only for a very long time.

caused pvmove to stopped working if an LV is activated exclusively.

Milan

Milan Broz (4):
  Remove unused and wrongly set cluster VG flag from clvmd lock query
    command.
  Use new flag PVMOVE_EXCLUSIVE in update_metatada call.
  Do not allow pvmove if some affected LVs are activated locally     or
    on more nodes while others are activated exclusively.
  Keep exclusive activation in pvmove if LV is already active.

 WHATS_NEW                     |    3 ++
 lib/locking/cluster_locking.c |    2 +-
 lib/locking/locking.c         |    2 +-
 tools/pvmove.c                |   44 +++++++++++++++++++++++++++++++++-------
 4 files changed, 41 insertions(+), 10 deletions(-)

-- 
1.7.9.1


