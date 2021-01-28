From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 28 Jan 2021 11:10:13 +0100
Subject: [PATCH] config: set external_device_info_source=none if udev isn't running
In-Reply-To: <20210127172859.956-1-mwilck@suse.com>
References: <20210127172859.956-1-mwilck@suse.com>
Message-ID: <f671d5ea-5cb0-a690-f393-c1f733ffdd14@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27. 01. 21 v 18:28 mwilck at suse.com napsal(a):
> From: Martin Wilck <mwilck@suse.com>
> 
> LVM2 has several configuration options related to device detection
> and udev. In particular, we have obtain_device_list_from_udev=(0|1)
> and external_device_info_source=("none"|"udev"). The two options are
> obviously semantically related, but it's rather unclear if and how
> they interact.
> 
> If udev is unavailable, e.g. in containers, obtain_device_list_from_udev
> (which defaults to 1) will be automatically reset to 0. However,
> if external_device_info_source="udev" is set, this setting is not
> reset to "none", leading to error messages like
> 
>    Udev database has incomplete information about device /dev/vda.
>    /dev/vda: Failed to get external handle [udev].
> 
> This patch changes that, treating external_device_info_source the
> same way as obtain_device_list_from_udev, thereby making LVM2's
> device detection more consistent.
> 
> The default for external_device_info_source is "none", but I believe
> there are very good reasons to change this setting to "udev", because
> LVM will get detection of multipath and md devices wrong most of the
> time otherwise. LVM should follow the same logic as systemd and other


Hi

I'm afraid there is no such simple fix for this as you might think.

In general lvm2 should NOT be used in containers - containers are NOT
technology for such use-case - for as long as devices are not 'a 
containerized' resources.

There have been already several attempts with usage of 'privileged' container,
but still the is 'generic' problem about synchronization between the
main system and its containers.

If users need devices in their containers - those should be always created
on hosting machine with proper naming and access control and given to the 
container. It's fairly bad plan to give such 'power' to the container as it 
can very simply make the host machine (with all other containers) unusable.

But if there is anyone using 'lvm2' inside a container today he must always 
use non-udev variant of lvm2 with some 'strict' rules all over the hosting
machine and other containers - but I'd highly discourage such usage as it
requires a very good 'insight' knowledge.

Zdenek


