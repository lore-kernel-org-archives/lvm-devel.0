From: Martin Wilck <mwilck@suse.com>
Date: Tue, 01 Feb 2022 09:40:11 +0100
Subject: [PATCH] udev: create symlinks and watch even in suspended state
In-Reply-To: <20220131133354.vfomn5gdlgrhue4g@alatyr-rpi.brq.redhat.com>
References: <20220128134229.1783-1-mwilck@suse.com>
	<10ad6fc0-6c24-c98b-4a02-2140883af72d@gmail.com>
	<a1f472a89e9825f90a4104bea535086f0cde6b93.camel@suse.com>
	<d0d0d8f39257bcddf480524f01faae1f15ac2c42.camel@suse.com>
	<e85bd660-0c50-df5d-35de-2fd5b16cc47f@gmail.com>
	<0a55dd1393df2c125f8cb443daaeb7d1b7162bcc.camel@suse.com>
	<aba2f6dd-f4cf-6af4-e2b6-965f5de06cd8@redhat.com>
	<92de9eff521e2702e364f7aa3cce6927d9d9c03c.camel@suse.com>
	<1b20e88f-2714-3c61-73a6-2f34f6a34edc@gmail.com>
	<712b54a06fa1b13f9ac92a00d7b121979c43d31c.camel@suse.com>
	<20220131133354.vfomn5gdlgrhue4g@alatyr-rpi.brq.redhat.com>
Message-ID: <3f7f5039c4529912970f21fe699ad204dfbe5be3.camel@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2022-01-31 at 14:33 +0100, Peter Rajnoha wrote:
> (just discussed this with Zdenek too)
> 
> The patch makes sense to me!
> 
> We added all the DM_UDEV_PRIMARY_SOURCE_FLAG and related for exactly
> such cases where we need to take the existing values already scanned
> in previous event, main use-case being the trigger at boot. We just
> didn't cover the 13-dm-disk.rules with the same logic regarding the
> suspended state to keep the symlinks - I didn't think it would cause
> issues (because, usually, after suspend, we anticipate incoming
> resume where the device is scanned again).
> 
> But yes, if temporarily losing the symlink causes issues, your patch
> solves that (Zdenek will push that upstream).

Thank you very much! It occured to me that if we want to solve my use
case with minimal risk, we could make the the case in which the
symlinks are preserved conditional on ACTION=="add" (i.e. true coldplug
events). Tell me if you'd prefer that, I can re-submit.

Martin


