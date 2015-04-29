From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 29 Apr 2015 13:10:28 +0000 (UTC)
Subject: master - tests: bash-fu for lvmconf
Message-ID: <20150429131028.64D7060ECF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5b4327f3d34f823ae01511ea8b7635c3637fe87
Commit:        c5b4327f3d34f823ae01511ea8b7635c3637fe87
Parent:        923902013c6d47f02abe2d6171bdeed9f16f413c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 29 12:26:12 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 29 15:09:58 2015 +0200

tests: bash-fu for lvmconf

Sqeeze about 0.1s out of every created conf and use internal
bash associative arrays instead of lot of command forking
---
 test/lib/aux.sh |   33 +++++++++++++++++++++++----------
 1 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 24be323..961dfcf 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -785,16 +785,29 @@ EOF
 	    echo "$v"
 	done >> "$config_values"
 
-	local s
-	for s in $(cut -f1 -d/ "$config_values" | sort | uniq); do
-		echo "$s {"
-		local k
-		for k in $(grep ^"$s"/ "$config_values" | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
-			grep "^$k" "$config_values" | tail -n 1 | sed -e "s,^$s/,	  ,"
-		done
-		echo "}"
-		echo
-	done | tee "$config" | sed -e "s,^,## LVMCONF: ,"
+	declare -A CONF
+	local sec
+	local last_sec
+
+	# read sequential list and put into associative array
+	while IFS=$IFS_NL read -r v; do
+		# trim white-space-chars via echo when inserting
+		CONF[$(echo ${v%%=*})]=${v##*=}
+	done < "$config_values"
+
+	# sort by section and iterate through them
+	printf "%s\n" ${!CONF[@]} | sort | while read -r v ; do
+		sec=${v%%/*} # split on section'/'param_name
+		test "$sec" = "$last_sec" || {
+			test -z "$last_sec" || echo "}"
+			echo "$sec {"
+			last_sec=$sec
+		}
+		echo "	${v#*/} =${CONF[$v]}"
+	done > "$config"
+	echo "}" >> "$config"
+
+	sed -e "s,^,## LVMCONF: ," "$config"
 }
 
 lvmconf() {


