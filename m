From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 16:38:04 -0400
Subject: master - tests: enable lvcreate-pvtags with lvmlockd
Message-ID: <201805312038.w4VKc4T0027322@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=caa600a409fe811a25f2d784daeb6780ea977614
Commit:        caa600a409fe811a25f2d784daeb6780ea977614
Parent:        b9c1cef8176ad127e682e40b1508816b23c9a989
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 31 15:37:25 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 31 15:37:25 2018 -0500

tests: enable lvcreate-pvtags with lvmlockd

---
 test/shell/lvcreate-pvtags.sh |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvcreate-pvtags.sh b/test/shell/lvcreate-pvtags.sh
index 893b3ef..b794c45 100644
--- a/test/shell/lvcreate-pvtags.sh
+++ b/test/shell/lvcreate-pvtags.sh
@@ -10,7 +10,6 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -24,7 +23,7 @@ aux lvmconf 'allocation/maximise_cling = 0' \
 # not required, just testing
 aux pvcreate --metadatacopies 0 "$dev1"
 
-vgcreate "$vg" "${DEVICES[@]}"
+vgcreate $SHARED "$vg" "${DEVICES[@]}"
 pvchange --addtag fast "${DEVICES[@]}"
 
 # 3 stripes with 3 PVs (selected by tag, @fast) is fine


