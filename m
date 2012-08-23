From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:19 +0000 (UTC)
Subject: master - dmsetup: check if new_name is non NULL
Message-ID: <20120823124219.461E9A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b1640df5e6375926df0cc0e8dab217b21b23ce57
Commit:        b1640df5e6375926df0cc0e8dab217b21b23ce57
Parent:        b9ae22d758e6b5eed62774f5b2a71b87d818087e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 27 01:19:23 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:18 2012 +0200

dmsetup: check if new_name is non NULL

---
 WHATS_NEW_DM    |    1 +
 tools/dmsetup.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 186a2e1..d0e8f7d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.77 -
 =================================
+  Check for existing new_name for dmsetup rename.
   Fix memory leak in dmsetup _get_split_name() error path.
 
 Version 1.02.76 - 7th August 2012
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index ca1087d..7d1f2a1 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -719,7 +719,7 @@ static int _do_rename(const char *name, const char *new_name, const char *new_uu
 	if (new_uuid) {
 		if (!dm_task_set_newuuid(dmt, new_uuid))
 			goto out;
-	} else if (!dm_task_set_newname(dmt, new_name))
+	} else if (!new_name || !dm_task_set_newname(dmt, new_name))
 		goto out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))


