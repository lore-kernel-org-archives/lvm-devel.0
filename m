From: Milan Broz <mbroz@redhat.com>
Date: Tue,  8 Dec 2009 16:38:43 +0100
Subject: [PATCH 00/10] Fixes related to mirror repair in clustered environment
Message-ID: <cover.1260284754.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These are patches I created when trying to reproduce fails with
recent mirror repair changes.

Because it touch the core cluster locking parts, I separated it
to several simple patches to review it separately.

Please review and comment it - it is curretnly test blocker for clustering.

(If there is better way how to fix described problems - please let me know,
I am quite desperate after debugging this code ;-)

Milan


Milan Broz (10):
  Remove newly created log volume if initial deactivation fails.
  Get rid of hardcoded 0xffdf cluster lock flag.
  Get rid of magic masks in cluster locking code.
  Get rid of magic masks in cluster locking code - clvmd part.
  Allow implicit "convert" to the same lock mode.
  Allow manipulation with precommited metadata even when a PV is
    missing.
  Call explicitly suspend for temporary mirror layer.
  Allow implicit lock conversion for pre/post callbacks.
  Never ever use distributed lock for LV in non-clustered VG.
  Add memlock information to do_lock_lv debug output.

 daemons/clvmd/clvmd-command.c |   10 ++++----
 daemons/clvmd/lvm-functions.c |   38 +++++++++++++++++++++---------------
 lib/locking/cluster_locking.c |    7 +++--
 lib/locking/locking.h         |    3 ++
 lib/metadata/metadata.c       |    4 +-
 lib/metadata/mirror.c         |   42 +++++++++++++++++++++-------------------
 6 files changed, 58 insertions(+), 46 deletions(-)


