From: okozina <okozina@fedoraproject.org>
Date: Wed,  9 Mar 2016 12:00:02 +0000 (UTC)
Subject: master - test: fix inverted condition
Message-ID: <20160309120002.7B36360284@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5434e9f5ea697de7fe8785476f9e94f8615012f8
Commit:        5434e9f5ea697de7fe8785476f9e94f8615012f8
Parent:        e655ccb418d942889aae5c83af25ca8d085825b8
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Mar 9 11:31:01 2016 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Mar 9 12:59:42 2016 +0100

test: fix inverted condition

---
 test/shell/lvmetad-pvs.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmetad-pvs.sh b/test/shell/lvmetad-pvs.sh
index 97cc205..2f51944 100644
--- a/test/shell/lvmetad-pvs.sh
+++ b/test/shell/lvmetad-pvs.sh
@@ -10,7 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMPOLLD=1
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 


