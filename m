From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:42 +0000 (UTC)
Subject: master - lvmpolld: don't return success on invalid option
Message-ID: <20150515183742.11F8F6100F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4317c040635a67c62df95bd102e03575d49f09d
Commit:        d4317c040635a67c62df95bd102e03575d49f09d
Parent:        d34de2d91270a1f3cd427e1dab4a6df8789de7e5
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri May 15 19:28:23 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:33:40 2015 +0200

lvmpolld: don't return success on invalid option

---
 daemons/lvmpolld/lvmpolld-core.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index a141d77..1a33625 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -914,7 +914,7 @@ int main(int argc, char *argv[])
 		.socket_path = getenv("LVM_LVMPOLLD_SOCKET") ?: LVMPOLLD_SOCKET,
 	};
 
-	while ((opt = getopt_long(argc, argv, "?fhVl:p:s:B:t:", long_options, &option_index)) != -1) {
+	while ((opt = getopt_long(argc, argv, "fhVl:p:s:B:t:", long_options, &option_index)) != -1) {
 		switch (opt) {
 		case 0 :
 			if (action < ACTION_MAX) {
@@ -928,7 +928,7 @@ int main(int argc, char *argv[])
 			break;
 		case '?':
 			_usage(argv[0], stderr);
-			exit(EXIT_SUCCESS);
+			exit(EXIT_FAILURE);
 		case 'B': /* --binary */
 			ls.lvm_binary = optarg;
 			server = 1;


