From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 05:52:47 +0000 (UTC)
Subject: master - libdaemon-server: Fix a memory leak in daemon_log_multi.
Message-ID: <20121009055247.E8379241E@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc9c02fe68f6ee8f5f6bcf885c1ed41387778bb7
Commit:        cc9c02fe68f6ee8f5f6bcf885c1ed41387778bb7
Parent:        7a64fff948278604d287ac96d9783a6b896de99b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 8 17:11:43 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 8 20:35:29 2012 +0200

libdaemon-server: Fix a memory leak in daemon_log_multi.

---
 libdaemon/server/daemon-log.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index b18e70c..837fffd 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -98,6 +98,7 @@ void daemon_log_multi(log_state *s, int type, const char *prefix, const char *ms
 		_log_line(pos, &b);
 		pos = next ? next + 1 : 0;
 	}
+	dm_free(buf);
 }
 
 void daemon_log_enable(log_state *s, int outlet, int type, int enable)


