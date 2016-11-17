From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:25 +0000 (UTC)
Subject: master - lvmdbustest.py: Remove raid4 use
Message-ID: <20161117173625.9EB83605B4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=560229178cec9daff0c0f4fe16f59013d566f1d5
Commit:        560229178cec9daff0c0f4fe16f59013d566f1d5
Parent:        2a86f54b09312db58b662b1779557466a639567f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Nov 4 13:16:24 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbustest.py: Remove raid4 use

Looks like this isn't support across versions.  Need to add functionality
to service to return the supported segment types, so we only use the
supported ones.
---
 test/dbus/lvmdbustest.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index e5b8243..7e3a877 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -496,7 +496,7 @@ class TestDbusService(unittest.TestCase):
 
 		vg = self._vg_create(pv_paths).Vg
 		self._test_lv_create(
-			vg.LvCreateRaid, (lv_n(), 'raid4', mib(16), 2, 8, g_tmo, {}), vg)
+			vg.LvCreateRaid, (lv_n(), 'raid5', mib(16), 2, 8, g_tmo, {}), vg)
 
 	def _create_lv(self, thinpool=False, size=None, vg=None):
 


