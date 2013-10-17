From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 17 Oct 2013 08:17:22 +0000 (UTC)
Subject: master - coverity: sscanf should use "%u" instead of "%i"
Message-ID: <20131017081722.DB5FF6174A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3924a041ba3798c228749de1fc5491fd5411103b
Commit:        3924a041ba3798c228749de1fc5491fd5411103b
Parent:        9b13cb86878677e2b35e29fef054d9de7e24f320
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 17 10:11:53 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 17 10:17:16 2013 +0200

coverity: sscanf should use "%u" instead of "%i"

The "age" variable is unsigned:

  unsigned age = 0;
  ...
  if (argc == 2 && (sscanf(argv[1], "%i", &age) != 1))
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 517e8aa..a0ee23e 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1147,7 +1147,7 @@ static int _udevcomplete_all(CMD_ARGS)
 	unsigned age = 0;
 	time_t t;
 
-	if (argc == 2 && (sscanf(argv[1], "%i", &age) != 1)) {
+	if (argc == 2 && (sscanf(argv[1], "%u", &age) != 1)) {
 		log_error("Failed to read age_in_minutes parameter.");
 		return 0;
 	}


