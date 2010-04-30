From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 30 Apr 2010 13:30:46 +0200
Subject: [PATCH 1/3] Display errornous pattern to the user
In-Reply-To: <20100430105509.GC14077@agk-dp.fab.redhat.com>
References: <cover.1272618315.git.zkabelac@redhat.com>	<faa688b19e8215fa87f2e86d9362e74f15337281.1272618315.git.zkabelac@redhat.com>
	<20100430105509.GC14077@agk-dp.fab.redhat.com>
Message-ID: <4BDABF66.1010306@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30.4.2010 12:55, Alasdair G Kergon napsal(a):
> On Fri, Apr 30, 2010 at 11:07:19AM +0200, Zdenek Kabelac wrote:
>> -			log_error("invalid filter pattern");
>> +			log_error("Invalid filter pattern \"%s\".", v->v.str);
> 
> No need to double the quotes there?
> Just %s will do.
> Ack.
> 

Well I wanted to make clear what is the expression - which is usually used
with quotes in lvm.conf. If the user uses spaces inside (or dots for sentence
end) it might look a bit confusing in the first sight. Thought the user will
usually immediatelly notice what is wrong - so plain '%s' would do the job as
well, but I would prefer quotes in this case.

Zdenek


