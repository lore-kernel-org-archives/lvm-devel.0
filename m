From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 07 Jan 2011 16:03:16 +0100
Subject: [PATCH 2/8] Add default error path for get_property
In-Reply-To: <20110107135543.GH5910@agk-dp.fab.redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>	<6bbe3896c9173603df3be06a3e60dd79f339e028.1294398815.git.zkabelac@redhat.com>	<20110107134141.GC5910@agk-dp.fab.redhat.com>	<4D2719DC.1030008@redhat.com>
	<20110107135543.GH5910@agk-dp.fab.redhat.com>
Message-ID: <4D272B34.7030003@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 7.1.2011 14:55, Alasdair G Kergon napsal(a):
> On Fri, Jan 07, 2011 at 02:49:16PM +0100, Zdenek Kabelac wrote:
>> No - all parameters passed to get_property are NULL in this case -
>> so programmer's error.
>  
> So in what sense is it invalid?
> (I'm basically asking if a more-useful error message is possible.
> So you could say in it the function was called without any parameters set?)
> 

Examle of such error use-case could be:

lv = NULL;
lvm_lv_get_property(lv, "name");

i.e. user will use invalid lv handle for some reason - code mistake, missing
check...

Maybe "Invalid library use." ?

Zdenek


