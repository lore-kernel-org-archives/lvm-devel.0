From: Malahal Naineni <malahal@us.ibm.com>
Date: Wed, 5 May 2010 07:35:58 -0700
Subject: [BUG-REPORT] mirror legs in the same PV with --alloc anywhere
In-Reply-To: <87fx26zba5.fsf@twilight.int.mornfall.net.>
References: <20100415220308.GO13021@agk-dp.fab.redhat.com>
	<4BC88002.10803@redhat.com> <1271495752.5449.53.camel@localhost>
	<4BCF1761.7080805@redhat.com>
	<s2q29ae894c1004211036i8113a0e4q16670c46f5700bf1@mail.gmail.com>
	<t2i29ae894c1004230901qe3e4fa75of26e8d39e0d8c7cd@mail.gmail.com>
	<4BD1ECEB.9010504@redhat.com> <1272056987.2983.2.camel@localhost>
	<4BD1F9C0.8090108@redhat.com>
	<87fx26zba5.fsf@twilight.int.mornfall.net.>
Message-ID: <20100505143558.GA7122@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai [prockai at redhat.com] wrote:
> Takahiro Yasui <tyasui@redhat.com> writes:
> > On 04/23/10 17:09, brem belguebli wrote:
> >> On Fri, 2010-04-23 at 14:54 -0400, Takahiro Yasui wrote:
> >>> On 04/23/10 12:01, brem belguebli wrote:
> >>>> I've read in the RHEL 5.5 technical datasheet that the shipped LVM
> >>>> version 2.02.56 was alraedy capable of mirrored log.
> >>>
> >>> As far as I see lvm2 code, I don't think lvm2 in RHEL5.5 has
> >>> mirrored log feature. I'm not sure which document you referred to.
> >>> Could you tell me the exact name of "RHEL 5.5 technical datasheet"?
> >> 
> >> http://www.redhat.com/f/pdf/rhel/RHEL_5_5_TechOverview_wp_web.pdf
> >> page 4, LVM
> >> 
> >> " LVM ??? the Logical Volume Management storage suite has been augmented
> >> to provide hot sparing
> >>  for mirror journals, enabling automatic replacement or removal of
> >> failed logging devices.
> >> "
> >
> > Thanks for the information, but I am not sure if this sentence is
> > telling 'mirrored log.' What I can say is the lvm2-2.02.56-8 doesn't
> > have 'mirrored log' feature. I hope someone may give you a explanation...
> For all I can tell, this means that if the log fails, it is
> automatically replaced when there's a hotspare. Which is true, but it
> does not imply mirroring.

But is that new in 5.5? I thought that feature is available in 5.4 too.

Thanks, Malahal.


