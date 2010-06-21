From: Milan Broz <mbroz@redhat.com>
Date: Mon, 21 Jun 2010 17:21:06 +0200
Subject: LVM2 ./WHATS_NEW tools/reporter.c
In-Reply-To: <20100621151543.GC26395@agk-dp.fab.redhat.com>
References: <20100617131553.18299.qmail@sourceware.org>
	<20100621151543.GC26395@agk-dp.fab.redhat.com>
Message-ID: <4C1F8362.4020907@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On 06/21/2010 05:15 PM, Alasdair G Kergon wrote:
> On Thu, Jun 17, 2010 at 01:15:53PM -0000, mbroz at sourceware.org wrote:
>> 	IOW fix lvs -o help
> 
> dmsetup info -c -o help
> 
> also still gives me non-zero return code.

I have no time to fix it now, sorry.

It just fixes documented use in manual "-o help". 
"Use -o help to view the full list of columns available."

It will not work if you run -o +something,help" anyway.

Milan


