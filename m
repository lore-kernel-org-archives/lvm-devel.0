From: David Teigland <teigland@redhat.com>
Date: Thu, 25 Feb 2021 10:47:53 -0600
Subject: [PATCH LVM2 v1 1/2] blkdeactive: Introduce option "forcevg" to forcibly deactivate VG
In-Reply-To: <602d5fc8-f2ff-23cd-676d-b14db3186786@redhat.com>
References: <20210225110451.175956-1-leo.yan@linaro.org>
	<5ceaf113-7d5a-3a98-3937-f3e6b1406a14@redhat.com>
	<20210225123935.GC160939@leoy-ThinkPad-X240s>
	<602d5fc8-f2ff-23cd-676d-b14db3186786@redhat.com>
Message-ID: <20210225164753.GB9864@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Feb 25, 2021 at 01:54:35PM +0100, Zdenek Kabelac wrote:
> lvm supports options --nolocking  --noudevsync
> so there should be a mechanism to bypass many problem when necessary -
> 
> it's just we shouldn't use the biggest hammer as the first thing in the row.
> 
> the option --force should be able to 'gradualy' raise 'actions'.
> 
> Depending on what kind of trouble is user expecting.
> 
> But under-cutting device with error target should be definitely the last.

I think we need a solution like you're talking about, specifically a way
to deactivate a VG without metadata, based only on info from dm devices.
It's needed for a couple of other cases I know of also.

If we had a command like that, we could also add an option for it to go
directly to wipe_table.  (In this specific sanlock scenario we know that
the devices are not responsive, so we know that intermediate steps would
just get stuck.)

Until we have that command, blkdeactivate seems to be a workable option,
and it's simple to change it later with a config setting.


