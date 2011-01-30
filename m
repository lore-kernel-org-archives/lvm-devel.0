From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:45 +0100
Subject: [PATCH 22/24] Testing: Try to prioritize locking process
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <0a0fb7e4fc3a29f9e67432a17d9710b44cfa1d63.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is rather 'hotfix' - it will run  lvm command with lower
prioritu - thus flock process should exit sooner before it's
checked by 'ps' for it's existance.

Think about better way how to test this.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/t-lock-blocking.sh |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/t-lock-blocking.sh b/test/t-lock-blocking.sh
index e3ec63c..3e6985b 100644
--- a/test/t-lock-blocking.sh
+++ b/test/t-lock-blocking.sh
@@ -20,17 +20,17 @@ vgcreate $vg $dev1 $dev2
 
 # if wait_for_locks set, vgremove should wait for orphan lock
 # flock process should have exited by the time first vgremove completes
-flock -w 5 $TESTDIR/var/lock/lvm/P_orphans -c "sleep 10" &
+flock -w 4 $TESTDIR/var/lock/lvm/P_orphans -c "sleep 6" &
 flock_pid=`jobs -p`
-vgremove --config 'global { wait_for_locks = 1 }' $vg
-not vgremove --config 'global { wait_for_locks = 1 }' $vg
+nice vgremove -vvvv --config 'global { wait_for_locks = 1 }' $vg
+nice not vgremove -vvvv --config 'global { wait_for_locks = 1 }' $vg
 not ps $flock_pid # finished
 
 # if wait_for_locks not set, vgremove should fail on non-blocking lock
 # we must wait for flock process at the end - vgremove won't wait
 vgcreate $vg $dev1 $dev2
-flock -w 5 $TESTDIR/var/lock/lvm/P_orphans -c "sleep 10" &
+flock -w 4 $TESTDIR/var/lock/lvm/P_orphans -c "sleep 6" &
 flock_pid=`jobs -p`
-not vgremove --config 'global { wait_for_locks = 0 }' $vg
+nice not vgremove --config 'global { wait_for_locks = 0 }' $vg
 ps $flock_pid # still running
 kill $flock_pid
-- 
1.7.3.5


