From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 6 May 2010 02:10:19 +0100
Subject: [PATCH 01/23] Return ECMD_FAILED for break
In-Reply-To: <1c89a9d6ba2bfb863fb66b02743ccd9fa00f97e5.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
	<1c89a9d6ba2bfb863fb66b02743ccd9fa00f97e5.1272457502.git.zkabelac@redhat.com>
Message-ID: <20100506011019.GJ27027@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 28, 2010 at 02:27:20PM +0200, Zdenek Kabelac wrote:
> Return ECMD_FAILED when sigint has been caught.
 
Might seem reasonable, but this condition is also checked in many other places.
If we're going to override the return code when a command might have been
interrupted before it completed, shouldn't we do it consistently everywhere?

Alasdair


