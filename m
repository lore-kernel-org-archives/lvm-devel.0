From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 23 Mar 2011 17:33:39 +0100
Subject: [PATCH 1/6] Pool locking code
In-Reply-To: <4D8A1886.1090105@redhat.com>
References: <cover.1300828168.git.zkabelac@redhat.com>	<d2353d5f9081b6eed91ed788af173ddf88dd4bba.1300828168.git.zkabelac@redhat.com>	<1300888988.14527.28.camel@ubuntu>	<4D8A098C.8060803@redhat.com>
	<1300893225.14527.37.camel@ubuntu> <4D8A1886.1090105@redhat.com>
Message-ID: <4D8A20E3.5030809@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 23.3.2011 16:57, Zdenek Kabelac napsal(a):
> Dne 23.3.2011 16:13, Joe Thornber napsal(a):
>> On Wed, 2011-03-23 at 15:54 +0100, Zdenek Kabelac wrote:
>>> Forget to answer the size question -  >8MB is allocated by the VG
>>> mempool when
>>> set of simple linear 7200LVs on 1 PV are in use.
>>
>> So I think each snapshot/restore of a VG pool of that size is going to
>> take ~0.1 seconds.  So now my question is how many times are we
>> expecting to happen during a typical tool invocation?  Your previous
>> reply suggested it happens just once?
> 
> 
> If there would be just 1 vg read for 7200 activate call - obviously I'd not
> need to play with this dm_pool locking :)
> 
> So there is 7200 vg reads - which will use this one locked pool with my patch set:
> 
> To give some time info here
> (using my unoptimized gcc debug build on C2D 2.2GHz - but with few more
> patches applied than current upstream)
> 
> Deactivate 7200LV   (7200 already active)
> real	1m16.140s
> user	0m5.686s
> sys	0m31.410s
> 
> 
> Deactivate 7200LV (non active)
> real	0m2.121s
> user	0m1.083s
> sys	0m1.032s
> 
> 
> Activate 7200  (non active)
> real	2m19.324s
> user	0m6.503s
> sys	1m30.785s
> 
> Activate 7200 (7200 already active)
> real	0m10.945s
> user	0m1.422s
> sys	0m9.502s
> 

I think good example could be this - when I disable mprotect-ing in my
patchset - and enable crc checking with each dm_pool_restore (which should be
similar to memcpy) (otherwise crc is checked only with final pool unlock)

Deactivate 7200LV
real	1m45.353s
user	0m38.128s
sys	0m27.395s

Deactivate 7200LV
real	0m36.948s
user	0m35.284s
sys	0m1.642s

Activate 7200  (non active)
real	2m31.065s
user	0m37.740s
sys	1m18.481s

(here could be observed - thet mprotecting takes 12s)

Activate 7200 (7200 already active)
real	0m52.188s
user	0m35.570s
sys	0m16.563s



So I'd estimate like 33seconds would be wasted.

--

And to complete the picture - crc only with unlock - and without pool
mprotect-ing  - assuming this would be normal work.

Deactivate 7200LV
real	1m9.989s
user	0m4.584s
sys	0m26.882s

Deactivate 7200LV
real	0m2.119s
user	0m1.087s
sys	0m1.025s

Activate 7200  (non active)
real	2m11.363s
user	0m4.696s
sys	1m15.393s

Activate 7200 (7200 already active)
real	0m11.127s
user	0m1.392s
sys	0m9.669s


Zdenek




