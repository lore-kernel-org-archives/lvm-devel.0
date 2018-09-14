From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 14 Sep 2018 10:57:49 -0400
Subject: master - libdm: fix buffer overflow
Message-ID: <201809141457.w8EEvnsq024363@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fdb6ef8a85e9adc4805202b3200b17bd3b351982
Commit:        fdb6ef8a85e9adc4805202b3200b17bd3b351982
Parent:        0c00af776a27875ee5ffbf3ab2d3b73495ce8c52
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jun 21 10:20:09 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Sep 14 16:57:22 2018 +0200

libdm: fix buffer overflow

(cherry picked from commit 8a0af1bec882de66677e1a0cdceff841c39f92b0)
---
 libdm/libdm-common.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 7c740d8..5099f91 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1763,7 +1763,7 @@ static int _mountinfo_parse_line(const char *line, unsigned *maj, unsigned *min,
 			return 0;
 		}
 		devmapper += 12; /* skip fixed prefix */
-		for (i = 0; devmapper[i] && devmapper[i] != ' ' && i < sizeof(root); ++i)
+		for (i = 0; devmapper[i] && devmapper[i] != ' ' && i < sizeof(root)-1; ++i)
 			root[i] = devmapper[i];
 		root[i] = 0;
 		_unmangle_mountinfo_string(root, buf);


