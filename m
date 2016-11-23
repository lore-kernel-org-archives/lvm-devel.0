From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:55:54 +0000 (UTC)
Subject: master - cleanup: hide gcc warning
Message-ID: <20161123165554.D53C960F9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc3895623c43dbbd6976f3c988e4ad26ad9ac9c8
Commit:        cc3895623c43dbbd6976f3c988e4ad26ad9ac9c8
Parent:        8a4dfe6ce7f44e2996e48fa0dd7dfd98680cae86
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 16 15:13:36 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:55:03 2016 +0100

cleanup: hide gcc warning

---
 libdm/regex/parse_rx.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/libdm/regex/parse_rx.c b/libdm/regex/parse_rx.c
index f9ba65c..80e97a4 100644
--- a/libdm/regex/parse_rx.c
+++ b/libdm/regex/parse_rx.c
@@ -19,6 +19,7 @@
 #ifdef DEBUG
 #include <ctype.h>
 
+__attribute__ ((__unused__))
 static void _regex_print(struct rx_node *rx, int depth, unsigned show_nodes)
 {
 	int i, numchars;


