From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 Jan 2015 10:39:43 +0000 (UTC)
Subject: master - dev_manager: do not mark snapshot origins as unusable devices just because of possible blocked mirror underneath
Message-ID: <20150109103943.6E3A160A35@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0e17bca90326104020ba31b00fb9f66abf278b6
Commit:        c0e17bca90326104020ba31b00fb9f66abf278b6
Parent:        9dbeacf303f34d4a9f4ccad666e44ca55b83fada
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 9 11:24:16 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 9 11:24:16 2015 +0100

dev_manager: do not mark snapshot origins as unusable devices just because of possible blocked mirror underneath

At first, all snapshot-origins where marked as unusable unconditionally
here, but we can't cut off whole snapshot-origin use in a stack just
because of this possible mirror state. This whole "device_is_usable"
check was even incorrectly part of persistent filter before commit
a843d0d97c66aae1872c05b0f6cf4bda176aae2 (where filter cleanup was
done).

The persistent filter is used only if obtain_device_list_from_udev=0,
which means that the former check for snapshot-origin here had not even
been hit with default configuration for a few years before commit
a843d0d97c66aae1872c05b0f6cf4bda176aae2 (the check for snapshot-origin and
skipping of this LV was introduced with commit a71d6051ed3d72af6895733c599cc44b49f24dbb
back in 2010).

The obtain_device_list_from_udev=1 (and hence not using persistent
filter and hence not hitting this check for snapshot-origins and skipping) has been
in action since commit edcda01a1e18af6599275801a8237fe10112ed6f (that is 2011).
So for 3 years this condition was not even checked with default configuration,
making it superfluous.

This all changed in 2014 with commit 8a843d0d97c66aae1872c05b0f6cf4bda176aae2
where "filter-usable" is introduced  and since then all snapshot-origins
have been marked as unusable more often than before and making snapshot-origins
practically unusable in a stack.

This patch removes this incorrect check from commit a71d6051ed3d72af6895733c599cc44b49f24dbb
which caused snapshot-origins to be unusable more often recently.

If we want to fix this eventually in a correct way, we need to look
down the stack and if snapshot-origin is hit and there's a blocked
mirror underneath, only then mark the device as unusable. But mirrors
in stack are not supported anymore so it's questionable whether it's
worth spending more time on this at all...
---
 lib/activate/dev_manager.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e336933..18092db 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -547,18 +547,22 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 		}
 
 		/*
-		 * Snapshot origin could be sitting on top of a mirror which
-		 * could be blocking I/O.  Skip snapshot origins entirely for
-		 * now.
-		 *
-		 * FIXME: rather than skipping origin, check if mirror is
-		 * underneath and if the mirror is blocking I/O.
+		 * FIXME: Snapshot origin could be sitting on top of a mirror
+		 * which could be blocking I/O. We should add a check for the
+		 * stack here and see if there's blocked mirror underneath.
+		 * Currently, mirrors used as origin or snapshot is not
+		 * supported anymore and in general using mirrors in a stack
+		 * is disabled by default (with a warning that if enabled,
+		 * it could cause various deadlocks).
+		 * This is former check used, but it's not correct as it
+		 * disables snapshot-origins to be used in a stack in
+		 * general, not just over mirrors!
 		 */
-		if (check.check_suspended && target_type && !strcmp(target_type, "snapshot-origin")) {
+		/*if (check.check_suspended && target_type && !strcmp(target_type, "snapshot-origin")) {
 			log_debug_activation("%s: Snapshot-origin device %s not usable.",
 					     dev_name(dev), name);
 			goto out;
-		}
+		}*/
 
 		if (target_type && strcmp(target_type, "error"))
 			only_error_target = 0;


