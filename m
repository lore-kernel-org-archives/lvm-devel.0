From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Sep 2013 11:33:14 +0000 (UTC)
Subject: master - tests: extend harness with output of /var/log/messages
Message-ID: <20130912113314.71C5B60FB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d544004863b3d443fbeca11d264a324275958bd
Commit:        4d544004863b3d443fbeca11d264a324275958bd
Parent:        4dc16684679fb4bb9e8dbc2424e3760055788da2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 12 13:30:12 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 12 13:30:12 2013 +0200

tests: extend harness with output of /var/log/messages

Add a very simple hack for embeding /var/log/messages into
the tests output - it's not ideal since it sometimes breaks lines,
but still gives valuable info.
---
 test/lib/harness.c |   24 ++++++++++++++++++++----
 1 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 415093d..0036502 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -219,7 +219,8 @@ static const char *_append_with_stamp(const char *buf, int stamp)
 	return bb;
 }
 
-static void drain(void) {
+static void drain(int fd)
+{
 	char buf[4096];
 	const char *bp;
 	int stamp = 0;
@@ -228,7 +229,7 @@ static void drain(void) {
 	static int stdout_last = -1, stdout_counter = 0;
 	static int outfile_last = -1, outfile_counter = 0;
 
-	while ((sz = read(fds[1], buf, sizeof(buf) - 1)) > 0) {
+	while ((sz = read(fd, buf, sizeof(buf) - 1)) > 0) {
 		if (fullbuffer)
 			continue;
 		buf[sz] = '\0';
@@ -368,6 +369,8 @@ static void run(int i, char *f) {
 		fd_set set;
 		int runaway = 0;
 		int no_write = 0;
+		FILE *varlogmsg;
+		int fd_vlm = -1;
 
 		snprintf(buf, sizeof(buf), "%s ...", f);
 		printf("Running %-60s ", buf);
@@ -378,6 +381,13 @@ static void run(int i, char *f) {
 		if (!(outfile = fopen(outpath, "w")))
 			perror("fopen");
 
+		/* Mix in kernel log message */
+		if (!(varlogmsg = fopen("/var/log/messages", "r")))
+			perror("fopen");
+		else if (((fd_vlm = fileno(varlogmsg)) >= 0) &&
+			 fseek(varlogmsg, 0L, SEEK_END))
+			perror("fseek");
+
 		while ((w = wait4(pid, &st, WNOHANG, &usage)) == 0) {
 			if ((fullbuffer && fullbuffer++ == 8000) ||
 			    (no_write > 180 * 2)) /* a 3 minute timeout */
@@ -401,14 +411,18 @@ static void run(int i, char *f) {
 				no_write++;
 				continue;
 			}
-			drain();
+			drain(fds[1]);
 			no_write = 0;
+			if (fd_vlm >= 0)
+				drain(fd_vlm);
 		}
 		if (w != pid) {
 			perror("waitpid");
 			exit(206);
 		}
-		drain();
+		drain(fds[1]);
+		if (fd_vlm >= 0)
+			drain(fd_vlm);
 		if (die == 2)
 			interrupted(i, f);
 		else if (runaway) {
@@ -423,6 +437,8 @@ static void run(int i, char *f) {
 		} else
 			failed(i, f, st);
 
+		if (varlogmsg)
+			fclose(varlogmsg);
 		if (outfile)
 			fclose(outfile);
 		if (fullbuffer)


