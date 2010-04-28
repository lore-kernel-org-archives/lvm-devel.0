From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 28 Apr 2010 15:37:21 -0400
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <87y6g99bbg.fsf@twilight.int.mornfall.net.>
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>
Message-ID: <4BD88E71.3040902@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/27/10 11:14, Petr Rockai wrote:
> this is a first iteration of the transient-error handling in
> lvconvert. This works by marking LVs as partial even though there are no
> PVs missing -- whenever a mirror marks a leg or log as failed (in the
> status string). The downside of this approach is that we never figure
> which PV is failing, but that would require kernel-level support for IO
> error tracking.

Hello Petr,

It is very grad that the patch to fix this issue was being developed.
I have not thoroughly read it, but I found one issue. It doesn't work
for a "mirrored" log, while it looks good for a "core" or "disk" log.

A logical mirror device with a mirrored log has a 'layered' structure
for its log. Therefore, we need to check the status of its log, too.
As for the following example, we need to check the status string of
vg00-lv00_mlog.

# dmsetup ls --tree -o ascii
vg00-lv00 (253:5)
 |-vg00-lv00_mimage_1 (253:4)
 |  `- (8:48)
 |-vg00-lv00_mimage_0 (253:3)
 |  `- (8:32)
 `-vg00-lv00_mlog (253:2)
    |-vg00-lv00_mlog_mimage_1 (253:1)
    |  `- (8:80)
    `-vg00-lv00_mlog_mimage_0 (253:0)
       `- (8:64)

# dmsetup status
...
vg00-lv00_mlog: 0 8192 mirror 2 253:0 253:1 8/8 1 AA 1 core
vg00-lv00: 0 24576 mirror 2 253:3 253:4 24/24 1 AA 3 disk 253:2 A


The current code calls lv_check_transient() at the beginning of
_lvconvert_mirrors_repair() but I think that lv_check_transient()
needs to be called in functions which repairs a mirror log,
such as _lv_update_log_type(), too.

Also this patch works well not only for a transient error but
also a medium error, therefore, function names with '_transient'
could be '_status' or '_status_string'. (e.g. lv_check_status())

I appreciate your work on this issue.

Thanks,
Taka


