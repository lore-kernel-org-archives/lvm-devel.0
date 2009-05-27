From: Milan Broz <mbroz@redhat.com>
Date: Wed, 27 May 2009 13:30:00 +0200
Subject: Re: [PATCH] Fix handling of snapshots with virtual origin.
In-Reply-To: <Pine.LNX.4.64.0905270711490.29054@hs20-bc2-1.build.redhat.com>
References: <4A1C2FFF.8050604@redhat.com>
	<Pine.LNX.4.64.0905270711490.29054@hs20-bc2-1.build.redhat.com>
Message-ID: <4A1D2438.6070500@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Mikulas Patocka wrote:
> It fixes the problem, but here is another one:
> 
> [gerlinda:~]# rmmod dm_zero
> [gerlinda:~]# lvcreate -n vo -s --virtualoriginsize 64M -L 24M vg1
>   Can't expand LV vo_vorigin: zero target support missing from kernel?
>   Couldn't create virtual origin for LV vo

That's common problem for all target modules when missing, the automatic
module loading doesn't work and dm_zero is not loaded by default in RHEL btw.
(mirror and snapshpot is loaded in initrd).

> [gerlinda:~]# lvcreate -n vo -s --virtualoriginsize 64M -L 24M vg1
>   Internal error: Duplicate LV name vo_vorigin detected in vg1.
>   Couldn't create virtual origin for LV vo
>   Internal error: Duplicate LV name vo_vorigin detected in vg1.
>   Manual intervention may be required to remove abandoned LV(s) before 
> retrying.

hm, I'll check, probably another bug which was there since introduction of vorigin.

It is should fail more intelligently without residual LVs in metadata...

Milan


