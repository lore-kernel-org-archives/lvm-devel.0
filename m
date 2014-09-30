From: Eric Wheeler <lvm-dev@lists.ewheeler.net>
Date: Tue, 30 Sep 2014 15:38:13 -0700 (PDT)
Subject: dm-thinp feature request: skip allocation on writes of all zeroes
In-Reply-To: <20140930201319.GA11339@redhat.com>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
	<20140930201319.GA11339@redhat.com>
Message-ID: <alpine.DEB.2.00.1409301519210.26721@ware.dreamhost.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

>> I have always wondered, does LVM ignore writes with blocks of all
>> zeroes when the destination address is unallocated? From experience,
>> it does not appear that this is so (or I cannot find the config
>> option). This would reduce IOs, particularily when importing VM disk
>> images from other sources. Currently, we must import, allocate lots
>> of zeroes, then fstrim after the fact.
>
> And in your example fstrim wouldn't do anything for you. [...]
> fstrim is only useful to reclaim blocks that are no longer used.

For this particular example, unused data is mostly zeroes and thus fstrim 
frees those unused chunks when dm-thinp receives the discard. I realize 
that fstrim, strictly speaking, is not the solution---it was only meant to 
highlight my example.

> The zeroed data in the image is still valid isn't it?

Yes, and it would continue to be valid because dm-thinp returns zeroes in 
read requests to unallocated chunks. A quick check for all zeroes in the 
bio before writing to an unallocated chunk would save a good amount of 
overhead in our application, and probably others' as well. (Of course if 
the chunk is allocated, the write must proceed like normal.)

> We don't inspect the data being written to infer WRITE SAME-like action.

I would like to implement data inspection in this way and make it 
available as an option to the dmsetup table string.

Can you recommend where I should look in the dm-thinp code to check the 
bio for all zeroes and branch accordingly?

(You are correct, deduplication would be an even better solution, but for 
the moment I believe that WRITE SAME-like action could be implemented with 
a relatively small patch if I can learn where to insert the code.)

-Eric


