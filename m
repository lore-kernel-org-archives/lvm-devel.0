From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 16 Jun 2021 17:19:54 +0000 (GMT)
Subject: main - lvmdbusd: Don't setup search key unless needed
Message-ID: <20210616171954.147E53987C2C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e8f3a63000e692b00070b337e475fd4a38e1f1c9
Commit:        e8f3a63000e692b00070b337e475fd4a38e1f1c9
Parent:        27abb03a0d5fb8342741c306b0ce187f41f8e3c1
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Jun 10 13:26:15 2021 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Jun 16 12:19:02 2021 -0500

lvmdbusd: Don't setup search key unless needed

self.lvm_id is a property which actually executes some code which doesn't
need to be executed everytime.
---
 daemons/lvmdbusd/automatedproperties.py | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/automatedproperties.py b/daemons/lvmdbusd/automatedproperties.py
index b5919484d..d9f2c5e9f 100644
--- a/daemons/lvmdbusd/automatedproperties.py
+++ b/daemons/lvmdbusd/automatedproperties.py
@@ -157,14 +157,15 @@ class AutomatedProperties(dbus.service.Object):
 		if not self._ap_search_method:
 			return 0
 
-		search = self.lvm_id
-		if search_key:
-			search = search_key
-
 		# Either we have the new object state or we need to go fetch it
 		if object_state:
 			new_state = object_state
 		else:
+			if search_key:
+				search = search_key
+			else:
+				search = self.lvm_id
+
 			new_state = self._ap_search_method([search])[0]
 			assert isinstance(new_state, State)
 


