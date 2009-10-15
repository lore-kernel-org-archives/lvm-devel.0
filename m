From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Thu, 15 Oct 2009 13:59:52 -0700
Subject: Re: [dm-devel] [PATCH 0 of 2] LVM: Split mirror capability
In-Reply-To: <1255468842.16495.21.camel@hydrogen.msp.redhat.com>
References: <1255468842.16495.21.camel@hydrogen.msp.redhat.com>
Message-ID: <20091015205952.GA14480@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow [jbrassow at redhat.com] wrote:
> [root at bp-01 ~]# lvconvert -m1 --split vg/lv /dev/sdc1
>   Logical volume lv converted.
> [root at bp-01 ~]# lvs
>   LV          VG         Attr   LSize   Origin Snap%  Move Log     Copy%  Convert
>   LogVol00    VolGroup00 -wi-ao 139.09g
>   LogVol01    VolGroup00 -wi-ao   9.81g
>   lv          vg         mwi-a- 500.00m                    lv_mlog 100.00
>   lv_mimage_1 vg         -wi-a- 500.00m
> 
> You can see from the above that I went as far as to specify the leg I
> wanted split off.

How about specifying the hidden volume name of legs rather than PVs?
I imagine a leg could be allocated on two different PVs.

> Aside from the new '--split' argument not being very good, we also end
> up with a new logical volume named, 'lv_mimage_1', which also isn't very
> good.  Should I change the name via s/_mimage_1/-copy-%d/, or should I
> allow the name to be specified (or left alone)?

We should allow the name to be specified. If not specified, we should
do something like: lvname-split-%date% 

> # New '--split' argument.
> # This is suppose to give the user the ability to signify a split
> # of the mirror, rather than a reduction/increase in mirror images.
> # However, something like '--keep_images' might better signify that
> # although we are reducing the number of mirror legs, we want to
> # have them presented rather than removed.
> prompt> lvconvert -m <n> --split vg/lv <removable device(s)>
> 
> # New '--splitmirror <n>' argument
> # Replaces '-m <n> --split', and rather than specifying the number
> # of legs you want remaining in the mirror when finished, you specify
> # the number of legs you want split off.
> #
> # BTW, you can only split off one leg at a time right now, but I
> # don't see a reason why we couldn't split a 4-way mirror into
> # 2 2-way mirrors at some point in the future.  (Being able to
> # specify the removable devices also allows us to choose every
> # other device if we chose to.)
> prompt> lvconvert --splitmirror 1 vg/lv <removable device(s)>

I like the current syntax if you go with 'lvconvert' command. It already
has -m option, and convert is all about the current LV rather than the
resulting split LV.

I like #2 better but only if you go with a different command like
lvsplit:

promt> lvsplit --splitnum <n> vg/lv <list of hidden lv names>

<n> is the number of mirror legs the user wants to split out and the
number of hidden volume names specified can be less than or equal to <n>
but can't be more.

Thanks, Malahal.


