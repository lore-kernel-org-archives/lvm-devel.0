From: wangjufeng <wangjufeng@huawei.com>
Date: Sat, 14 Sep 2019 13:54:56 +0000
Subject: stable-2.02 - lvmetad: fix sync cache to lvmetad
Message-ID: <723608783F175343AAB90DD84928BC3401188CF2@dggeml510-mbx.china.huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thanks for your helpful patch. It seems that we two patches aim to fix different problems.
My patch try to fix the problem that new vg metadata is replaced by the old one, it lead to newly created lv get lost.
For proposal patch https://sourceware.org/git/?p=lvm2.git;a=commit;h=c82d05c5ec4928e1c9d875cd28c9ac1397f8941c, it try to fix that old pv list replace newer pv list.
They are not so equivalent.

After running my testcase,  the proposal patch failed, if fail  when
1.lvcreate and lvchange both get token "none"
2.lvchange sets token "updating" (for "none")
lvmetad sees that its token is still "none", allows update
3. lvcreate sets token "updating" (for "none")
lvmetad sees that its token is now "updating", disallows update
lvcreate-> lvm_run_command-> lvmetad_pvscan_all_devs return error, then call lvmetad_make_unused(), it lead to that lvcreate will not commit vg metadata including new lv to lvmetad.
4.lvchange commit the old vg metadata not including new lv to lvmetad.
5.then "lvs" could not see new lv even after calling lvscan --cache, while "dmsetup table" could see its md device.
With that, if a new lvcreate process come up next, it will allocate the start disk sector for newer lv. Actually, the same start disk sector number has already allocated for last lv. Two md device 
get same disk sectors. When write date on one md device, it will destroy the data on the other one.

It seems that my patch don't have the problem which the proposal patch met. Because, after using my patch, the concurrence processes which get token "none" from lvmetad, will all
update lvmetad's token serially.   So, a process could call label_scan_pvscan_all() to scan all devices, only after calling _token_update() and return 1,  geting the chance to update lvmetad.
I run the following testcase to check if my patch have the problem which lvmetad miss some pv. 
	#!/bin/bash
	while :
	do
		echo "scsi remove-single-device 0 0 0 3" > /proc/scsi/scsi
		echo "scsi remove-single-device 0 0 0 2" > /proc/scsi/scsi
		service	lvm2-lvmetad restart
		echo "scsi add-single-device 0 0 0 3" > /proc/scsi/scsi & 
		echo "scsi add-single-device 0 0 0 2" > /proc/scsi/scsi &
		wait
		sleep 1
		cnt=$(pvs|wc -l|xargs)
		#before offline the disks, pvs|wc -l return 4.
		if [ $cnt-ne 4  ];then
			echo "error"
			break
		fi
	done
After running for hours, it did not fail. Is the testcase appropriate to test it?

However, my patch will lead to more times of lvmetad update token when the concurrence processes get token "none" from lvmetad, it is necessary for the problem I met.
Waiting for more proposal from you.
Thanks a lot.


-----Original Message-----
From: lvm-devel-bounces@redhat.com [mailto:lvm-devel-bounces at redhat.com] On Behalf Of David Teigland
Sent: Friday, September 13, 2019 2:48 AM
To: wangjufeng <wangjufeng@huawei.com>
Cc: lvm-devel at redhat.com
Subject: Re: [lvm-devel] stable-2.02 - lvmetad: fix sync cache to lvmetad

On Thu, Sep 12, 2019 at 01:19:19PM +0000, wangjufeng wrote:
> >From 2d2f0bd0bf60400c06f586f28ea49c4888253cc6 Mon Sep 17 00:00:00 
> >2001
> From: wangjufeng <wangjufeng@huawei.com>
> Date: Wed, 11 Sep 2019 23:31:56 +0800
> Subject: [PATCH] lvmetad: fix sync cache to lvmetad

Thanks for the patch and the testing, it looks good.  Some months ago I wrote a similar patch, although yours may be better.  Could you try this alternative patch to see if it works similarly to yours?  If you find that one works better than the other, then we should use the better one.  Or if they are equivalent, I'd likely go with yours.  Thanks

https://sourceware.org/git/?p=lvm2.git;a=commit;h=c82d05c5ec4928e1c9d875cd28c9ac1397f8941c


