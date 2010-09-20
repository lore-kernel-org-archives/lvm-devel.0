From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 20 Sep 2010 13:35:05 +0100
Subject: [PATCH] Revert to old glibc behaviour for vsnprintf used in emit_to_buffer function
In-Reply-To: <4C8E36DA.2050707@redhat.com>
References: <4C8E36DA.2050707@redhat.com>
Message-ID: <20100920123505.GA30622@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 13, 2010 at 04:36:10PM +0200, Peter Rajnoha wrote:
> Revert to old glibc behaviour for vsnprintf used in emit_to_buffer fn.
> Otherwise, the check that follows would be wrong for new glibc versions.
 
Ack.

Alasdair


