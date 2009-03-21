From: Sandeep K Sinha <sandeepksinha@gmail.com>
Date: Sat, 21 Mar 2009 10:21:45 +0530
Subject: MIrrored Logical Volumes ?
Message-ID: <37d33d830903202151g1a4701ddrfb08d33e308768d6@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,

Recently going through some of the documents and code on LVM mirror,
I just have a couple of questions. I know of them might be silly. so,
kindly forgive me for the same.

I am starting to look at the code though, but having these
informations handy can be quite useful.


1. What if someone wants to do a mirror verification, do we have a
command for the same?
2. Do we have a mirror-read-verify mechanism supported?
3. What happens incase at any point if the two blocks have different
data, say at boot time during resync?
4. What if write on one of the plex/mirrored volume fails and succeds
on the other?
5. How about this:
? ?Rather than syncing the second device to the first device for a
sync configuration , zero out both the devices at the time of creation
and then serving read request from both Logical Volume on Round-Robin
basis.
6. Support for mirroring an existing Logical volume?
7. Can we initiate re-sync through some commands/interface?
8. Do we utilise the mirror volume to recover from any I/O errors on the volume?
9. Looking at the code, looks like for the overall implementaion we
consider the primary LV as reference for all out-of-sync issues, is
that true?
10 .What incase of lost writes? Will you be able to handle those cases
and mark the LV's out-of-sync?

Thanks in advance,

Also, in the linux mainline, the dm-raid1 should be renamed to
dm-mirror as we have separate RAID implementaion through md driver,
Right ?
Just a suggestion, as for all other targets, its dm-target_name.



Regards,
Sandeep.






?To learn is to change. Education is a process that changes the learner.?


