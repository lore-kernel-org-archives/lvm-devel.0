From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:51 +0200
Subject: [PATCH 05/14] Testsuit: speedup
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <3e5e833c49ae138f10ec68dfb393fbf661499eca.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Instead of waiting for flock end kill lock.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/t-lock-blocking.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/t-lock-blocking.sh b/test/t-lock-blocking.sh
index 7e5321e..166340c 100644
--- a/test/t-lock-blocking.sh
+++ b/test/t-lock-blocking.sh
@@ -33,4 +33,4 @@ flock -w 5 $TESTDIR/var/lock/lvm/P_orphans -c "sleep 10" &
 flock_pid=`jobs -p`
 not vgremove --config 'global { wait_for_locks = 0 }' $vg
 ps $flock_pid # still running
-wait $flock_pid
+kill $flock_pid
-- 
1.7.2


