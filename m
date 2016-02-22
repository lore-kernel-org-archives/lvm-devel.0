From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Feb 2016 20:15:22 +0000 (UTC)
Subject: master - tests: fix clean up after lvmlockd tests
Message-ID: <20160222201522.2771C61BFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f4efc2435c29b3bf4375c17937d0d2ab2294e00e
Commit:        f4efc2435c29b3bf4375c17937d0d2ab2294e00e
Parent:        ec81c421793e63373cf6e119fe4bfd60368ee47d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 22 14:13:30 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 22 14:15:17 2016 -0600

tests: fix clean up after lvmlockd tests

---
 test/shell/zz-lvmlockd-dlm-remove.sh     |    7 ++++++-
 test/shell/zz-lvmlockd-sanlock-remove.sh |    5 ++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/test/shell/zz-lvmlockd-dlm-remove.sh b/test/shell/zz-lvmlockd-dlm-remove.sh
index 3848c0e..0526314 100644
--- a/test/shell/zz-lvmlockd-dlm-remove.sh
+++ b/test/shell/zz-lvmlockd-dlm-remove.sh
@@ -19,6 +19,11 @@ test_description='Remove the dlm test setup'
 # lvmlockctl -d > lvmlockd-debug.txt
 # dlm_tool dump > dlm-debug.txt
 
+lvmlockctl --stop-lockspaces
+sleep 1
+killall lvmlockd
+sleep 1
+killall lvmlockd || true
+sleep 1
 systemctl stop dlm
 systemctl stop corosync
-killall lvmlockd
diff --git a/test/shell/zz-lvmlockd-sanlock-remove.sh b/test/shell/zz-lvmlockd-sanlock-remove.sh
index ae5bdef..b01952a 100644
--- a/test/shell/zz-lvmlockd-sanlock-remove.sh
+++ b/test/shell/zz-lvmlockd-sanlock-remove.sh
@@ -26,11 +26,14 @@ vgremove --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_
 # lvmlockctl -d > lvmlockd-debug.txt
 # sanlock log_dump > sanlock-debug.txt
 
+lvmlockctl --stop-lockspaces
+sleep 1
 killall lvmlockd
 sleep 1
+killall lvmlockd || true
+sleep 1
 killall sanlock
 sleep 1
-
 killall -9 lvmlockd || true
 killall -9 sanlock || true
 


