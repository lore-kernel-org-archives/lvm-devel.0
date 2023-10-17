From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Tue, 17 Oct 2023 23:51:48 +0000
Subject: [Git][lvmteam/lvm2][main] 3 commits: tests: init of dmevent may take upto a second
Message-ID: <652f1e1488812_2bc5d6d9c1991a@gitlab-sidekiq-low-urgency-cpu-bound-v2-65f69dcbf-t765r.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
8b8c9dea by Zdenek Kabelac at 2023-10-17T23:24:03+02:00
tests: init of dmevent may take upto a second

Dynamic load of plugins takes a while...

- - - - -
beae6889 by Zdenek Kabelac at 2023-10-18T01:47:13+02:00
tests: wait till snapshot merge is finished

In case test runs with lvmpolld (and lvmlockd) wait till snapshot
merge is finished.

- - - - -
2e567780 by Zdenek Kabelac at 2023-10-18T01:48:50+02:00
tests: aux kills lvmdbusd more agressively

It&#39;s not exactly trivial to kill &#39;frozen&#39; lvmdbusd.
So skip the test testing interruption and also add killall use.

- - - - -


3 changed files:

- test/lib/aux.sh
- test/shell/dmeventd-restart.sh
- test/shell/snapshot-raid.sh


Changes:

=====================================
test/lib/aux.sh
=====================================
@@ -317,6 +317,7 @@ prepare_lvmdbusd() {
 	unset LVM_LOG_FILE_EPOCH
 	unset LVM_LOG_FILE_MAX_LINES
 	unset LVM_EXPECTED_EXIT_STATUS
+	export LVM_DBUSD_TEST_SKIP_SIGNAL=1
 
 	"$daemon" $lvmdbusdebug > debug.log_LVMDBUSD_out 2>&1 &
 	local pid=$!
@@ -495,6 +496,7 @@ kill_sleep_kill_() {
 	if test -s "$pidfile" ; then
 		pid=$(< "$pidfile")
 		rm -f "$pidfile"
+		test "$pidfile" = "LOCAL_LVMDBUSD" && killall -9 lvmdbusd || true
 		kill -TERM "$pid" 2>/dev/null || return 0
 		for i in {0..10} ; do
 			ps "$pid" >/dev/null || return 0


=====================================
test/shell/dmeventd-restart.sh
=====================================
@@ -27,7 +27,7 @@ _restart_dmeventd() {
 	done
 	# wait a bit, so we talk to the new dmeventd later
 	# On some systems init of selinux contex may take a while...
-	sleep .5
+	sleep 1.5
 }
 
 aux prepare_dmeventd


=====================================
test/shell/snapshot-raid.sh
=====================================
@@ -260,6 +260,12 @@ test_merge_snap()
 	not ls "$mount_dir/B"
 
 	umount "$mount_dir"
+
+	for i in $(seq 1 10); do
+		# Wait tiil snapshot is surely merged
+		dmsetup info $vg-snap || break
+		sleep 0.1
+	done
 }
 
 test_extend_snap()



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/249446e0aa0a3b5f80dfa0879839cffe20479f61...2e56778038bb2874340ed5a470be57f268ac3eff

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/249446e0aa0a3b5f80dfa0879839cffe20479f61...2e56778038bb2874340ed5a470be57f268ac3eff
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231017/d330b1ad/attachment-0001.htm>
