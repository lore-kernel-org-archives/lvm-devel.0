From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 Oct 2015 08:55:07 +0000 (UTC)
Subject: master - dmeventd: ensure filter is empty
Message-ID: <20151023085507.0DD1A610F9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87a39d8bac572b67f927dad41548155606a50f4f
Commit:        87a39d8bac572b67f927dad41548155606a50f4f
Parent:        cff1c728d8c80b3393c461f6229066f633b67fc2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 23 09:43:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 23 10:54:13 2015 +0200

dmeventd: ensure filter is empty

On some error path we could have left filter set to some value.
Not a big issue - but lets make reporting correct as soon
as we can.
---
 daemons/dmeventd/dmeventd.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index af03091..949fcf4 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -936,6 +936,7 @@ static void _monitor_unregister(void *arg)
 			break;
 		}
 
+	thread->events = 0;	/* Filter is now empty */
 	thread->pending = 0;	/* Event pending resolved */
 	thread->processing = 1;	/* Process unregistering */
 


