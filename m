From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 18 Sep 2013 00:26:34 +0000 (UTC)
Subject: master - dmsetup: Detect invalid sector supplied to message.
Message-ID: <20130918002634.277B66119B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68f841fcda29ee0af177b0299b52842afcf1bae2
Commit:        68f841fcda29ee0af177b0299b52842afcf1bae2
Parent:        6e912d949b5f68dbf522c4ddb48b93461bdacfdd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 18 01:24:19 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 18 01:24:19 2013 +0100

dmsetup: Detect invalid sector supplied to message.

atoll doesn't check for errors, so invalid sector numbers were silently
accepted in the "dmsetup message" command.

(Mikulas)
---
 WHATS_NEW_DM    |    1 +
 tools/dmsetup.c |    9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 252f105..51c771c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.80 - 
 ==================================
+  Detect invalid sector supplied to 'dmsetup message'.
   Free any previously-set string if a dm_task_set_* function is called again.
   Do not allow passing empty new name for dmsetup rename.
   Display any output returned by 'dmsetup message'.
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 01f49c3..517e8aa 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -771,6 +771,8 @@ static int _message(CMD_ARGS)
 	struct dm_task *dmt;
 	char *str;
 	const char *response;
+	uint64_t sector;
+	char *endptr;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_TARGET_MSG)))
 		return 0;
@@ -785,7 +787,12 @@ static int _message(CMD_ARGS)
 		argv++;
 	}
 
-	if (!dm_task_set_sector(dmt, (uint64_t) atoll(argv[1])))
+	sector = strtoull(argv[1], &endptr, 10);
+	if (*endptr || endptr == argv[1]) {
+		err("invalid sector");
+		goto out;
+	}
+	if (!dm_task_set_sector(dmt, sector))
 		goto out;
 
 	argc -= 2;


