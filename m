From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:37 +0000 (GMT)
Subject: main - dmsetup: fix measure handling
Message-ID: <20210927165737.6CC463858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a3352f08f687e1db4bb20a2f1b1c52bb888b9d97
Commit:        a3352f08f687e1db4bb20a2f1b1c52bb888b9d97
Parent:        e62a71f3dd97795ea64b2f3948dd8629c2dac8b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 27 18:26:35 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:45:25 2021 +0200

dmsetup: fix measure handling

Previous patch f853a1bc7afdebb44aeb8c1167e8784d155cad84 enabled
ima measurement unconditionally for every status call,
but it needs to be set only for 'dmsetup measure' command.
---
 libdm/dm-tools/dmsetup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 4641c1f18..07b6cca8a 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -2446,7 +2446,8 @@ static int _status(CMD_ARGS)
 	if (_switches[NOFLUSH_ARG] && !dm_task_no_flush(dmt))
 		goto_out;
 
-	if (!dm_task_ima_measurement(dmt))
+	if (!strcmp(cmd->name, "measure") &&
+	    !dm_task_ima_measurement(dmt))
 		goto_out;
 
 	if (!_task_run(dmt))


