From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Wed, 23 Aug 2023 13:11:39 +0000
Subject: [Git][lvmteam/lvm2][main] 2 commits: tests: better slowdown
Message-ID: <64e6058b85dcb_28a4d4495887@gitlab-sidekiq-low-urgency-cpu-bound-v2-5498c8d5b5-z9csq.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
941c4a20 by Zdenek Kabelac at 2023-08-23T13:47:39+02:00
tests: better slowdown

- - - - -
71ff21f5 by Zdenek Kabelac at 2023-08-23T15:10:40+02:00
gcc: initialize variables

- - - - -


3 changed files:

- lib/device/device_id.c
- test/shell/lvconvert-mirror.sh
- tools/lvconvert.c


Changes:

=====================================
lib/device/device_id.c
=====================================
@@ -2286,7 +2286,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			 int *device_ids_invalid, int noupdate)
 {
 	struct dm_list wrong_devs;
-	struct device *dev;
+	struct device *dev = NULL;
 	struct device_list *devl;
 	struct dev_use *du, *du2;
 	struct dev_id *id;


=====================================
test/shell/lvconvert-mirror.sh
=====================================
@@ -324,10 +324,10 @@ aux throttle_dm_mirror || SHOULD=should
 test "${LVM_VALGRIND:-0}" -eq 0 || SHOULD=should
 
 # Use large enough mirror that takes time to sychronize with small regionsize
-lvcreate -aey -L30 -Zn -Wn --type mirror --regionsize 16k -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
+lvcreate -aey -L20 -Zn -Wn --type mirror --regionsize 4k -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
 $SHOULD not lvconvert -m-1 $vg/$lv1 "$dev1" 2>&1 | tee out
 aux restore_dm_mirror
-grep "not in-sync" out
+$SHOULD grep "not in-sync" out
 
 lvconvert $vg/$lv1 # wait
 
@@ -342,7 +342,7 @@ lvremove -ff $vg
 aux throttle_dm_mirror || :
 # No parallel lvconverts on a single LV please
 # Use big enough mirror size and small regionsize to run on all test machines succesfully
-lvcreate -aey -Zn -Wn -L30 --type mirror --regionsize 16k -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-8"
+lvcreate -aey -Zn -Wn -L20 --type mirror --regionsize 4k -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-8"
 check mirror $vg $lv1
 check mirror_legs $vg $lv1 2
 


=====================================
tools/lvconvert.c
=====================================
@@ -3069,7 +3069,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *metadata_lv = NULL;  /* existing or created */
 	struct logical_volume *data_lv;             /* lv arg renamed */
-	struct logical_volume *pool_lv;             /* new lv created here */
+	struct logical_volume *pool_lv = NULL;             /* new lv created here */
 	const char *pool_metadata_name;             /* user-specified lv name */
 	char converted_names[3*NAME_LEN];	    /* preserve names of converted lv */
 	struct segment_type *pool_segtype;          /* thinpool or cachepool */



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/73abdedbc9bd200847b2030b8573546f6f0a44ee...71ff21f57ca961fb490bc2aaef8dc4b5f5d4d18e

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/73abdedbc9bd200847b2030b8573546f6f0a44ee...71ff21f57ca961fb490bc2aaef8dc4b5f5d4d18e
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230823/e0f303fb/attachment-0001.htm>
