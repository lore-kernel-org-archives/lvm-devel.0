From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Fri, 13 Oct 2023 18:37:21 +0200
Subject: [PATCH] autoconf: handle the standard --disable-shared flag
In-Reply-To: <169578804917.28077.15346938084174534374@localhost>
References: <20230922064737.31282-2-adam@westernsemico.com>
 <e0bc7bc7-027b-45d6-84a2-c73bf68672c4@gmail.com>
 <169578804917.28077.15346938084174534374@localhost>
Message-ID: <f812791f-3514-4f15-ba64-b48ca8df0023@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27. 09. 23 v 6:14 Adam Joseph napsal(a):
> Quoting Zdenek Kabelac (2023-09-26 12:53:59)
>> The main problem with supporting anything for 'static' linkage is rather a
>> lack of 'known' system that can be build with 'static' library of all other
>> used libraries - and actually be usable.
> 
> Oh it's quite usable; I've been using it on both my laptop and workstations for
> over a year.  See below.  Until recently I was using LVM 2.02 where all of this
> just worked with no patches; the submitted patch is necessary in order to fix a
> regression in LVM 2.03.
> 

Hi

Ok - so I've pushed some patches to immprove the static build support.
Added also couple '--without-blkid|systemd|udev' options - (libaio.a has to 
exist as it's currently mandatory for lvm)

So please check the upstream main HEAD whether it's now fixed for your case.

There are possibly couple more enhancement around automatic combination of 
flags possibly be added.

Regards

Zdenek

