From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 3 May 2017 06:30:06 -0400
Subject: master - command: avoid compiler warning
Message-ID: <201705031030.v43AU6HL017416@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a0f742542f5762c4c80e52eab31819ea5abdb94b
Commit:        a0f742542f5762c4c80e52eab31819ea5abdb94b
Parent:        e15c7c5ff963e1a0287f25bca401bc3dbe515f76
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed May 3 11:19:43 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed May 3 11:19:43 2017 +0100

command: avoid compiler warning

man-generator.c:3243: warning: declaration of ???stat??? shadows a global
declaration
---
 tools/command.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 347475b..0f69bbb 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3240,29 +3240,29 @@ static int include_description_file(char *name, char *des_file)
 	char *buf;
 	int fd, r = 0;
 	ssize_t sz;
-	struct stat stat;
+	struct stat statbuf;
 
 	if ((fd = open(des_file, O_RDONLY)) < 0) {
 		log_error("Failed to open description file %s.", des_file);
 		return 0;
 	}
 
-	if (fstat(fd, &stat) < 0) {
+	if (fstat(fd, &statbuf) < 0) {
 		log_error("Failed to stat description file %s.", des_file);
 		goto out_close;
 	}
 
-	if (stat.st_size > MAX_MAN_DESC) {
+	if (statbuf.st_size > MAX_MAN_DESC) {
 		log_error("Description file %s is too large.", des_file);
 		goto out_close;
 	}
 
-	if (!(buf = dm_malloc(stat.st_size + 1))) {
+	if (!(buf = dm_malloc(statbuf.st_size + 1))) {
 		log_error("Failed to allocate buffer for description file %s.", des_file);
 		goto out_close;
 	}
 
-	if ((sz = read(fd, buf, stat.st_size)) < 0) {
+	if ((sz = read(fd, buf, statbuf.st_size)) < 0) {
 		log_error("Failed to read description file %s.", des_file);
 		goto out_free;
 	}


