From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 8 Feb 2010 16:29:04 -0500
Subject: false error messages when merging
In-Reply-To: <Pine.LNX.4.64.1002081542190.13894@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1002081542190.13894@hs20-bc2-1.build.redhat.com>
Message-ID: <20100208212904.GA21695@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Feb 08 2010 at  3:49pm -0500,
Mikulas Patocka <mpatocka@redhat.com> wrote:

> Hi
> 
> LVM2.2.02.60 writes false error messages about tree node not found when 
> activating delayed merging. But it starts merging anyway.
> 
> [slunicko:~]# lvs
>   LV   VG   Attr   LSize  Origin Snap%  Move Log Copy%  Convert
>   m    vg1  -wi-a- 16.00m
> [slunicko:~]# lvcreate -s -n s -c 4k -L 24M vg1/m
>   Logical volume "s" created
> [slunicko:~]# mount -t ext2 /dev/vg1/s /mnt/test
> [slunicko:~]# lvconvert --merge /dev/vg1/s
>   Can't merge when snapshot is open
>   Merging of snapshot s will start next activation.
> [slunicko:~]# umount /mnt/test
> [slunicko:~]# lvchange -an vg1/m
> [slunicko:~]# lvchange -ay vg1/m
>   failed to find tree node for m
>   failed to find tree node for s
> [slunicko:~]#
> ... the merging starts on backgound fine

I can reproduce your "failed to find tree node for" scenario using
the steps you provided.

I'm auditing the deptree code now while working to fix snapshot-merge
for use with Milan's "query info by uuid rather than name" support.  So
something may turn up.

I also saw "failed to find tree node for" messages late last week when I
was developing the 'lvconvert --merge @tag" support that iterated over a
single VG with two LVs that had pending snapshot merges.

I'd merge the 2 snapshots and in the process stale metadata would get
written to disk (at the start of merging the 2nd snapshot, because the
VG instance in process_each_lv() wasn't refreshed after each iteration).

Both merges completed but LVM thought a merge was still in progress
(because the metadata was stale).  I finally got the "failed to find
tree node" when I used "lvchange --refresh <vg/lv>" to eliminate the LVM
inconsistency (effectively the equivalent of your lvchange -an +
lvchange -ay).

Once I eliminated the source of the stale metadata (by refreshing the VG
instance between each process_each_lv iteration) these messages went
away.

All this being said, I'm not sure what's going on with your scenario but
I'll get to the bottom of it.

Mike


