From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 14 Mar 2014 02:09:12 +0000 (UTC)
Subject: master - lvmetad: Also return vgname in reply to pv_found requests.
Message-ID: <20140314020912.5FE626036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5eef269f7719089db2474b3f732f3630467d1bbc
Commit:        5eef269f7719089db2474b3f732f3630467d1bbc
Parent:        a31ab7c1716b60d80cbc1b58fa08b7ef9f1b8183
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Mar 14 02:40:20 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Mar 14 03:08:19 2014 +0100

lvmetad: Also return vgname in reply to pv_found requests.

---
 daemons/lvmetad/lvmetad-core.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 2bbf9e4..8522c11 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -952,6 +952,11 @@ out_of_mem:
 			return reply_fail("non-orphan VG without metadata encountered");
 		}
 		unlock_vg(s, vgid);
+
+		// TODO: separate vgid->vgname lock
+		lock_vgid_to_metadata(s);
+		vgname = dm_hash_lookup(s->vgid_to_vgname, vgid);
+		unlock_vgid_to_metadata(s);
 	}
 
 	if (vgid_old && (!vgid || strcmp(vgid, vgid_old))) {
@@ -968,6 +973,7 @@ out_of_mem:
 				   "status = %s", orphan ? "orphan" :
 				                     (complete ? "complete" : "partial"),
 				   "vgid = %s", vgid ? vgid : "#orphan",
+				   "vgname = %s", vgname ? vgname : "#orphan",
 				   "seqno_before = %"PRId64, seqno_old,
 				   "seqno_after = %"PRId64, seqno,
 				   NULL);


