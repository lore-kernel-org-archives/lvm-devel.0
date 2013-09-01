From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  1 Sep 2013 20:41:20 +0000 (UTC)
Subject: master - libdm: new name can't be empty
Message-ID: <20130901204120.A805C60E04@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=350cf7968c77d090b49fc41761221da930d60538
Commit:        350cf7968c77d090b49fc41761221da930d60538
Parent:        eee3aeeb612c65c0851bf8080e0ef381587837ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 30 14:46:34 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Aug 31 21:40:28 2013 +0200

libdm: new name can't be empty

Do not allow passing '' names to kernel.

This test was missing also in kernel, so it has allowed
to create device with '' name.  This then confused dmsetup tool,
since such name is unexpected and unsupported. To remove
such name from table, user has to use -j -m to specify which device
should be removed.

This patch fixes the posibility to run this operation:

dmsetup rename existingdev ''

after this operation commands like  'dmsetup table' are failing.
This patch prohibits to use such name.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3995187..f5d7dc2 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.80 - 
 ==================================
+  Do not allow passing empty new name for dmsetup rename.
   Display any output returned by 'dmsetup message'.
   Add dm_task_get_message_response to libdevmapper.
 
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 9043352..c0669cb 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -698,6 +698,11 @@ int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 		return 0;
 	}
 
+	if (!*newname) {
+		log_error("Non empty new name is required.");
+		return 0;
+	}
+
 	if (!check_multiple_mangled_string_allowed(newname, "new name", mangling_mode))
 		return_0;
 


