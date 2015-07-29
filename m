From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 29 Jul 2015 11:16:48 +0000 (UTC)
Subject: master - dmsetup: remove dead code that covered "info -c -o help" case once
Message-ID: <20150729111648.D843360559@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca0d9a70d15ca44c1d0d6f65a277c5e2ac7dd161
Commit:        ca0d9a70d15ca44c1d0d6f65a277c5e2ac7dd161
Parent:        cf700151eba483aeedbf790fd66ce1c44e19c707
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 29 13:10:31 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 29 13:16:09 2015 +0200

dmsetup: remove dead code that covered "info -c -o help" case once

The "-o help" is now handled as implicit field and it gets processed
just like any other field - all handled by libdevmapper now.
---
 tools/dmsetup.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index e6cc44f..7a26db1 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3857,15 +3857,8 @@ unknown:
 		goto out;
 	}
 
-	if (_switches[COLS_ARG]) {
-		if (!_report_init(cmd))
-			goto out;
-		if (!_report) {
-			if (!strcmp(cmd->name, "info"))
-				r = 0;  /* info -c -o help */
-			goto out;
-		}
-	}
+	if (_switches[COLS_ARG] && !_report_init(cmd))
+		goto out;
 
 	#ifdef UDEV_SYNC_SUPPORT
 	if (!_set_up_udev_support(dev_dir))


