From: Dongsu Park <dongsu.park@profitbricks.com>
Date: Tue, 17 Jul 2012 17:19:08 +0200
Subject: [RFC PATCH 0/3] optimize detection of MD devices
In-Reply-To: <20120716221758.GB2641@agk-dp.fab.redhat.com>
References: <1342473519-2853-1-git-send-email-dongsu.park@profitbricks.com>
	<20120716221758.GB2641@agk-dp.fab.redhat.com>
Message-ID: <20120717151908.GA22995@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Alasdair,

On 16.07.2012 23:17, Alasdair G Kergon wrote:
> On Mon, Jul 16, 2012 at 11:18:36PM +0200, dongsu.park at profitbricks.com wrote:
> > This patchset optimizes the detection mechanism of MD devices, as well
> 
> Optimising the detection, good.

Thank you for reviewing the patches.

> > as introduces a possibility to turn off detections of the legacy
> > metadata versions.
>  
> Maybe, but I'd discourage people from turning it off more strongly, as it's a
> small price to pay for peace of mind.
> 
> So, after review and a bit of tweaking, yes, I'm in favour.
> 
> However, the whole of this code is itself 'legacy' in that this detection is
> moving into blkid under udev's control, so you should check if that code is
> sufficiently efficient too.

Ok, that's a good point.
It would be more optimal to get MD metadata versions, rather than to turn
off v1.0/v0.9 completely.

I think it could be possible to determine the MD metadata version of a
device, simply reading the sysfs attribute,
e.g. /sys/block/md*/md/metadata_version.

I'll post a second patchset with the improvement.

Dongsu

> 
> Alasdair
> 


