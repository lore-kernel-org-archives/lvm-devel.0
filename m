From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:48:58 +0000 (UTC)
Subject: master - cleanup: add braces for if()
Message-ID: <20140702084858.B47EC60BAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1dcbe085370ba194b6598bb9440550edb7f184f
Commit:        d1dcbe085370ba194b6598bb9440550edb7f184f
Parent:        52ab15b2d0803fee480c404a458f3b568507a53a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 2 10:28:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:45:43 2014 +0200

cleanup: add braces for if()

---
 libdm/regex/parse_rx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/regex/parse_rx.c b/libdm/regex/parse_rx.c
index 0ad033a..bc0e619 100644
--- a/libdm/regex/parse_rx.c
+++ b/libdm/regex/parse_rx.c
@@ -67,7 +67,7 @@ static void _regex_print(struct rx_node *rx, int depth, unsigned show_nodes)
 			printf("[");
 		for (i = 0; i < 256; i++)
 			if (dm_bit(rx->charset, i)) {
-				if isprint(i)
+				if (isprint(i))
 					printf("%c", (char) i);
 				else if (i == HAT_CHAR)
 					printf("^");


