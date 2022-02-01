From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Tue, 1 Feb 2022 11:11:44 +0100
Subject: [PATCH] udev: create symlinks and watch even in suspended state
In-Reply-To: <3f7f5039c4529912970f21fe699ad204dfbe5be3.camel@suse.com>
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
	<3f7f5039c4529912970f21fe699ad204dfbe5be3.camel@suse.com>
Message-ID: <cc5c503a-c94f-d32f-9f91-e388f36c647c@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 01. 02. 22 v 9:40 Martin Wilck napsal(a):
> On Mon, 2022-01-31 at 14:33 +0100, Peter Rajnoha wrote:
>> (just discussed this with Zdenek too)
>>
>> The patch makes sense to me!
>>
>> We added all the DM_UDEV_PRIMARY_SOURCE_FLAG and related for exactly
>> such cases where we need to take the existing values already scanned
>> in previous event, main use-case being the trigger at boot. We just
>> didn't cover the 13-dm-disk.rules with the same logic regarding the
>> suspended state to keep the symlinks - I didn't think it would cause
>> issues (because, usually, after suspend, we anticipate incoming
>> resume where the device is scanned again).
>>
>> But yes, if temporarily losing the symlink causes issues, your patch
>> solves that (Zdenek will push that upstream).
> 
> Thank you very much! It occured to me that if we want to solve my use
> case with minimal risk, we could make the the case in which the
> symlinks are preserved conditional on ACTION=="add" (i.e. true coldplug
> events). Tell me if you'd prefer that, I can re-submit.

The problem is handling of 'suspended' state in udev rules - as I've mentioned 
original no userland tool should mostly care about this.

However since there are those things like udev 'trigger' and it would be kind 
of ugly if the 'left-over' suspended device would stop whole system operation
it's most likely better ATM to have some kind of support for this.

It's should be noted there is still 'race' risk of system freezing in the case 
the suspend happens just after sysfs test and before actual i.e. 'blkid' use.
But let's assume the chance of having this to happen is pretty minimal, and 
usually tools doing suspend & resume will work correctly and the 'crash' will 
not likely happen in this particular moment - and suspended device just 
hanging there already for longer time.

The missed issue to be solve is - that ALL rules have to rely on a single 
suspend check - otherwise we risk 'partial' processing  which is the last 
thing we want to see (aka all or nothing).

Your real problem was not the suspend on its own - which still may happen 
anytime (so i.e. just after the test whether device is suspended),
but the bug was related to bad exit path cleaning udev db content in this case 
- which is clear bug.  Next bug is that other rules have to be consistent and 
properly skip its processing if the 1st. rules decides its meant to be skipped.

ATM your patch is already upstream and great thanks for pointing this out.

Regards

Zdenek



