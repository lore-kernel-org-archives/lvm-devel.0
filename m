From: Paul B. Henson <henson@acm.org>
Date: Wed, 2 Apr 2014 19:54:56 -0700
Subject: cache support
In-Reply-To: <DCB87093-0877-4CE2-A738-4D5E6B2D194B@redhat.com>
References: <52F2AD44.8030006@redhat.com>
	<0a7b01cf22db$da3f56c0$8ebe0440$@acm.org>
	<A2CE00CC-6439-4A2E-A694-8E3B2656867B@redhat.com>
	<0fff01cf276c$d059c8d0$710d5a70$@acm.org>
	<0C83CD55-18B6-4407-9A42-72F9D6C5683D@redhat.com>
	<0b4501cf3d85$44b76c90$ce2645b0$@acm.org>
	<7A62EBEE-E031-469E-902B-FA507CADD9DA@redhat.com>
	<20140329013841.GL5509@bender.unx.csupomona.edu>
	<20140329014302.GM5509@bender.unx.csupomona.edu>
	<DCB87093-0877-4CE2-A738-4D5E6B2D194B@redhat.com>
Message-ID: <20140403025456.GO5509@bender.unx.csupomona.edu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 02, 2014 at 03:34:46PM -0500, Brassow Jonathan wrote:
> 
> What version of LVM are you using?

2.02.103 at the moment, it's what's currently marked stable in Gentoo
linux. I also noticed these in the logs, even after I deleted the failed
lv:

Mar 28 18:45:08 virtz lvm[13640]: Invalid target type.
Mar 28 18:45:18 virtz lvm[13640]: Invalid target type.
Mar 28 18:45:28 virtz lvm[13640]: Invalid target type.

They went away after I rebooted.

Thanks...


