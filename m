From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 30 Jul 2019 13:32:11 +0200
Subject: lvmcache in writeback mode gets stuck flushing dirtyblocks
In-Reply-To: <5d400c85.1c69fb81.b383c.5221@mx.google.com>
References: <5d3fce60.1c69fb81.f521b.46a8@mx.google.com>
	<54fa6178-88c8-0236-8595-2c19a6e4b73f@redhat.com>
	<5d400c85.1c69fb81.b383c.5221@mx.google.com>
Message-ID: <0650078b-d311-b05d-14fb-2912662c7524@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30. 07. 19 v 11:23 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Zdenek,
> 
> Thank you for the acknowledging the issue.
> 
> I may not be at a liberty to choose the environment always, as most of the 
> major distributions come bundled with 2.02.133
> 
> I have two followup questions.
> 
> 1/ Is there a way to tell that a particular version has very critical bug 
> (like the one I reported)? Nothing short of hitting it seem the way to confirm 
> currently.


See  'stable-2.02' branch WHATS_NEW  file content:

https://sourceware.org/git/?p=lvm2.git;a=blob_plain;f=WHATS_NEW;hb=refs/heads/stable-2.02


Huge amount of bugfixes and improvements.


> 2/ which is the nearest stable release that addresses this particular issue?

2.02.185....

> 
> 3/ Does latest lvm stable work well in old distributions, Linux kernels too? 
> Whats the compatibility matrix here?


For cache or thin I'd not use anything below 4.20 kernel.

Also note - we do provide support upstream - not for every individual distro
out there in Universe.

If you want/need to backport individual fixes into your version - you will 
likely need to ask for this service your distro provider.

lvm2 is maintained to be fully backward compatible (version 2.02)
so it should work with almost any distros - to the point we are informed
about bug/problem :)

HEAD of git master is a bit more experimental (2.03)...

Regards

Zdenek


