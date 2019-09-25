From: wangjufeng <wangjufeng@huawei.com>
Date: Wed, 25 Sep 2019 07:48:23 +0000
Subject: stable-2.02 - libdaemon: fix the race of handling SIGTERM timeout
Message-ID: <723608783F175343AAB90DD84928BC3401196923@dggeml510-mbx.china.huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

>From e97d3a14d070a85867ce39fc1749d19c2ac0b685 Mon Sep 17 00:00:00 2001
From: wangjufeng <wangjufeng@huawei.com>
Date: Wed, 25 Sep 2019 15:34:25 +0800
Subject: [PATCH] libdaemon: fix the race of handling SIGTERM timeout

When the daemon service lvmetad running without "-t" option,system
shutdown may take a long time.

error could be simulated follow those steps:
1.remove "-t" option from lvmetad start arguments.
2.start a process p1 like this
                while :
                do
                                time service lvm2-lvmetad stop
                                sleep 2
                                service lvm2-lvmetad start
                done
3.start a process p2 like this
                while :
                do
                                lvs
                done
4.use ctrl+c stop process p2, it is very easy to occur that, stop
lvm2-lvmetad timeout.

This is because, when system shutdown, lvmetad recieve SIGTERM,
_shutdown_requested will change to 1 asynchronously. If a client
thread is still running, s.threads->next is not NULL. It could
happen that (_shutdown_requested && !s.threads->next) will not be
satisfied before calling pselect, then it call pselect and get
blocked . If no new request or signall come, systemd have to
send SIGKILL after SIGTERM timeout, usually it could take 90
seconds.

This patch call _reap(s, 1) to finish all client threads after
_shutdown_requested change to 1. And always pass a timeout
value to pselect to avoid that _shutdown_requested change to 1
between judging _shutdown_requested value and calling pselect.

Signed-off-by: wangjufeng <wangjufeng@huawei.com>
---
libdaemon/server/daemon-server.c | 23 ++++++-----------------
1 file changed, 6 insertions(+), 17 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index bc58f7b..2a7c291 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -87,19 +87,6 @@ static int _is_idle(daemon_state s)
               return s.idle && s.idle->is_idle && !s.threads->next;
}
-static struct timespec *_get_timeout(daemon_state s)
-{
-              return s.idle ? s.idle->ptimeout : NULL;
-}
-
-static void _reset_timeout(daemon_state s)
-{
-              if (s.idle) {
-                              s.idle->ptimeout->tv_sec = 1;
-                              s.idle->ptimeout->tv_nsec = 0;
-              }
-}
-
static unsigned _get_max_timeouts(daemon_state s)
{
               return s.idle ? s.idle->max_timeouts : 0;
@@ -563,7 +550,7 @@ void daemon_start(daemon_state s)
               fd_set in;
               sigset_t new_set, old_set;
               int ret;
-
+             struct timeval select_timeout = { .tv_sec = 1, .tv_usec = 0  };
               /*
                * Switch to C locale to avoid reading large locale-archive file used by
                * some glibc (on some distributions it takes over 100MB). Some daemons
@@ -651,18 +638,20 @@ void daemon_start(daemon_state s)
               sigprocmask(SIG_SETMASK, NULL, &old_set);
                while (!failed) {
-                              _reset_timeout(s);
                               FD_ZERO(&in);
                               FD_SET(s.socket_fd, &in);
                                _reap(s, 0);
                               sigprocmask(SIG_SETMASK, &new_set, NULL);
-                              if (_shutdown_requested && !s.threads->next) {
+                             if (_shutdown_requested) {
+                                             if (s.threads->next) {
+                                                             _reap(s, 1);
+                                             }
                                               sigprocmask(SIG_SETMASK, &old_set, NULL);
                                               INFO(&s, "%s shutdown requested", s.name);
                                               break;
                               }
-                              ret = pselect(s.socket_fd + 1, &in, NULL, NULL, _get_timeout(s), &old_set);
+                             ret = pselect(s.socket_fd + 1, &in, NULL, NULL, &select_timeout, &old_set);
                               sigprocmask(SIG_SETMASK, &old_set, NULL);
                                if (ret < 0) {
--
1.8.3.1
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190925/8b481aa2/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: libdaemon-fix-the-race-of-handling-SIGTERM-timeout.patch
Type: application/octet-stream
Size: 3257 bytes
Desc: libdaemon-fix-the-race-of-handling-SIGTERM-timeout.patch
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190925/8b481aa2/attachment.obj>
