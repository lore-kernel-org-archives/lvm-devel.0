From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:49 +0000 (UTC)
Subject: master - lvmdbusd: Correct return type for empty PeSegments
Message-ID: <20160829202849.379F260B45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9241dbdf57c997bcb8467b823cae6aee7faab03b
Commit:        9241dbdf57c997bcb8467b823cae6aee7faab03b
Parent:        20318e4c6c389b5ee25b8897fb93aaa036878a95
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 29 12:33:00 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:56 2016 -0500

lvmdbusd: Correct return type for empty PeSegments

---
 daemons/lvmdbusd/pv.py |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/pv.py b/daemons/lvmdbusd/pv.py
index 0780179..ad8d8b3 100644
--- a/daemons/lvmdbusd/pv.py
+++ b/daemons/lvmdbusd/pv.py
@@ -55,9 +55,6 @@ class PvState(State):
 		return self.lvm_path
 
 	def _lv_object_list(self, vg_name):
-
-		# Note we are returning "a(oa(tts))"
-
 		rc = []
 		if vg_name:
 			for lv in sorted(cfg.db.pv_contained_lv(self.lvm_id)):
@@ -242,7 +239,7 @@ class Pv(AutomatedProperties):
 	def PeSegments(self):
 		if len(self.state.pe_segments):
 			return dbus.Array(self.state.pe_segments, signature='(tt)')
-		return dbus.Array([], 'a(tt)')
+		return dbus.Array([], '(tt)')
 
 	@property
 	def Exportable(self):


