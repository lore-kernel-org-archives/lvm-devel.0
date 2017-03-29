From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 29 Mar 2017 18:44:49 -0400
Subject: master - man-generator: catch missing command name
Message-ID: <201703292244.v2TMinMp016503@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2f1fd1584efc46e69453a38788ad22470f73698a
Commit:        2f1fd1584efc46e69453a38788ad22470f73698a
Parent:        df86ee8c2198abfbc8429813614636511be66402
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 30 00:39:26 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 30 00:44:34 2017 +0200

man-generator: catch missing command name

---
 tools/command.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 8a739f0..9a80812 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3439,6 +3439,10 @@ int main(int argc, char *argv[])
 
 	if (optind < argc)
 		cmdname = strdup(argv[optind++]);
+	else {
+		log_error("Missing command name");
+		exit(EXIT_FAILURE);
+	}
 
 	if (optind < argc)
 		desfile = argv[optind++];


