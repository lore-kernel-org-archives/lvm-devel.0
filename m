From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Fri, 09 Jul 2010 15:18:01 +0200
Subject: [PATCH] pid files cleanup
In-Reply-To: <20100709130950.GX22664@agk-dp.fab.redhat.com>
References: <4C36E604.6090106@redhat.com>
	<20100709130950.GX22664@agk-dp.fab.redhat.com>
Message-ID: <4C372189.2080200@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 7/9/2010 3:09 PM, Alasdair G Kergon wrote:
> On Fri, Jul 09, 2010 at 11:04:04AM +0200, Fabio M. Di Nitto wrote:
>> +	/* Create pidfile */
>> +	if (create_lockfile(CLVMD_PIDFILE) < 0) {
> 
> For functions in lvm, our convention is to return 1 on success or 0 on failure.

Ok, i?ll swap them around.

> 
>> +++ b/daemons/cmirrord/Makefile.in
> 
>> +LVMLIBS = $(LVMINTERNAL_LIBS)
> 
> Hmmm.
> 
> We still have already:
>   cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
> 
> - Does the definition above mean this bit can come out?

It?s best to have them there both.

cmirrord: $(top_builddir)/lib/liblvm-internal.a

expresses a dependency that is required before calling the linker.

+LVMLIBS = $(LVMINTERNAL_LIBS)

this is necessary to link against liblvm-internal.

> 
>> +++ b/lib/misc/lvm-file.c
>> +	return 0;
> 
> return 1;
> 
>> +	return -errno;
> 
> return 0;
> 
> (This function already handled/reported errno appropriately.)

I?ll check again.

> 
> Looks good - ack.

Ok thanks, I?ll repost the new patch with the correct return codes later
today or early monday morning.

Fabio


