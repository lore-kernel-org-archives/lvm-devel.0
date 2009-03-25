From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 25 Mar 2009 18:09:13 +0000
Subject: [PATCH] fix dm debug pool issues
In-Reply-To: <49CA6FB2.4090504@redhat.com>
References: <49CA64CA.6010708@redhat.com>
	<20090325173303.GL13664@agk.fab.redhat.com>
	<49CA6FB2.4090504@redhat.com>
Message-ID: <20090325180913.GM13664@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 25, 2009 at 06:53:54PM +0100, Milan Broz wrote:
> and next obvious problem with pool data caught by pool debug:
> - second iteration in loop operates on non-existing object here
 
Ack.

Alasdair
-- 
agk at redhat.com


