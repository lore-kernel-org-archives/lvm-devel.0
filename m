From: Martin Wilck <mwilck@suse.com>
Date: Fri, 02 Feb 2018 11:55:47 +0100
Subject: [PATCH 0/2] LVM2: fix lvmetad udev rules for CHANGE events
In-Reply-To: <1516050733.5699.48.camel@suse.com>
References: <20171221115705.5055-1-mwilck@suse.com>
	<1516050733.5699.48.camel@suse.com>
Message-ID: <1517568947.4013.17.camel@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2018-01-15 at 22:12 +0100, Martin Wilck wrote:
> Dear LVM2 maintainers,
> 
> On Thu, 2017-12-21 at 12:57 +0100, Martin Wilck wrote:
> > The current logic in 69-dm-lvm-metad.rules is broken for the
> > default
> > "enable-udev-systemd-background-jobs" case. Detailed information
> > about the
> > problem can be found in the commit message of the 2nd patch in the
> > set.
> > That patch also contains the tiny actual change of this patch set:
> > if
> > systemd
> > background jobs are active, the variables SYSTEMD_ALIAS and
> > SYSTEMD_WANTS are
> > also set for CHANGE events, not only for ADD.
> > 
> > The reason that the patch set is quite large nonetheless is that I
> > wanted
> > the comments in the rules file to match the actual behavior.
> > Substitution of
> > multi-line comments is very hard, if not impossible, with the
> > string
> > substitution approach in the current Makefile. That necessitates
> > the
> > first
> > patch, which introduces no functional change.
> > 
> > Martin Wilck (2):
> >   lvm2: 69-dm-lvm-metad.rules: explicit pvscan rule
> >   lvm2: 69-dm-lvm-metad.rules: set systemd vars on "change"
> > 
> >  udev/69-dm-lvm-metad.rules.in | 53
> > +++++++++++++++++++++++++++++++++++++++----
> >  udev/Makefile.in              |  9 +++++---
> >  2 files changed, 54 insertions(+), 8 deletions(-)
> 
> A review of this patch would be highly appreciated.
> 

a gentle reminder, could someone please have a look?

Regards,
Martin


-- 
Dr. Martin Wilck <mwilck@suse.com>, Tel. +49 (0)911 74053 2107
SUSE Linux GmbH, GF: Felix Imend?rffer, Jane Smithard, Graham Norton
HRB 21284 (AG N?rnberg)


