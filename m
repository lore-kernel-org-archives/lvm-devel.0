From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 15 Dec 2008 19:49:06 +0000
Subject: Re: dmsetup export
In-Reply-To: <ac3eb2510811251934w68ca5404r5cb2fff324586a4@mail.gmail.com>
References: <20080915202517.GB12984@agk.fab.redhat.com>
	<ac3eb2510811251934w68ca5404r5cb2fff324586a4@mail.gmail.com>
Message-ID: <20081215194906.GI19917@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Nov 26, 2008 at 04:34:32AM +0100, Kay Sievers wrote:
> One thing I'm missing, what the "export" did, is a comma separated
> list of the table types used for the volume. There are currently
> matches in udev rules for:
>   ENV{DM_TARGET_TYPES}=="|*error*"
>   ENV{DM_TARGET_TYPES}=="*snapshot-origin*"
> Any idea how to provide something similar, or how to replace that? I
> don't care about any name or format it is provided.
 
Ah.

What are those rules actually doing?  Maybe we can come up with a better way to
avoid those special cases...

Alasdair
-- 
agk at redhat.com


