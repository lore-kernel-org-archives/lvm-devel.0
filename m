From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  4 Sep 2013 14:21:22 +0000 (UTC)
Subject: master - test: Include tests that timed out in the final summary.
Message-ID: <20130904142122.08DB460E71@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=374653f2b55fe06431e4db4ef8e3d4340cdab29b
Commit:        374653f2b55fe06431e4db4ef8e3d4340cdab29b
Parent:        cc66dedc0ebe9a7f7718d6340ccd6247d1a471e1
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 4 16:20:35 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 4 16:21:08 2013 +0200

test: Include tests that timed out in the final summary.

---
 test/lib/harness.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 52fa62f..53814dc 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -520,6 +520,9 @@ int main(int argc, char **argv) {
 			case INTERRUPTED:
 				printf("interrupted: %s\n", argv[i]);
 				break;
+			case TIMEOUT:
+				printf("timeout: %s\n", argv[i]);
+				break;
 			default: /* do nothing */ ;
 			}
 		}


