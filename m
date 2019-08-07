From: Lakshmi Narasimhan Sundararajan <lns@portworx.com>
Date: Wed, 7 Aug 2019 17:44:06 +0530
Subject: lvmcache in writeback mode gets stuck flushingdirtyblocks
In-Reply-To: <CAMNNMLHRjNR71m06pz=uU1OaDeBVh0j+EScBkhSeuDom-Zvurw@mail.gmail.com>
References: <5d3fce60.1c69fb81.f521b.46a8@mx.google.com>
	<CAMNNMLH8jxxRYNyZn6s=Qqhgt7kA5CereTUw8GSNeUrJ5V9iDw@mail.gmail.com>
	<5d41650e.1c69fb81.cd7bd.5ade@mx.google.com>
	<CAMNNMLFnGpkFkbDMsO3k_GJKoHLcmk-chn3O6dtBCgyxjrXkwA@mail.gmail.com>
	<CAMNNMLHRjNR71m06pz=uU1OaDeBVh0j+EScBkhSeuDom-Zvurw@mail.gmail.com>
Message-ID: <5d4ac08e.1c69fb81.48e83.253c@mx.google.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Nikhil,
So far with migration_threshold set to 20480 from original 2048 has not seen this problem. I shall keep you posted on further internal testing on this.

But I would like to understand more on the tunables we have with lvmcache. Can you please help refine the definitions and my understanding of the below.

Defaults:
migration_threshold 2048 
random_threshold 4 
sequential_threshold 512

1) Migration_threshold: This tunable controls how many sectors (512B) of data are pulled in or pushed out of cache. So all flush/writeback operations from the cache device operates in multiples of this threshold. There is no migration ever in writethrough cache.  Larger the number of sectors will help in moving larger context into/out of cache immediately and improve sequential performance, but shall adversely affect random performance.
2) Sequential_threshold: This tunable is a count of IO requests that have to be contiguous (start from last IO end) to treat incoming IO as sequential. Each IO can be of any size. As long as the next IO is contiguous it shall get counted. All IOs only after hitting the sequential_threshold shall be bypassed from cache. Even if one IO misses the sequential pattern from last IO, the threshold gets reset to zero? And all intervening IO are cached?
3) Random_threshold: This tunable is a count of IO requests that miss sequential condition to be considered as a random IO. In default condition, first 4 IO requests in the stream can never get cached. All IO between 4 and 512 requests in the stream get cached. And only after 512 requests does the caching module recognize incoming IO as sequential and stop caching further.

Outside of this I also see 3 other tunables.
    "read_promote_adjustment",
    "write_promote_adjustment",
    "discard_promote_adjustment"

To which I do not understand how this needs to be configured.
Are there any other tunables that I am not aware of.

Can you please help clarify on the same.

Regards
LN
Sent from Mail for Windows 10

From: Nikhil Kshirsagar
Sent: Monday, August 5, 2019 2:42 PM
To: LVM2 development
Subject: Re: [lvm-devel] lvmcache in writeback mode gets stuck flushingdirtyblocks

Can you try increasing migration threshold through the device mapper commands and check if this gets rid of the infinite flushes ?

On Fri, 2 Aug, 2019, 5:14 PM Nikhil Kshirsagar, <nkshirsa@redhat.com> wrote:
Hello,

You are welcome.

The migration threshold is in terms of chunks, I think.. So it should be at least one chunk so the looping forever won't happen. The bug we found was if chunksize goes beyond a certain value triggered by larger than one tb sized cached lv, it ends up with migration threshold hard coded to lower than the increased chunksize.

Yes migration threshold right now needs better documentation and explanations. Also the ability to see it from lvm commands just like we can see chunksize. We are working on it through the bzs mentioned earlier. (See the bz about migration threshold needing better documentation in the man pages)

I think right now you can get it only at the device mapper layer, will check..

Regards,
Nikhil.


On Fri, 2 Aug, 2019, 5:09 PM Lakshmi Narasimhan Sundararajan, <lns@portworx.com> wrote:
Hi Nikhil,
Thank you for your email. Much appreciated.
?
In my environment, Chunksize is fixed at 1M irrespective of the pool size. This may take the number of entries over 1M and result in kernel warning. But the class of systems we are using are huge, and so the memory and cpu bottlenecks does not seem to be a factor in our testing.
?
I looked up at the bugs. The first one about chunksize > 1M, we should be safe on that given our chunksize is fixed at 1MB.
The other one about migration threshold is interesting, I will have to validate this again.
?
What would be the unit of migration threshold?? Is it the number of 512 byte sectors? And what exactly is its definition?
?
And also curiously this does not seem to be exported through lvm cli, need to fetch this only through dmsetup?
?
Thanks
LN
Sent from Mail for Windows 10
?
From: Nikhil Kshirsagar
Sent: Wednesday, July 31, 2019 3:04 PM
To: LVM2 development
Subject: Re: [lvm-devel] lvmcache in writeback mode gets stuck flushing dirtyblocks
?
This used to happen if the chunksize increased as a result of needing to use more than a million chunks to store the size of the cached lv. What is the size of the pool?
?
Regards,
Nikhil.
?
On Tue, 30 Jul, 2019, 1:25 PM Lakshmi Narasimhan Sundararajan, <lns@portworx.com> wrote:
Hi Team,
A very good day to all.

I am using lvmcache in writeback mode. When there are dirty blocks still in the lv, and if needs to be destroyed or flushed, then
It seems to me that there are some conditions under which the dirty data flush gets stuck forever.
?
?
As an example:
root at pdc4-sm35:~# lvremove -f pwx0/pool
? 367 blocks must still be flushed.
? 367 blocks must still be flushed.
? 367 blocks must still be flushed.
? 367 blocks must still be flushed.
? 367 blocks must still be flushed.
? 367 blocks must still be flushed.
^C
root at pdc4-sm35:~#
?
I am running these version:
root at pdc4-sm35:~# lvm version
? LVM version:???? 2.02.133(2) (2015-10-30)
? Library version: 1.02.110 (2015-10-30)
? Driver version:? 4.34.0
root at pdc4-sm35:~#
?
?
This issue seems old and reported multiple places. There have been some acknowledgement that this issue is resolved in 2.02.133, but still I see it. Also, I have seen some posts report it in 2.02.170+ as well (here: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=878441) (Package: lvm2 Version: 2.02.173-1 Severity: normal)
?
I filed one here myself, https://github.com/lvmteam/lvm2/issues/22, trying? to understand from you experts where we are on this?
?
I would sincerely appreciate your help in understanding the state of this issue in more detail.
?
Best regards
LN
Sent from Mail for Windows 10
?
--
lvm-devel mailing list
lvm-devel at redhat.com
https://www.redhat.com/mailman/listinfo/lvm-devel
?
--
lvm-devel mailing list
lvm-devel at redhat.com
https://www.redhat.com/mailman/listinfo/lvm-devel

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190807/8b9a51ad/attachment.htm>
