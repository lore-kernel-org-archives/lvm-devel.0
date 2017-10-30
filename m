From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Oct 2017 09:42:58 +0100
Subject: [PATCH] lvconvert: fix wrong name order when merging thin snapshot
In-Reply-To: <20171030044829.9564-1-zren@suse.com>
References: <20171030044829.9564-1-zren@suse.com>
Message-ID: <ba22ed84-b3dc-0a88-f1ed-84e0fe51ee21@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30.10.2017 v 05:48 Eric Ren napsal(a):
> The wrong message occurs when merging thin snapshot as below:
> 
> """
> lvcreate --type thin-pool -l80%FREE -n pool1 vg1
> lvcreate -T vg1/pool1 -V 1G -n lv1
> mkfs.ext2 /dev/vg1/lv1
> mkdir mnt
> mount /dev/vg1/lv1 mnt/
> touch mnt/foo
> lvcreate -s -n lv1.snap1 vg1/lv1
> touch mnt/bar
> umount mnt
> lvconvert --merge vg1/lv1.snap1
>    Merging of thin snapshot vg1/lv1 will occur on next activation of vg1/lv1.snap1.
> """
> 
> Fix the wrong name order by saving the initial names at the beginning, and
> also remove the unnecessary callings to display_lvname().
> 
> Signed-off-by: Eric Ren <zren@suse.com>
> ---
>   tools/lvconvert.c | 14 ++++++++------
>   1 file changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/tools/lvconvert.c b/tools/lvconvert.c
> index 76be5cb..3b2341c 100644
> --- a/tools/lvconvert.c
> +++ b/tools/lvconvert.c
> @@ -2101,10 +2101,12 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
>   	int origin_is_active = 0, r = 0;
>   	struct lv_segment *snap_seg = first_seg(lv);
>   	struct logical_volume *origin = snap_seg->origin;
> +	const char *origin_name = display_lvname(origin);
> +	const char *snap_name = display_lvname(lv);


Hi

The only trouble here is that 'display_lvname()' is using internal ring buffer 
inside cmd struct, so the output is meant to be used immediately, otherwise
it might get overwritten and you will get on output some garbage.
So the proper solution here is to copy the string (dm_strncpy()) in
a local buffer[NAME_LEN] buffer.

But I'll handle that one myself.

Thanks for noticing.

Regards

Zdenek


