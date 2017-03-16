From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 15 Mar 2017 22:25:53 -0400
Subject: master - tools: Drop unused e2fsadm refs (replaced by fsadm).
Message-ID: <201703160225.v2G2Prb0003129@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e9b5a455e1ce1eebcf949be20c1dd282fdb00d75
Commit:        e9b5a455e1ce1eebcf949be20c1dd282fdb00d75
Parent:        8ef93c756eecc2036f0c945c80972902f27970ca
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 16 02:24:39 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 16 02:24:39 2017 +0000

tools: Drop unused e2fsadm refs (replaced by fsadm).

---
 tools/stub.h |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/tools/stub.h b/tools/stub.h
index a98346a..f03e5d3 100644
--- a/tools/stub.h
+++ b/tools/stub.h
@@ -13,13 +13,6 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-/*
-#define unimplemented \
-	log_error("Command not implemented yet."); return ECMD_FAILED
-
-int e2fsadm(struct cmd_context *cmd, int argc, char **argv) unimplemented
-*/
-
 int lvmsadc(struct cmd_context *cmd __attribute__((unused)),
 	    int argc __attribute__((unused)),
 	    char **argv __attribute__((unused)))


