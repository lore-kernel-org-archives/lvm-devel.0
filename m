From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  6 Mar 2013 17:17:59 +0000 (UTC)
Subject: master - test: Fix the way in_sync calculates the sync field location
Message-ID: <20130306171759.83F4FA0C32@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=69ae454d4d46228a5de3b95a2ddcd8b8307fed4a
Commit:        69ae454d4d46228a5de3b95a2ddcd8b8307fed4a
Parent:        31c24dd9f2ad7b5f7913a18c9f11a00d7b3474a1
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Mar 6 11:12:09 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Mar 6 11:12:09 2013 -0600

test: Fix the way in_sync calculates the sync field location

'in_sync' was using the last field in the RAID status output as
the location for the sync ratio field.  The sync ratio may not always
be the last field, but it will always be the 7th field.  So we switch
to using the absolute value rather than computing the last field
index number.
---
 test/lib/check.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 6b7849f..48e3073 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -170,8 +170,8 @@ in_sync() {
 	fi
 
 	if [ ${a[2]} = "raid" ]; then
-		# Last argument is the sync ratio for RAID
-		idx=$((${#a[@]} - 1))
+		# 6th argument is the sync ratio for RAID
+		idx=6
 		type=${a[3]}
 	elif [ ${a[2]} = "mirror" ]; then
 		# 4th Arg tells us how far to the sync ratio


