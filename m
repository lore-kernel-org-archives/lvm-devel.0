From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 24 Sep 2015 12:23:03 +0000 (UTC)
Subject: master - libdm: fix bogus macro causing false parameter count
Message-ID: <20150924122303.712FE61023@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1945a0f50415c024d706d29c39604347c4de883d
Commit:        1945a0f50415c024d706d29c39604347c4de883d
Parent:        4e60e6244456785c88dcd5bc0998a348a639c17b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Sep 24 14:22:52 2015 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Sep 24 14:22:52 2015 +0200

libdm: fix bogus macro causing false parameter count

---
 libdm/libdm-deptree.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 7bc098f..b5067f5 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2371,7 +2371,7 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 }
 
 /* Is parameter non-zero? */
-#define PARAM_IS_SET(p) (p) ? 1 : 0
+#define PARAM_IS_SET(p) ((p) ? 1 : 0)
 
 /* Return number of bits assuming 4 * 64 bit size */
 static int _get_params_count(uint64_t bits)


