From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Apr 2015 09:17:11 +0000 (UTC)
Subject: master - tests: lvmconf update
Message-ID: <20150430091711.866EA61085@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3706abde5e7703562bad3072cca13faf31b6b8b6
Commit:        3706abde5e7703562bad3072cca13faf31b6b8b6
Parent:        13fea879606c4dfdeb8d7686ca2ab606a70a5cd4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 30 11:12:19 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 30 11:16:14 2015 +0200

tests: lvmconf update

New lvmconf function is using bash associative arrays - however
older systems like RHEL5 doesn't provide this feature. In this case
stay with older variant.

Restore support for use case like this:
aux lvmconf 'tags/@foo {}'
---
 test/lib/aux.sh |   20 +++++++++++++++++---
 1 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 373909a..67df0f5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -786,14 +786,28 @@ EOF
 	    echo "$v"
 	done >> "$config_values"
 
-	declare -A CONF
+	declare -A CONF || {
+		# Associative arrays is not available
+		local s
+		for s in $(cut -f1 -d/ "$config_values" | sort | uniq); do
+			echo "$s {"
+			local k
+			for k in $(grep ^"$s"/ "$config_values" | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
+				grep "^$k" "$config_values" | tail -n 1 | sed -e "s,^$s/,	 ,"
+			done
+			echo "}"
+			echo
+		done | tee "$config" | sed -e "s,^,## LVMCONF: ,"
+		return 0
+	}
+
 	local sec
 	local last_sec
 
 	# read sequential list and put into associative array
 	while IFS=$IFS_NL read -r v; do
 		# trim white-space-chars via echo when inserting
-		CONF[$(echo ${v%%=*})]=${v##*=}
+		CONF[$(echo ${v%%[={]*})]=${v#*/}
 	done < "$config_values"
 
 	# sort by section and iterate through them
@@ -804,7 +818,7 @@ EOF
 			echo "$sec {"
 			last_sec=$sec
 		}
-		echo "	${v#*/} =${CONF[$v]}"
+		echo "    ${CONF[$v]}"
 	done > "$config"
 	echo "}" >> "$config"
 


