From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 06 May 2010 10:22:15 +0200
Subject: [PATCH 05/23] Replicator: suspend/deactivate replicator
In-Reply-To: <20100506014505.GM27027@agk-dp.fab.redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
	<b1c4250364861bf2ed2d7bf6a9b157302b8abf56.1272457502.git.zkabelac@redhat.com>
	<20100506014505.GM27027@agk-dp.fab.redhat.com>
Message-ID: <4BE27C37.1040704@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 6.5.2010 03:45, Alasdair G Kergon napsal(a):
> On Wed, Apr 28, 2010 at 02:27:24PM +0200, Zdenek Kabelac wrote:
>>  	int activation_priority;	/* 0 gets activated first */
>> +	int suspend_priority;		/* 1 gets suspend first */
>   
> Can we make those two work in similar, not opposite, ways?


Idea behind 'suspend_priority' is not meant as a generic concept - it's rather
designed for needs of Replicator target (also that's why original  reject name
had the replicator in it and after your suggestion a more generic name is used
here) - if there will be some future target with similar logic - we could try
to figure out probably better logic.

Meanwhile - the difference from activation_priority is there are no levels,
it's rather boolean 'true/false' logic (which could go to comment probably) -
when  false==0  means default - no priority for parent suspend - thus unless
explicitly set by dm user (which currently is made only by  the Replicator
target) the function _suspend_parent() will have no effect on processing.

Zdenek



