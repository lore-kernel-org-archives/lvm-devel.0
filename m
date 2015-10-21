From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 21 Oct 2015 16:23:06 +0000 (UTC)
Subject: master - libdaemon: fix typo in last log enable commit
Message-ID: <20151021162306.42FAF60FFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0d819172fde16913347e5c0984dc4d67ae6befe
Commit:        a0d819172fde16913347e5c0984dc4d67ae6befe
Parent:        0aee04288e221de91de022d84d19424d4698a05c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 21 11:22:22 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 21 11:22:22 2015 -0500

libdaemon: fix typo in last log enable commit

---
 libdaemon/server/daemon-log.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index abe602b..2bebf41 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -166,7 +166,7 @@ static int _parse_one(log_state *s, int outlet, const char *type, int enable)
 		daemon_log_enable(s, outlet, DAEMON_LOG_ERROR, enable);
 	else if (!strcmp(type, "warn"))
 		daemon_log_enable(s, outlet, DAEMON_LOG_WARN, enable);
-	else if (!strcmp(type, "warn"))
+	else if (!strcmp(type, "info"))
 		daemon_log_enable(s, outlet, DAEMON_LOG_INFO, enable);
 	else if (!strcmp(type, "wire"))
 		daemon_log_enable(s, outlet, DAEMON_LOG_WIRE, enable);


