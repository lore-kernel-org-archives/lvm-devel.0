From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:12 +0000 (UTC)
Subject: dev-mornfall-activate - dmeventd: always return success on dmevetnd -V
Message-ID: <20130604192712.EB70060FAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ad17fd7129dc7f50c0623181681157faea806a1
Commit:        6ad17fd7129dc7f50c0623181681157faea806a1
Parent:        be25f7ac83bcf0f910a6213d4c1d195fbdd0d45d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 29 12:54:42 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed May 29 12:54:42 2013 +0200

dmeventd: always return success on dmevetnd -V

---
 daemons/dmeventd/dmeventd.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 95fb837..4710910 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1928,10 +1928,10 @@ int main(int argc, char *argv[])
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
-			exit(0);
+			exit(EXIT_SUCCESS);
 		case '?':
 			usage(argv[0], stderr);
-			exit(0);
+			exit(EXIT_SUCCESS);
 		case 'R':
 			_restart++;
 			break;
@@ -1943,7 +1943,7 @@ int main(int argc, char *argv[])
 			break;
 		case 'V':
 			printf("dmeventd version: %s\n", DM_LIB_VERSION);
-			exit(1);
+			exit(EXIT_SUCCESS);
 		}
 	}
 


