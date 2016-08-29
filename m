From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:45 +0000 (UTC)
Subject: master - lvmdbustest.py: Remove '-' from tag ch set
Message-ID: <20160829202845.036156193A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9aed18a57167451b20fa67a80052d39634447064
Commit:        9aed18a57167451b20fa67a80052d39634447064
Parent:        0985b2d0d45d82fbaac7112c0c575cb14792d021
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Aug 25 18:41:53 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:55 2016 -0500

lvmdbustest.py: Remove '-' from tag ch set

---
 test/dbus/lvmdbustest.py |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 457db96..ced49a0 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1107,10 +1107,13 @@ class TestDbusService(unittest.TestCase):
 				vg_proxy.Vg.LvCreateLinear(r + rs(8, '_lv'),
 					mib(4), False, -1, {})
 
-	_ALLOWABLE_TAG_CH = string.ascii_letters + string.digits + "._-+/=!:&#"
+	# Wait until BZ https://bugzilla.redhat.com/show_bug.cgi?id=1370002
+	# is corrected before we add '-' in the allowable character set
+	#_ALLOWABLE_TAG_CH = string.ascii_letters + string.digits + "._-+/=!:&#"
+	_ALLOWABLE_TAG_CH = string.ascii_letters + string.digits + "._+/=!:&#"
 
 	def _invalid_tag_characters(self):
-		bad_tag_ch_set = set(string.printable) - set(self._ALLOWABLE_TAG_CH)
+		bad_tag_ch_set = set(string.printable) - set(self._ALLOWABLE_TAG_CH + '-')
 		return ''.join(bad_tag_ch_set)
 
 	def test_invalid_tags(self):


