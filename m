From: Martin Wilck <mwilck@suse.com>
Date: Fri, 29 Jan 2021 14:02:11 +0100
Subject: [PATCH] config: set external_device_info_source=none if udev isn't running
In-Reply-To: <fb6bb401-8641-1d3b-800b-b35fd1acf04d@redhat.com>
References: <20210127172859.956-1-mwilck@suse.com>
	<f671d5ea-5cb0-a690-f393-c1f733ffdd14@redhat.com>
	<cdf7d365c12b9cac29be22a12392e3f9860b1560.camel@suse.com>
	<7e4ceb01-953b-abbd-cab1-f77374d9d37e@gmail.com>
	<e45a5da341edd2593dce5ef087039f84c20338f4.camel@suse.com>
	<fb6bb401-8641-1d3b-800b-b35fd1acf04d@redhat.com>
Message-ID: <968c9f098c342091aa041a61caadcffb3e2434d4.camel@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2021-01-29 at 12:11 +0100, Zdenek Kabelac wrote:
> 
> The reason why "udev" is not default is simply because ATM it's
> unreliable 
> source of info. It works well only for couple device types - but for
> lot of 
> others it is not actual (i.e. network storage) (there are even no
> events 
> generated for updating udev)

What kind of network storage?

> If we would have thought for a minute that 'udev' is good generic
> default - it would be already done....

The udev source (DEV_EXT_UDEV) is only used in 5 places, all in the
filtering code path:

 a) dev_is_md_component()
 b) _dev_is_mpath()
 c) dev_is_partitioned()
 d) _dev_is_fwraid()
 e) check_pv_min_size()

I think we agree that "udev" is more reliable than "none" in case a)
and b). For which of the above is "udev" unreliable, why, and why can't
it be fixed?

> > How do you handle that in Fedora? 
> Generic advice is - configure proper filters.

IMHO filters aren't the solution. LVM offers
"multipath_component_detection", which suggests that
no additional filtering is necessary. Unfortunately
"multipath_component_detection" is broken without
'external_device_info_source="udev"'.

LVM filters are hard to get right, even for experienced admins. Not
because of the regexes, but because of the many different names under
which devices appear under /dev. Telling admins that they need to
fiddle with filter rules just to make multipath work sounds like
something I'd have said 10 years ago, but not in 2021.

> There will be also a new 'filtering' introduced in a form a basic
> acceptance 
> list of devices - that may be seen in some cases as more simple to
> use.

Perhaps this will improve matters, perhaps it'll add more confusion.?
I don't know enough to tell.


> > But that would also mean that you would have to change the default
> > to
> > "udev", and *remove* both options "external_device_info_source" and
> > "obtain_device_list_from_udev". The former should be hard coded to
> > "udev" and the latter to 1, end of story. If you don't remove these
> > options, how would the new option interact with the existing two?
> > Which
> > would take precedence?
> 
> Each - has different meaning:
> 
> obtain_device_list_from_udev:? should give us devices for scanning -
> this
> is pretty much ok - but not much different for list of /sys/block
> anyway.
> 
> external_device_info_source:?? delegate 'trust' to udev knowledge
> about device 

Thanks for the explanation. It makes sense, even though I think not all
combinations do (if you trust udev, why not use it for obtaining the
device list?). "lvmconfig --withcomments" is a bit vague about this.

> If your only problem is mpath leg detection - one solution could be -
> to 
> improve lvm2 internal mpath leg detection - there is even some
> initial patch 
> set in some Dave's branch - which would need just some polishing to
> become 
> probably more usable then 'udev info source'.

Which branch are you referring to?


> > If you can provide a better solution than my patch, we'll happily
> > take it. But we need *something* to fix the current breakage.
> 
> 1st. we should define what kind of problem you try to solve
> and eventually open BZ (since list is not best for tracking
> progress).
> 
> Is is detection of 'mpath leg' while mpath is offline
> and user is not able to set his filters properly ?

See above. Our aspiration is to make multipath+md+LVM setups work out-
of-the-box, reliably.

Regards,
Martin




