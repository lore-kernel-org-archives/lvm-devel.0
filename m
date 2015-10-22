From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:52 +0000 (UTC)
Subject: master - dmeventd: drop unneded test
Message-ID: <20151022213352.0D5056057E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2ea2a81476495f494915774c46c0b3c139d1c3f
Commit:        e2ea2a81476495f494915774c46c0b3c139d1c3f
Parent:        941c6354dbf783da17851be7e38f243334a4acd6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 12:31:45 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:34:29 2015 +0200

dmeventd: drop unneded test

Function is never called without device.uuid.
---
 daemons/dmeventd/dmeventd.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index bbdee82..2f5fe67 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -545,9 +545,6 @@ static int _fill_device_data(struct thread_status *ts)
 	struct dm_info dmi;
 	int ret = 0;
 
-	if (!ts->device.uuid)
-		return 0;
-
 	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
 		return 0;
 


