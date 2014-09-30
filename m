From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 30 Sep 2014 21:30:15 +0200
Subject: dm-thinp feature request: skip allocation on writes of all zeroes
In-Reply-To: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
Message-ID: <542B04C7.8000708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30.9.2014 v 20:38 Eric Wheeler napsal(a):
> Hello all,
>
> We have been testing dm-thinp for the last couple years and it has been stable
> for the most part.
>
> I have always wondered, does LVM ignore writes with blocks of all zeroes when
> the destination address is unallocated? From experience, it does not appear
> that this is so (or I cannot find the config option). This would reduce IOs,
> particularily when importing VM disk images from other sources. Currently, we
> must import, allocate lots of zeroes, then fstrim after the fact.

If you use thinpool with enabled zeroing of provisioned chunks -
then you always get 'zeroed' thin-volume device in all parts -
so you don't need to zero anything in such block device.

Now if you 'skip' writing zeroes (like i.e. cp -a  does when copying files),
you get your  'skip' zero writes.

Note - if your original source device would be already an LV - it might be 
then probably more efficient to either use such LV as an external origin, or 
implement support for merging LV into thin-pool.


Regards

Zdenek



