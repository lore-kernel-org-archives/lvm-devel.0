From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 19 May 2009 18:11:14 +0100
Subject: [PATCH] Use suspend with flush when device size was changed during table preload.
In-Reply-To: <4A128DEC.9080508@redhat.com>
References: <4A128DEC.9080508@redhat.com>
Message-ID: <20090519171114.GX5125@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, May 19, 2009 at 12:46:04PM +0200, Milan Broz wrote:
> Use suspend with flush when device size was changed during table preload.
> This allows online mirror resize, also removes condition to preventing
> code to do this.
 
Ack.

Alasdair


