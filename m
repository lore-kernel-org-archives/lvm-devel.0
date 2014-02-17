From: Paul B. Henson <henson@acm.org>
Date: Mon, 17 Feb 2014 14:12:10 -0800
Subject: cache support
In-Reply-To: <0C83CD55-18B6-4407-9A42-72F9D6C5683D@redhat.com>
References: <096101cf2214$d241ed60$76c5c820$@acm.org>	<52F205CA.1090807@redhat.com>	<0a3901cf22af$ae01d2d0$0a057870$@acm.org>	<52F2AD44.8030006@redhat.com>	<0a7b01cf22db$da3f56c0$8ebe0440$@acm.org>	<A2CE00CC-6439-4A2E-A694-8E3B2656867B@redhat.com>	<0fff01cf276c$d059c8d0$710d5a70$@acm.org>
	<0C83CD55-18B6-4407-9A42-72F9D6C5683D@redhat.com>
Message-ID: <185501cf2c2d$53f02030$fbd06090$@acm.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> From: Brassow Jonathan
> Sent: Wednesday, February 12, 2014 9:40 AM
> 
> I'll let others weigh-in on the overhead of introducing thin-provisioning.
> However, my experience is that the overhead is very small and the benefit
is
> very large.
[...]
> You now have a very fast thin pool from which you will create thin volumes
> and snapshots.  Everything is cached with low overhead.

Hmm, interesting; this would allow me to work within the confines of the
intended lvm cache support yet achieve my goal of using a single cache
device for all of my LV's. That does seem preferable to trying to manage
dm-cache manually with dmsetup.

Thanks.


