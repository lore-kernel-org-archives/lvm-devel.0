From: brem belguebli <brem.belguebli@gmail.com>
Date: Fri, 23 Apr 2010 23:09:47 +0200
Subject: [BUG-REPORT] mirror legs in the same PV with --alloc anywhere
In-Reply-To: <4BD1ECEB.9010504@redhat.com>
References: <4BC7817E.7080407@redhat.com>
	<20100415220308.GO13021@agk-dp.fab.redhat.com>	<4BC88002.10803@redhat.com>
	<1271495752.5449.53.camel@localhost>	<4BCF1761.7080805@redhat.com>
	<s2q29ae894c1004211036i8113a0e4q16670c46f5700bf1@mail.gmail.com>
	<t2i29ae894c1004230901qe3e4fa75of26e8d39e0d8c7cd@mail.gmail.com>
	<4BD1ECEB.9010504@redhat.com>
Message-ID: <1272056987.2983.2.camel@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Taka,


On Fri, 2010-04-23 at 14:54 -0400, Takahiro Yasui wrote:
> Hi Brem,
> 
> On 04/23/10 12:01, brem belguebli wrote:
> > I've read in the RHEL 5.5 technical datasheet that the shipped LVM
> > version 2.02.56 was alraedy capable of mirrored log.
> 
> As far as I see lvm2 code, I don't think lvm2 in RHEL5.5 has
> mirrored log feature. I'm not sure which document you referred to.
> Could you tell me the exact name of "RHEL 5.5 technical datasheet"?

http://www.redhat.com/f/pdf/rhel/RHEL_5_5_TechOverview_wp_web.pdf
page 4, LVM

" LVM ? the Logical Volume Management storage suite has been augmented
to provide hot sparing
 for mirror journals, enabling automatic replacement or removal of
failed logging devices.
"
> 
> Can we see that document in the following URL?
> http://www.redhat.com/docs/manuals/enterprise/
> 
> Thanks,
> Taka
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel

I may misunderstand the sentence, or someone at RedHat Marketing may
have written something not yet in the pipe for mainstream...

Regards

Brem	


