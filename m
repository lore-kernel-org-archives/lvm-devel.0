From: Paul B. Henson <henson@acm.org>
Date: Tue, 11 Feb 2014 13:04:08 -0800
Subject: cache support
In-Reply-To: <A2CE00CC-6439-4A2E-A694-8E3B2656867B@redhat.com>
References: <096101cf2214$d241ed60$76c5c820$@acm.org>	<52F205CA.1090807@redhat.com>	<0a3901cf22af$ae01d2d0$0a057870$@acm.org>	<52F2AD44.8030006@redhat.com>	<0a7b01cf22db$da3f56c0$8ebe0440$@acm.org>
	<A2CE00CC-6439-4A2E-A694-8E3B2656867B@redhat.com>
Message-ID: <0fff01cf276c$d059c8d0$710d5a70$@acm.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> From: Brassow Jonathan
> Sent: Tuesday, February 11, 2014 9:24 AM
>
> What do you think about caching a thin pool?  Then you would get the
> benefit of caching for all of your LVs and you would get all the benefits
of
> thin and thin snapshots.

Hmm, I'm not that familiar with thin allocation in lvm. Basically, I would
allocate the entire PV as a thin LV, attach my entire cache to that, and
then create all of my production LV's with thin allocation out of the single
thin LV? Interesting thought. I have sufficient storage for at least the
midterm, my perhaps flawed understanding is that going with thin LV's
introduces an extra layer of complexity and inefficiency versus regular
allocation?


