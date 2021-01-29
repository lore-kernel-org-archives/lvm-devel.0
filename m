From: David Teigland <teigland@redhat.com>
Date: Fri, 29 Jan 2021 14:39:39 -0600
Subject: [PATCH] config: set external_device_info_source=none if udev isn't running
In-Reply-To: <8f0c242bce1d4efed73ae852e8d89111aa709c7f.camel@suse.com>
References: <20210127172859.956-1-mwilck@suse.com>
	<f671d5ea-5cb0-a690-f393-c1f733ffdd14@redhat.com>
	<cdf7d365c12b9cac29be22a12392e3f9860b1560.camel@suse.com>
	<7e4ceb01-953b-abbd-cab1-f77374d9d37e@gmail.com>
	<e45a5da341edd2593dce5ef087039f84c20338f4.camel@suse.com>
	<fb6bb401-8641-1d3b-800b-b35fd1acf04d@redhat.com>
	<968c9f098c342091aa041a61caadcffb3e2434d4.camel@suse.com>
	<20210129173444.GB7644@redhat.com>
	<8f0c242bce1d4efed73ae852e8d89111aa709c7f.camel@suse.com>
Message-ID: <20210129203939.GC7644@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jan 29, 2021 at 08:58:21PM +0100, Martin Wilck wrote:
> If there are both SCSI devices and multipath devices with the given
> WWID, multipath would be preferred, I suppose? What would happen during
> device detection, when a SCSI device with the given WWID pops up? How
> would lvm "know" that this device was going to be added to a multipath
> map without asking udev?

Multipath devs and scsi devs are recorded as different types in the
devices file.  So, when looking for the wwid lvm will only look at mpath
devices to find a match for it.

Ideally the user does not also include the scsi component in the devices
file, but if they do lvm's existing mpath component filter is used to
ignore it.

As an example, I have /dev/mapper/mpatha over /dev/sdf.

The devices file mpatha entry is:
IDTYPE=mpath_uuid IDNAME=mpath-3690b11c0000438ad0000057150910423 DEVNAME=/dev/mapper/mpatha PVID=G7YCC9mQZPSvu21oWivrjM2yPtTb55dU

in this case lvm never looks at /dev/sdf.

After adding sdf to the devices file (ignoring the warnings about it):
IDTYPE=sys_wwid IDNAME=naa.690b11c0000438ad0000057150910423 DEVNAME=/dev/sdf PVID=G7YCC9mQZPSvu21oWivrjM2yPtTb55dU
IDTYPE=mpath_uuid IDNAME=mpath-3690b11c0000438ad0000057150910423 DEVNAME=/dev/mapper/mpatha PVID=G7YCC9mQZPSvu21oWivrjM2yPtTb55dU

in this case lvm's mpath filter ignores sdf.

"sys_wwid" entries are matched based on the /sys/.../device/wwid value and
"mpath_uuid" entries are matched based on the /sys/.../dm/uuid value.

(Note the unreliable DEVNAME values in there are used only as hints and
lvm corrects these when it finds they've become incorrect.)

Dave


