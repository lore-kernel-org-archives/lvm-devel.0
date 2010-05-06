From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 6 May 2010 02:45:05 +0100
Subject: [PATCH 05/23] Replicator: suspend/deactivate replicator
In-Reply-To: <b1c4250364861bf2ed2d7bf6a9b157302b8abf56.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
	<b1c4250364861bf2ed2d7bf6a9b157302b8abf56.1272457502.git.zkabelac@redhat.com>
Message-ID: <20100506014505.GM27027@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 28, 2010 at 02:27:24PM +0200, Zdenek Kabelac wrote:
>  	int activation_priority;	/* 0 gets activated first */
> +	int suspend_priority;		/* 1 gets suspend first */
  
Can we make those two work in similar, not opposite, ways?

Alasdair


