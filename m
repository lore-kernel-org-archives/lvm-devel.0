From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:01:03 +0000 (UTC)
Subject: master - test: pv-duplicate-uuid
Message-ID: <20160506140103.3807460722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4d1d5ac3ebc88f48e7d959cff9ab9c59ba92ba0
Commit:        d4d1d5ac3ebc88f48e7d959cff9ab9c59ba92ba0
Parent:        708eca39eac23af1a4a889de40d69151168d18f1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 21 15:53:15 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

test: pv-duplicate-uuid

update for duplicate changes
---
 test/shell/pv-duplicate-uuid.sh |   34 ++++++++++++++++++++++++++++------
 1 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/test/shell/pv-duplicate-uuid.sh b/test/shell/pv-duplicate-uuid.sh
index bd54f5f..c846a50 100644
--- a/test/shell/pv-duplicate-uuid.sh
+++ b/test/shell/pv-duplicate-uuid.sh
@@ -19,13 +19,35 @@ aux prepare_devs 3
 
 pvcreate "$dev1"
 UUID1=$(get pv_field "$dev1" uuid)
-pvcreate --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev2"
-pvcreate --config "devices{filter=[\"a|$dev3|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev3"
+pvcreate --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]} global/use_lvmetad=0" -u "$UUID1" --norestorefile "$dev2"
+pvcreate --config "devices{filter=[\"a|$dev3|\",\"r|.*|\"]} global/use_lvmetad=0" -u "$UUID1" --norestorefile "$dev3"
+
+pvscan --cache 2>&1 | tee out
+
+if test -e LOCAL_LVMETAD; then
+	grep "was already found" out
+	grep "WARNING: Disabling lvmetad cache which does not support duplicate PVs." out
+fi
 
 pvs -o+uuid 2>&1 | tee out
-COUNT=$(should grep --count "Found duplicate" out)
 
-# FIXME  lvmetad is not able to serve properly this case
-should [ "$COUNT" -eq 2 ]
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+test $(grep $UUID1 main | wc -l) -eq 1
+
+COUNT=$(grep --count "was already found" warn)
+[ "$COUNT" -eq 2 ]
+
+pvs -o+uuid --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}" 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+not grep "$dev1" main
+grep "$dev2" main
+not grep "$dev3" main
+
+not grep "was already found" warn
 
-pvs -o+uuid --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}"


