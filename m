From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 10 Jun 2016 21:06:23 +0000 (UTC)
Subject: master - lvmdbusd: Add roles property to LV common interface
Message-ID: <20160610210623.223D960362@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3bf43a65fefbda1b2628fbbc77ad40e3780a8d84
Commit:        3bf43a65fefbda1b2628fbbc77ad40e3780a8d84
Parent:        8a667f5887f62525cebe7e57ffe6e049ce17c7dd
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 3 17:07:37 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jun 10 15:28:42 2016 -0500

lvmdbusd: Add roles property to LV common interface

See: https://bugzilla.redhat.com/show_bug.cgi?id=1342559
---
 daemons/lvmdbusd/lv.py |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 42219b3..149547f 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -179,6 +179,7 @@ class LvState(State):
 @utils.dbus_property(LV_COMMON_INTERFACE, 'HiddenLvs', "ao")
 class LvCommon(AutomatedProperties):
 	_Tags_meta = ("as", LV_COMMON_INTERFACE)
+	_Roles_meta = ("as", LV_COMMON_INTERFACE)
 	_IsThinVolume_meta = ("b", LV_COMMON_INTERFACE)
 	_IsThinPool_meta = ("b", LV_COMMON_INTERFACE)
 	_Active_meta = ("b", LV_COMMON_INTERFACE)
@@ -281,6 +282,10 @@ class LvCommon(AutomatedProperties):
 		return utils.parse_tags(self.state.Tags)
 
 	@property
+	def Roles(self):
+		return utils.parse_tags(self.state.role)
+
+	@property
 	def lvm_id(self):
 		return self.state.lvm_id
 


