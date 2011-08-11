From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 11 Aug 2011 12:34:39 +0200
Subject: [PATCH] Suppress locking error messages in monitoring initscripts
Message-ID: <4E43B03F.1050606@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We already use --sysinit to disable these messages when using
"vgchange -ay" in rc.sysinit stage. However, there's also a
"vgchange --monitor y" call later, but this is still too early
to expect all locks to have the infrastructure in place (like
using cluster locking globally in lvm.conf, but monitoring starts
much earlier than cluster infrastructure, so we'd always end with
a scary error message at boot).

The user should not see these messages about socket failures and
fallback to another type of locking, at least not at this moment.
It's misleading - this is actually not a real problem at all, but
the messages look like something terrible is happening.

Peter

---

 lib/locking/locking.c                              |    2 +-
 scripts/lvm2_monitoring_init_red_hat.in            |    1 +
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    1 +
 3 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 8d709f6..a234ed9 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -221,7 +221,7 @@ static void _update_vg_lock_count(const char *resource, uint32_t flags)
  */
 int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 {
-	if (ignorelockingfailure() && getenv("LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES"))
+	if (getenv("LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES"))
 		suppress_messages = 1;
 
 	if (type < 0)
diff --git a/scripts/lvm2_monitoring_init_red_hat.in b/scripts/lvm2_monitoring_init_red_hat.in
index 4812c75..0988511 100644
--- a/scripts/lvm2_monitoring_init_red_hat.in
+++ b/scripts/lvm2_monitoring_init_red_hat.in
@@ -42,6 +42,7 @@ VGS=${sbindir}/vgs
 LOCK_FILE="/var/lock/subsys/$DAEMON"
 
 WARN=1
+export LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1
 
 start()
 {
diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index 4715416..b5dd9bb 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -8,6 +8,7 @@ Conflicts=shutdown.target
 
 [Service]
 Type=oneshot
+Environment=LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1
 ExecStart=@sbindir@/lvm vgchange --monitor y
 ExecStop=@sbindir@/lvm vgchange --monitor n
 RemainAfterExit=yes


