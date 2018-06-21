From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 21 Jun 2018 04:25:46 -0400
Subject: 2018-06-01-stable - libdm: fix buffer overflow
Message-ID: <201806210825.w5L8Pk7N022836@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a0af1bec882de66677e1a0cdceff841c39f92b0
Commit:        8a0af1bec882de66677e1a0cdceff841c39f92b0
Parent:        8bd9a89c148fa66c343e1754485af2387e5fbed1
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jun 21 10:20:09 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jun 21 10:22:24 2018 +0200

libdm: fix buffer overflow

---
 libdm/libdm-common.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 094e618..40b366b 100644
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


