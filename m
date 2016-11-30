From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 30 Nov 2016 21:59:40 +0000 (UTC)
Subject: master - lvmdbusd: Remove TODO on concurrent access to properties
Message-ID: <20161130215940.39E396104B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1d520909534e1a4e1adf2513a5061adfe631d6af
Commit:        1d520909534e1a4e1adf2513a5061adfe631d6af
Parent:        37f05ccab1a576bdd71be1f4f80ab6f621042d71
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 30 13:03:25 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 30 15:59:06 2016 -0600

lvmdbusd: Remove TODO on concurrent access to properties

As the code now uses a single thread to handle all changes to the
dbus model we no longer need to handle this potential race
condition.
---
 daemons/lvmdbusd/automatedproperties.py |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/automatedproperties.py b/daemons/lvmdbusd/automatedproperties.py
index 5e14d61..7b22d19 100644
--- a/daemons/lvmdbusd/automatedproperties.py
+++ b/daemons/lvmdbusd/automatedproperties.py
@@ -159,10 +159,7 @@ class AutomatedProperties(dbus.service.Object):
 			cfg.om.lookup_update(self, new_id[0], new_id[1])
 
 		# Grab the properties values, then replace the state of the object
-		# and retrieve the new values
-		# TODO: We need to add locking to prevent concurrent access to the
-		# properties so that a client is not accessing while we are
-		# replacing.
+		# and retrieve the new values.
 		o_prop = get_properties(self)
 		self.state = new_state
 		n_prop = get_properties(self)


