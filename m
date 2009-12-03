From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Wed, 2 Dec 2009 18:36:30 -0800
Subject: [PATCH 2 of 2] [RFC] handle a temporary secondary mirror device failure
In-Reply-To: <4B16FF95.6010603@redhat.com>
References: <patchbomb.1259576548@localhost>
	<a0324c61e9fc527d6a9d.1259576550@localhost>
	<4B16FF95.6010603@redhat.com>
Message-ID: <20091203023630.GA15001@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Takahiro Yasui [tyasui at redhat.com] wrote:
> On 11/30/09 05:22, Malahal Naineni wrote:
> > If "retry" policy is selected, then the mirror DSO uses "dmsetup"
> > command to restart a resync. Right now, it is done immediately but we
> > should do it after a configured time. Also, this is done endlessly but
> > should be done only few configured times.
> 
> It sounds good to me. This feature would work in a variety of
> environments by adding configurable parameter as you mentioned.
> 
> > Calling 'lvchange --refresh' to re-integrate the secondary mirror upon a
> > leg failure works if there are no device failures while the "lvchange"
> > is running.  Otherwise, the failed device is replaced with "error"
> > target which is not what we want. For now, this patch calls "dmsetup",
> > but should be replaced with a suitable "LVM" command.
> 
> > +	snprintf(cmd_str, CMD_SIZE, "dmsetup suspend %s-%s", vg, lv);
> > +	syslog(LOG_ERR, "Running command: %s", cmd_str);
> 
> We need to re-queue blocked I/Os instead of finishing them by -EIO.
> I think that "--noflush" option is necessary for "dmsetup suspend."

Yes, you are right. I tested this with existing code dm-raid1 module
which doesn't hold any I/O's, so it worked fine. But I think we should
use some LVM command (or create one if such a command doesn't exist)
instead of "dmsetup" command.

Thank you for looking into it.


Thanks, Malahal.


