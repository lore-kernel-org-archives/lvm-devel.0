From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Fri, 13 Oct 2023 13:01:21 +0000
Subject: [Git][lvmteam/lvm2][main] tests: handle empty table better
Message-ID: <65293fa176e71_2ca5320797b8@gitlab-sidekiq-low-urgency-cpu-bound-v2-868ddd547d-4ns7m.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
0b11b08b by Zdenek Kabelac at 2023-10-13T15:00:55+02:00
tests: handle empty table better

- - - - -


1 changed file:

- test/lib/inittest.sh


Changes:

=====================================
test/lib/inittest.sh
=====================================
@@ -82,9 +82,11 @@ PREFIX="${COMMON_PREFIX}$$"
 # Check we are not conflickting with some exiting setup
 if test -z "$SKIP_ROOT_DM_CHECK" ; then
 	d=$(dmsetup info -c -o name --noheadings --rows -S "suspended=Suspended||name=~${PREFIX}[^0-9]")
-	test "$d" = "No devices found" || {
-		die "DM table already has either suspended or $PREFIX prefixed devices: $d"
-	}
+	case "$d" in
+	"No devices found") ;;
+	"") ;;
+	*) die "DM table already has either suspended or $PREFIX prefixed devices: $d" ;;
+	esac
 fi
 
 test -n "$LVM_TEST_DIR" || LVM_TEST_DIR=${TMPDIR:-/tmp}



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/0b11b08b6e9cd15eeaf1f591c2a3ddd2b8d2d98e

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/0b11b08b6e9cd15eeaf1f591c2a3ddd2b8d2d98e
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231013/c981f8c7/attachment.htm>