> error could be reproduced follow those steps:
>     #!/bin/bash
>     vgcreate vgtest /dev/sdb
>     lvcreate -L 100M -n lv1 vgtest
>     while :
>     do
>         service lvm2-lvmetad restart
>         vgs &
>         pvscan &
>         lvcreate -L 100M -n lv2 vgtest &
>         lvchange /dev/vgtest/lv1 --addtag xxxxx &
>         wait
>         if ! lvs|grep lv2;then
>             echo "err create"
>             break
>         fi
>         sleep 1
>         lvremove -y /dev/vgtest/lv2
>         lvchange /dev/vgtest/lv1 --deltag xxxxx
>     done
> 
> and then fail to create vgtest/lv2, actually lv2 was created, while 
> the metadata written on disk is replaced by lvchange. It could look up 
> lv2 by calling dmsetup table, while lvs could not.
> 
> This is because, when lvmetad restarted, several lvm commands update 
> token concurrently, when lvcreate recieve "token_mismatch", it cancle 
> communicating with lvmetad, which leads to that lvmetad cache is not 
> sync with the metadata on disk, then lv2 is not committed to lvmetad 
> cache. The metadata of vgtest which lvchange query from lvmetad is out 
> of date. After lvchange, it use the old metadata cover the new one.
> 
> This patch let lvm process update token synchronously, only one 
> command update lvmetad token at a time.
> 
> lvmetad_pvscan_single send the metadata on a pv by sending "pv_found"
> to lvmetad, while the metadata maybe out of date after waiting for the 
> chance to update lvmetad token. Call label_read to read metadata again.
> 
> Token mismatch may lead to problems, increase log level.
> 
> Signed-off-by: wangjufeng<wangjufeng@huawei.com>
> ---
> daemons/lvmetad/lvmetad-core.c | 21 ++++++++++++++++-----
> lib/cache/lvmetad.c            | 32 ++++++++++++++++++++++++++++++--
> 2 files changed, 46 insertions(+), 7 deletions(-)
> 
> diff --git a/daemons/lvmetad/lvmetad-core.c 
> b/daemons/lvmetad/lvmetad-core.c index 9ae359b..2628022 100644
> --- a/daemons/lvmetad/lvmetad-core.c
> +++ b/daemons/lvmetad/lvmetad-core.c
> @@ -2669,6 +2669,7 @@ static response handler(daemon_state s, client_handle h, request r)
>        int pid;
>        int cache_lock = 0;
>        int info_lock = 0;
> +       uint64_t timegap = 0;
>         rq = daemon_request_str(r, "request", "NONE");
>        token = daemon_request_str(r, "token", "NONE"); @@ -2711,12 
> +2712,22 @@ static response handler(daemon_state s, client_handle h, request r)
>                                     state->update_cmd);
>                  } else if (prev_in_progress && this_in_progress) {
> +                          timegap = _monotonic_seconds() - state->update_begin;
> +                          if (timegap < state->update_timeout) {
> +                                   pthread_mutex_unlock(&state->token_lock);
> +                                   return daemon_reply_simple("token_updating",
> +                                                                  "expected = %s", state->token,
> +                                                                  "update_pid = " FMTd64, (int64_t)state->update_pid,
> +                                                                  "reason = %s", "another command has populated the cache",
> +                                                                  NULL);
> +                          }
> +
>                           /* Current update is cancelled and replaced by a new update */
> -                           DEBUGLOG(state, "token_update replacing pid %d begin %llu len %d cmd %s",
> +                          WARN(state, "token_update replacing pid %d 
> + begin %llu len %d cmd %s",
>                                     state->update_pid,
>                                     (unsigned long long)state->update_begin,
> -                                    (int)(_monotonic_seconds() - state->update_begin),
> +                                   (int)(timegap),
>                                     state->update_cmd);
>                            (void) dm_strncpy(prev_token, state->token, 
> sizeof(prev_token)); @@ -2726,7 +2737,7 @@ static response handler(daemon_state s, client_handle h, request r)
>                           state->update_pid = pid;
>                           strncpy(state->update_cmd, cmd, CMD_NAME_SIZE - 1);
> -                           DEBUGLOG(state, "token_update begin %llu timeout %d pid %d cmd %s",
> +                          WARN(state, "token_update begin %llu 
> + timeout %d pid %d cmd %s",
>                                     (unsigned long long)state->update_begin,
>                                     state->update_timeout,
>                                     state->update_pid, @@ -2737,7 
> +2748,7 @@ static response handler(daemon_state s, client_handle h, request r)
>                            if (state->update_pid != pid) {
>                                    /* If a pid doing update was cancelled, ignore its token update at the end. */
> -                                    DEBUGLOG(state, "token_update ignored from cancelled update pid %d", pid);
> +                                   WARN(state, "token_update ignored 
> + from cancelled update pid %d", pid);
>                                    pthread_mutex_unlock(&state->token_lock);
>                                     return 
> daemon_reply_simple("token_mismatch",
> @@ -2748,7 +2759,7 @@ static response handler(daemon_state s, client_handle h, request r)
>                                                                   NULL);
>                           }
> -                           DEBUGLOG(state, "token_update end len %d pid %d new token %s",
> +                          WARN(state, "token_update end len %d pid %d 
> + new token %s",
>                                     (int)(_monotonic_seconds() - state->update_begin),
>                                     state->update_pid, token); diff 
> --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c index 
> d242260..f896760 100644
> --- a/lib/cache/lvmetad.c
> +++ b/lib/cache/lvmetad.c
> @@ -565,7 +565,12 @@ static int _token_update(int *replaced_update)
>        const char *reply_str;
>        int update_pid;
>        int ending_our_update;
> +       unsigned int wait_sec = 0;
> +       uint64_t now = 0, wait_start = 0;
> +       wait_sec = (unsigned int)_lvmetad_update_timeout;
> +       unsigned int delay_usec = 0;
> +retry:
>        log_debug_lvmetad("Sending lvmetad token_update %s", _lvmetad_token);
>        reply = _lvmetad_send(NULL, "token_update", NULL); @@ -581,6 
> +586,28 @@ static int _token_update(int *replaced_update)
>        update_pid = (int)daemon_reply_int(reply, "update_pid", 0);
>        reply_str = daemon_reply_str(reply, "response", "");
> +       if (!strcmp(reply_str, "token_updating")) {
> +                daemon_reply_destroy(reply);
> +                if (!(now = _monotonic_seconds())) {
> +                          log_print_unless_silent("_monotonic_seconds error");
> +                          return 0;
> +                }
> +
> +                if (!wait_start)
> +                          wait_start = now;
> +
> +                if (now - wait_start <= wait_sec) {
> +                log_warn("lvmetad is being updated, retry for %u more seconds.",
> +                          wait_sec - (unsigned int)(now - wait_start));
> +                delay_usec = 1000000 + lvm_even_rand(&_lvmetad_cmd->rand_seed, 1000000);
> +                usleep(delay_usec);
> +                goto retry;
> +                }
> +
> +                log_print_unless_silent("Not using lvmetad after %u sec lvmetad_update_wait_time, no more try.", wait_sec);
> +                return 0;
> +       }
> +
>        /*
>         * A mismatch can only happen when this command attempts to set the
>         * token to filter:<hash> at the end of its update, but the 
> update has @@ -591,11 +618,11 @@ static int _token_update(int *replaced_update)
>                  ending_our_update = strcmp(_lvmetad_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
> -                 log_debug_lvmetad("Received token update mismatch expected \"%s\" our token \"%s\" update_pid %d our pid %d",
> +                log_print_unless_silent("Received token update 
> + mismatch expected \"%s\" our token \"%s\" update_pid %d our pid %d",
>                                      token_expected, _lvmetad_token, update_pid, getpid());
>                  if (ending_our_update && (update_pid != getpid())) {
> -                           log_warn("WARNING: lvmetad was updated by another command (pid %d).", update_pid);
> +                          log_print_unless_silent("WARNING: lvmetad 
> + was updated by another command (pid %d).", update_pid);
>                 } else {
>                           /*
>                            * Shouldn't happen.
> @@ -2274,6 +2301,7 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
>                 return 1;
>        }
> +       label_read(dev);
>        if (!(info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
>                 log_print_unless_silent("No PV info found on %s for PVID %s.", dev_name(dev), dev->pvid);
>                 if (!lvmetad_pv_gone_by_dev(dev))
> --
> 1.8.3.1


--
lvm-devel mailing list
lvm-devel at redhat.com
https://www.redhat.com/mailman/listinfo/lvm-devel


