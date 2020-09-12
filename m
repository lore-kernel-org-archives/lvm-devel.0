From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 Sep 2020 11:24:47 +0000 (GMT)
Subject: master - cov: check sscanf result
Message-ID: <20200912112447.D3A59383F86C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=740d5bf6cd39015aac086ddca98a089ba6028d72
Commit:        740d5bf6cd39015aac086ddca98a089ba6028d72
Parent:        a5d45b237dbb6d9c1984fd98ba84bce9bde0ea99
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 13:03:07 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 12 13:24:03 2020 +0200

cov: check sscanf result

---
 daemons/lvmlockd/lvmlockd-core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index a0803de39..fea8ee6cf 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -887,8 +887,8 @@ static int read_adopt_file(struct list_head *vg_lockd)
 			continue;
 		else if (!strncmp(adopt_line, "lvmlockd", 8)) {
 			unsigned int v_major = 0, v_minor = 0;
-			sscanf(adopt_line, "lvmlockd adopt_version %u.%u", &v_major, &v_minor);
-			if (v_major != ADOPT_VERSION_MAJOR)
+			if ((sscanf(adopt_line, "lvmlockd adopt_version %u.%u", &v_major, &v_minor) != 2) ||
+			    (v_major != ADOPT_VERSION_MAJOR))
 				goto fail;
 
 		} else if (!strncmp(adopt_line, "VG:", 3)) {


