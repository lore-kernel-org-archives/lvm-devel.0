From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Jun 2014 15:51:42 +0000 (UTC)
Subject: master - tests: change to inittest
Message-ID: <20140611155142.18A7460B61@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c230ae95abf4e0dd08183c37d204b0145ce0a5e8
Commit:        c230ae95abf4e0dd08183c37d204b0145ce0a5e8
Parent:        3f81b7c55c612ab24ade8d637517a33298b2cc94
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 11 17:46:55 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 11 17:46:55 2014 +0200

tests: change to inittest

---
 test/shell/pvremove-warnings.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvremove-warnings.sh b/test/shell/pvremove-warnings.sh
index c9b7c6a..f9d2737 100644
--- a/test/shell/pvremove-warnings.sh
+++ b/test/shell/pvremove-warnings.sh
@@ -8,7 +8,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 2
 pvcreate "$dev1" "$dev2"


