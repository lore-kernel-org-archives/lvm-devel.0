From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 24 Mar 2017 11:29:59 -0400
Subject: master - make: Don't hard-code SHELL as /bin/sh
Message-ID: <201703241529.v2OFTxsw021348@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=25c841af00f858c16ebda7baae87cebcfa59b010
Commit:        25c841af00f858c16ebda7baae87cebcfa59b010
Parent:        4046f9bd956fec51769dc9d43afcd899d2c117b4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Mar 24 15:29:17 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Mar 24 15:29:17 2017 +0000

make: Don't hard-code SHELL as /bin/sh

---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 41f23e6..8148fb5 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -13,7 +13,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SHELL = /bin/sh
+SHELL = @SHELL@
 
 @SET_MAKE@
 


