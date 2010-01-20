From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Wed, 20 Jan 2010 15:28:00 -0800
Subject: [PATCH 0 of 10] LVM: mirrored/redundant/duplicate mirror log
In-Reply-To: <4B578EC6.30104@redhat.com>
References: <1263954062.22044.9.camel@hydrogen.msp.redhat.com>
	<4B578EC6.30104@redhat.com>
Message-ID: <20100120232800.GA30276@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Takahiro Yasui [tyasui at redhat.com] wrote:
> On 01/19/10 21:21, Jonathan Brassow wrote:
> > I found a bug in the previous patches that were disrupting the workings
> > of 'lvconvert --repair'.  I was not properly grabbing the first item of
> > a list (and checking for NULL).
> > 
> > I am also having some mysterious trouble running the testsuite.  I am
> > getting different results between identical runs.  I'm not sure if I
> > have some old dmeventd running or what...
> > 
> > Also, people are unhappy with "redundant" as the name of the log type.
> > Other suggestions?  "mirrored"?  "duplicated"?
> 
> "reduntant" is used such as by "redundant system," and familiar key word
> to me. Otherwise, how about "dual-disk"? It will work for two disks.
> Or "multi-disk" for more than two disks?

I like 'mirrored'.  If not 'mirrored', I would go with 'multidisk'

Thanks, Malahal.


