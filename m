From: Milan Broz <mbroz@redhat.com>
Date: Sun, 06 Mar 2011 02:36:58 +0100
Subject: LVM2/libdm/ioctl libdm-iface.c
In-Reply-To: <20110306011808.GW10767@agk-dp.fab.redhat.com>
References: <20110305211719.11626.qmail@sourceware.org>
	<20110306011808.GW10767@agk-dp.fab.redhat.com>
Message-ID: <4D72E53A.6070104@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/06/2011 02:18 AM, Alasdair G Kergon wrote:
> On Sat, Mar 05, 2011 at 09:17:19PM -0000, mbroz at sourceware.org wrote:
>> 	This feature is not yet upstream and becuase cryptsetup in next version
>> 	uses this flag, it will cause a lot of noise on old kernels.
>  
> Let's take this as a temporary change then, and once the new code becomes
> reasonably widely used, revert this patch, OK?

IMHO that message should not be there at all. If application relies on
it, then it must fail completely, warning is not enough.
For other uses it is optional.

Anyway, we can revert it even now, I added version check into cryptsetup
to detect kernel DM version and do not use that call if it is old.
And the same change will be needed in RHEL or people will complain...

Milan


