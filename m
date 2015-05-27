From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 27 May 2015 09:11:45 +0000 (UTC)
Subject: master - lvmpolld: terminate error message with a dot and LF
Message-ID: <20150527091145.D7C556118E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1aba262edb7f0bfac897223868779053f4921ff9
Commit:        1aba262edb7f0bfac897223868779053f4921ff9
Parent:        f0268585dd962a7b0393160c042fefb72c64701c
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed May 27 08:24:36 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 27 11:10:43 2015 +0200

lvmpolld: terminate error message with a dot and LF

---
 daemons/lvmpolld/lvmpolld-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index c1d583e..c5b22d7 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -957,7 +957,7 @@ int main(int argc, char *argv[])
 			break;
 		case 't': /* --timeout in seconds */
 			if (!process_timeout_arg(optarg, &di.max_timeouts)) {
-				fprintf(stderr, "Invalid value of timeout parameter");
+				fprintf(stderr, "Invalid value of timeout parameter.\n");
 				exit(EXIT_FAILURE);
 			}
 			/* 0 equals to wait indefinitely */


