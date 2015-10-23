From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 Oct 2015 08:55:13 +0000 (UTC)
Subject: master - cleanup: fix gcc compile with older pthread
Message-ID: <20151023085513.5A07A6100C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b5b2a5483450dff10fd23a7b712649729e619b0d
Commit:        b5b2a5483450dff10fd23a7b712649729e619b0d
Parent:        21748a86309443ddaefe1fcc0644f0b9a6ea138e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 23 09:44:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 23 10:54:13 2015 +0200

cleanup: fix gcc compile with older pthread

Older pthread library was missing 'trick'
in pthread_cleanup_pop() which lead to
compilation error:

error: label at end of compound statement

Use explicit ';' to fix it.
---
 daemons/dmeventd/dmeventd.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 949fcf4..b5f1be3 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1029,6 +1029,9 @@ static void *_monitor_thread(void *arg)
 		}
 	}
 out:
+	/* ';' fixes gcc compilation problem with older pthread macros
+	 * "label at end of compound statement" */
+	;
 
 	pthread_cleanup_pop(1);
 


