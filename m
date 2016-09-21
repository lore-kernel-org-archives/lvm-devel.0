From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 21 Sep 2016 13:55:53 +0000 (UTC)
Subject: master - coverity: dmsetup: fix possible use of uninitialized value
Message-ID: <20160921135553.2437960E5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=926a56578185c7f22c9b3e9c36ff660ce6288c16
Commit:        926a56578185c7f22c9b3e9c36ff660ce6288c16
Parent:        7ea5758c919022e6bca9ebe15aec160fd5ef2430
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 21 15:52:23 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Sep 21 15:52:23 2016 +0200

coverity: dmsetup: fix possible use of uninitialized value

---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 5f4c192..5b817bb 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4956,7 +4956,7 @@ static int _stats_create_file(CMD_ARGS)
 	struct dm_histogram *bounds = NULL;
 	char *path, *abspath = NULL;
 	struct dm_stats *dms = NULL;
-	int group, fd, precise;
+	int group, fd = -1, precise;
 
 	if (_switches[AREAS_ARG] || _switches[AREA_SIZE_ARG]) {
 		log_error("--filemap is incompatible with --areas and --area-size.");


