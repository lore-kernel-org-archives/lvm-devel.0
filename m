From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 05 Mar 2011 12:52:21 +0100
Subject: [PATCH] Fix reading of released memory
In-Reply-To: <20110305000011.GR10767@agk-dp.fab.redhat.com>
References: <4D71616D.5050407@redhat.com>
	<20110305000011.GR10767@agk-dp.fab.redhat.com>
Message-ID: <4D7223F5.40700@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 5.3.2011 01:00, Alasdair G Kergon napsal(a):
> On Fri, Mar 04, 2011 at 11:02:21PM +0100, Zdenek Kabelac wrote:
>> Bugfix patch attached
>  
> Odd one out?  How did that happen?!
> 


My assuption - it's been always there - however in the past VGs were using
command pool - thus memory was still valid - after change for separate pools
for each allocated VG - this was not noticed as the memory remained valid so
the output remained correct.

Zdenek


