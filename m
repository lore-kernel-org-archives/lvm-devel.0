From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 24 Oct 2016 16:21:48 +0000 (UTC)
Subject: master - dmsetup: obey --programid when deleting regions
Message-ID: <20161024162149.015EF609D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5eda3934885b23ce06f862a56b524ceaab3cb565
Commit:        5eda3934885b23ce06f862a56b524ceaab3cb565
Parent:        de78e8eae73cb155fdb906ef2b8ddc9ca1a918c4
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Oct 24 17:21:18 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Oct 24 17:21:18 2016 +0100

dmsetup: obey --programid when deleting regions

---
 tools/dmsetup.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 9d357ec..ec64d24 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5278,6 +5278,8 @@ static int _stats_delete(CMD_ARGS)
 		name = argv[0];
 	}
 
+	if (_switches[PROGRAM_ID_ARG])
+		program_id = _string_args[PROGRAM_ID_ARG];
 	if (_switches[ALL_PROGRAMS_ARG])
 		program_id = DM_STATS_ALL_PROGRAMS;
 


