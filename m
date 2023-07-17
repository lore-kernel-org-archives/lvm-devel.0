From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Mon, 17 Jul 2023 14:36:26 +0000
Subject: [Git][lvmteam/lvm2][main] 2 commits: vdo: use long --verbose
Message-ID: <64b551ea643dc_281049c7c14b3@gitlab-sidekiq-low-urgency-cpu-bound-v2-58b657dc5c-tllmz.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
1c278235 by Zdenek Kabelac at 2023-07-17T16:22:29+02:00
vdo: use long --verbose

vdo tools needs long option.

- - - - -
b2431d10 by Zdenek Kabelac at 2023-07-17T16:34:14+02:00
tests: catch all output

Previous fix was invalid (after some in-place shuffling)
&#39;dd&#39; copied goes to &#39;stderr&#39; so we need to catch all output.
Grep needs to check output of tee tool.
Ensure &#39;C&#39; locales are in use with &#39;dd&#39;.

- - - - -


3 changed files:

- scripts/lvm_import_vdo.sh
- test/lib/aux.sh
- test/shell/integrity-syncaction.sh


Changes:

=====================================
scripts/lvm_import_vdo.sh
=====================================
@@ -619,7 +619,7 @@ do
 	  "-f"|"--force"  ) FORCE="-f" ;;
 	  "-h"|"--help"   ) tool_usage ;;
 	  "-n"|"--name"   ) shift; NAME=$1 ;;
-	  "-v"|"--verbose") VERB="-v" ;;
+	  "-v"|"--verbose") VERB="--verbose" ;;
 	  "-y"|"--yes"    ) YES="-y" ;;
 	  "--abort-after-vdo-convert" ) ABORT_AFTER_VDO_CONVERT=1; USE_VDO_DM_SNAPSHOT=0 ;; # For testing only
 	  "--dry-run"     ) DRY="1" ; VERB="-v" ;;


=====================================
test/lib/aux.sh
=====================================
@@ -965,7 +965,7 @@ corrupt_dev() {
 	test -n "${a[0]-}" || return 0
 
 	# Seek for the sequence and replace it with corruption pattern
-	echo -n "${a[1]/$2/$3}" | dd of="$1" bs=1 seek="${a[0]}" conv=fdatasync
+	echo -n "${a[1]/$2/$3}" | LANG=C dd of="$1" bs=1 seek="${a[0]}" conv=fdatasync
 }
 
 prepare_backing_dev() {


=====================================
test/shell/integrity-syncaction.sh
=====================================
@@ -53,8 +53,8 @@ _test1() {
 	# Corrupting raid1 is simple - 1 leg needs to be modifed
 	# For raid5 corrupted block can be places on any of its leg.
 	for i in "$@" ; do
-		aux corrupt_dev "$i" BBBBBBBBBBBBBBBBB BBBBBBBBCBBBBBBBB |tee out
-		grep -q "copied" && break  # leg found and corrupted
+		aux corrupt_dev "$i" BBBBBBBBBBBBBBBBB BBBBBBBBCBBBBBBBB |& tee out
+		grep -q "copied" out && break  # leg found and corrupted
 	done
 
 	lvchange -ay $vg/$lv1



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/32b2e416cc7ecaee013ebecf0ac507622535ce2b...b2431d105e29e8539e14b96ed0e09cb706cf6849

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/32b2e416cc7ecaee013ebecf0ac507622535ce2b...b2431d105e29e8539e14b96ed0e09cb706cf6849
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230717/f4fc470e/attachment-0001.htm>
