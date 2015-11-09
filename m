From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:29:06 +0000 (UTC)
Subject: master - cleanup: drop unneeded assign
Message-ID: <20151109092906.5D4B360F92@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c4c5635870c7273e61a0832431d264b8cf11a62f
Commit:        c4c5635870c7273e61a0832431d264b8cf11a62f
Parent:        e262d5e596202498c5b0d773cd54c1b2ecdb4f94
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 7 20:41:15 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:52 2015 +0100

cleanup: drop unneeded assign

prio is always assigned later.
---
 daemons/dmeventd/libdevmapper-event.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 85eab5a..359dfdd 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -838,7 +838,7 @@ void dm_event_log(const char *subsys, int level, const char *file,
 	static time_t start = 0;
 	const char *indent = "";
 	FILE *stream = stdout;
-	int prio = -1;
+	int prio;
 	time_t now;
 
 	switch (level & ~(_LOG_STDERR | _LOG_ONCE)) {


