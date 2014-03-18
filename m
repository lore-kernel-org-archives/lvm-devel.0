From: Paul B. Henson <henson@acm.org>
Date: Mon, 17 Mar 2014 18:07:50 -0700
Subject: cache support
In-Reply-To: <7A62EBEE-E031-469E-902B-FA507CADD9DA@redhat.com>
References: <096101cf2214$d241ed60$76c5c820$@acm.org>	<52F205CA.1090807@redhat.com>	<0a3901cf22af$ae01d2d0$0a057870$@acm.org>	<52F2AD44.8030006@redhat.com>	<0a7b01cf22db$da3f56c0$8ebe0440$@acm.org>	<A2CE00CC-6439-4A2E-A694-8E3B2656867B@redhat.com>	<0fff01cf276c$d059c8d0$710d5a70$@acm.org>	<0C83CD55-18B6-4407-9A42-72F9D6C5683D@redhat.com>	<0b4501cf3d85$44b76c90$ce2645b0$@acm.org>
	<7A62EBEE-E031-469E-902B-FA507CADD9DA@redhat.com>
Message-ID: <0f9a01cf4246$7db93f30$792bbd90$@acm.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> From: Brassow Jonathan
> Sent: Monday, March 17, 2014 8:56 AM
>
> Yes, that is basically the idea.  However, converting the thinpool is a
little
> more tricky.  You already are using the fast device for the thinpool
metadata
> device (which seems awfully large from your example).  When you cache the
> thinpool, I think you just want to cache the data section.
> # lvconvert --type cache --cachepool vg/cachepool vg/thinpool_tdata

Ah right; in your original example you had connected the cache to the
thinpool data lv before creating the actual thinpool, when I tried to
convert that to adding the cache after the fact I didn't take that into
consideration.

In your original example, it said to size the metadata device to
approximately 1/1000 of the data lv size, so for a 4 TB data lv that would
actually be almost 4 GB? The estimation utility says about 2.4 GB:

# thin_metadata_size -b 64k -s 4t -m 100000 -u g
thin_metadata_size - 2.41 gigabytes estimated metadata area size

Evidently online metadata pool resize is supported now, so I guess I don't
have to extremely overestimate from the start, as long as I keep an eye on
it I can always top it off before it runs out.

Thanks.


