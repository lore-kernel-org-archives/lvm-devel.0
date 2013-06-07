From: dongmao zhang <dmzhang@suse.com>
Date: Fri,  7 Jun 2013 21:52:28 +0800
Subject: [PATCH] if syslog has been opened, do not open it again
Message-ID: <1370613148-10904-1-git-send-email-dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

if log/syslog in /etc/lvm/lvm.conf were set, clvmd log
would be like this:

Jun  8 04:22:42 linux-node02 clvmd[29044]: Cluster ready, doing some
more initialisation
Jun  8 04:22:42 linux-node02 clvmd[29044]: starting LVM thread
Jun  8 04:22:42 linux-node02 lvm[29044]: Sub thread ready for work.
Jun  8 04:22:42 linux-node02 lvm[29044]: LVM thread waiting for work

Having lvm[pid] and clvmd[pid] is confusing. This is because
the ident of syslog was overrided by create_toolcontext->init_syslog.

So if syslog was opened as 'clvmd', it should not be opened as 'lvm'
again. Just use the exsiting global flag _syslog(log.c) to prevent this
---
 lib/log/log.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 06e053f..b0f5061 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -82,8 +82,10 @@ void init_log_while_suspended(int log_while_suspended)
 
 void init_syslog(int facility)
 {
-	openlog("lvm", LOG_PID, facility);
-	_syslog = 1;
+	if (!_syslog) {
+		openlog("lvm", LOG_PID, facility);
+		_syslog = 1;
+	}
 }
 
 int log_suppress(int suppress)
@@ -353,6 +355,7 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 		return;
 	}
 
+
 	if (_log_to_file && (_log_while_suspended || !critical_section())) {
 		fprintf(_log_file, "%s:%d %s%s", file, line, log_command_name(),
 			_msg_prefix);
-- 
1.7.3.4


