From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 15 Mar 2010 09:59:30 +0100
Subject: [PATCH] Remove the double open with same mode
In-Reply-To: <20100313041826.GB7267@agk-dp.fab.redhat.com>
References: <ee77738483f149622d19.1268439476@localhost>
	<20100313041826.GB7267@agk-dp.fab.redhat.com>
Message-ID: <4B9DF6F2.5040403@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 13.3.2010 05:18, Alasdair G Kergon wrote:
> On Fri, Mar 12, 2010 at 04:17:56PM -0800, Malahal Naineni wrote:
>>  	if ((open("/dev/null", O_RDONLY) < 0) ||
>> -	    (open("/dev/null", O_WRONLY) < 0) ||
>>  	    (open("/dev/null", O_WRONLY) < 0))
>>  		exit(EXIT_DESC_OPEN_FAILURE);
> 
> stdin, stdout, stderr
> 
> Alasdair
> 

IMHO it's probably worth to add comment to code, so there will not be similar
'optimizations' proposed in the future.

Zdenek.


