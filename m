From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:32:38 -0400
Subject: master - tests: aux.sh drop useless echo
Message-ID: <201707101232.v6ACWc6I022629@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5bd09cb79dc66eac7515b93b8991eded8ac25afd
Commit:        5bd09cb79dc66eac7515b93b8991eded8ac25afd
Parent:        6be61bf04408855da89f2117d268f1dbe1b98279
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 1 09:28:06 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: aux.sh drop useless echo

Simply trim on space.
---
 test/lib/aux.sh |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c5944c2..21c94ac 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -548,7 +548,7 @@ teardown() {
 	dm_table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
 		# Avoid activation of dmeventd if there is no pid
 		cfg=$(test -s LOCAL_DMEVENTD || echo "--config activation{monitoring=0}")
-		if echo "$(dm_info suspended,name)" | grep -q "^Suspended:.*$prefix" ; then
+		if dm_info suspended,name | grep -q "^Suspended:.*$prefix" ; then
 			echo "Skipping vgremove, suspended devices detected."
 		else
 			vgremove -ff "$cfg"  \
@@ -1207,8 +1207,7 @@ EOF
 
 	# read sequential list and put into associative array
 	while IFS=$IFS_NL read -r v; do
-		# trim white-space-chars via echo when inserting
-		CONF["$(echo ${v%%[={]*})"]=${v#*/}
+		CONF["${v%%[={ ]*}"]=${v#*/}
 	done < "$config_values"
 
 	# sort by section and iterate through them


