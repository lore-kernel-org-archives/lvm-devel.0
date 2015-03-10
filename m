From: okozina <okozina@fedoraproject.org>
Date: Tue, 10 Mar 2015 13:41:46 +0000 (UTC)
Subject: master - libdaemon: map error level properly
Message-ID: <20150310134146.29127602F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5dbcbbea58508854904dafe054945ea48baa1642
Commit:        5dbcbbea58508854904dafe054945ea48baa1642
Parent:        0982c5c79f3467bcff1d64ac12cb30b25d446a5a
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Mar 10 14:35:29 2015 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Mar 10 14:42:40 2015 +0100

libdaemon: map error level properly

internal daemon error log level was wrongly mapped to debug syslog
level causing most error messages were lost in non-debug mode.
---
 libdaemon/server/daemon-log.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index 91900af..87ad547 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -20,6 +20,7 @@ static void log_syslog(log_state *s, void **state, int type, const char *message
 	switch (type) {
 	case DAEMON_LOG_INFO: prio = LOG_INFO; break;
 	case DAEMON_LOG_WARN: prio = LOG_WARNING; break;
+	case DAEMON_LOG_ERROR: prio = LOG_ERR; break;
 	case DAEMON_LOG_FATAL: prio = LOG_CRIT; break;
 	default: prio = LOG_DEBUG; break;
 	}


